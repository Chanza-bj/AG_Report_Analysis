# =============================================================================
# 10_dashboard_data.R  -  Single source of truth for the dashboard's contract
# table and every count derived from it. Reads the page-cited CSVs and writes
# site/dashboard_data.js so the headline numbers, the status donut, the flag
# breakdown and the delivery-by-year chart can never drift from the rows.
#
#   const CONTRACTS        - the deep-verified contract rows (table + charts)
#   const CONTRACT_STATUS  - delivery donut, counted from CONTRACTS
#   const FLAG_COUNTS      - what the auditors flagged, counted from CONTRACTS
#   const DELIVERY         - delivery status by year, counted from CONTRACTS
#   const COUNTS           - every scalar count the page prints
#
# Output: site/dashboard_data.js
# =============================================================================
suppressMessages({library(readr); library(dplyr); library(stringr); library(jsonlite)})

cf     <- read_csv("data_clean/contracts_flagged.csv",  show_col_types = FALSE)
valued <- read_csv("data_raw/contracts_valued_all.csv", show_col_types = FALSE)
cases  <- read_csv("data_clean/supplier_cases.csv",     show_col_types = FALSE)

# ---- display helpers --------------------------------------------------------
# Short ministry label (strip "Ministry of", collapse known long names).
short_ministry <- function(m) {
  m |>
    str_replace("^Ministry of ", "") |>
    str_replace("^Office of the President.*", "Office of the President") |>
    str_replace("Infrastructure Housing and Urban Development", "Infrastructure") |>
    str_replace("Home Affairs and Internal Security", "Home Affairs") |>
    str_replace("Local Government and Rural Development", "Local Government") |>
    str_replace("Community Development and Social Services", "Community Dev") |>
    str_replace("Finance and National Planning", "Finance") |>
    str_replace("Transport and Logistics", "Transport") |>
    str_replace("Water Development and Sanitation", "Water") |>
    str_replace("Information and Media", "Information & Media") |>
    str_replace("Fisheries and Livestock", "Fisheries") |>
    str_replace("Works and Supply", "Works & Supply") |>
    str_replace("Lands and Natural Resources", "Lands")
}

# Format an amount + currency the way the table shows it.
fmt_val <- function(a, cur) {
  if (is.na(a)) return("not stated")
  u <- ifelse(cur %in% c("USD", "US$"), "US$",
         ifelse(cur %in% c("ZMW", "K"), "K", paste0(cur, " ")))
  if (a >= 1e9)      v <- paste0(formatC(a/1e9, format = "f", digits = 2), "bn")
  else if (a >= 1e6) v <- paste0(formatC(a/1e6, format = "f", digits = 1), "m")
  else               v <- formatC(round(a), format = "d", big.mark = ",")
  paste0(u, v)
}

# ---- CONTRACTS array (shape matches the old hand-kept `contracts`) ----------
# [year, ministry, supplier, description, value, delivered, flagged, page]
c_tbl <- cf |>
  arrange(desc(financial_year), source_pdf_page) |>
  transmute(
    y   = as.character(financial_year),
    m   = short_ministry(ministry_std),
    s   = supplier,
    d   = str_squish(description),
    val = mapply(fmt_val, suppressWarnings(as.numeric(contract_value)), contract_currency),
    del = recode(coalesce(delivered, "NA"), Yes = "Yes", No = "No", Partial = "Partial", .default = "NA"),
    fl  = str_squish(issue_flagged),
    p   = paste0("p", source_pdf_page))

CONTRACTS <- unname(as.list(as.data.frame(t(as.matrix(c_tbl)), stringsAsFactors = FALSE)))

# ---- delivery status donut (counted from the rows) --------------------------
del <- factor(c_tbl$del, levels = c("No", "Partial", "Yes", "NA"))
dn  <- as.integer(table(del))
names(dn) <- c("No", "Partial", "Yes", "NA")
CONTRACT_STATUS <- list(
  list(name = "Not delivered / terminated", value = dn[["No"]],     c = "#e34948"),
  list(name = "Partly delivered",           value = dn[["Partial"]], c = "#eda100"),
  list(name = "Delivered",                  value = dn[["Yes"]],     c = "#1baf7a"),
  list(name = "Status not stated",          value = dn[["NA"]],      c = "#c2c8d0"))

# ---- what the auditors flagged (each contract classified once) --------------
classify <- function(x) {
  x <- str_to_lower(x)
  dplyr::case_when(
    str_detect(x, "single-source|uncompetitive|cover bidding|no past experience") ~ "Single-source / uncompetitive",
    str_detect(x, "undelivered|not mobilis|not delivered|abandoned|stalled|delayed commencement") ~ "Undelivered / stalled",
    str_detect(x, "unsupported|without .*(invoice|guarantee|support)|irregular|verbal") ~ "Unsupported / irregular payment",
    str_detect(x, "overpriced|under-declar|duplicate") ~ "Overpriced / duplicated",
    str_detect(x, "not recovered|loss of funds|outstanding|shortfall") ~ "Funds not recovered / lost",
    str_detect(x, "interest|charges|cost|counterpart") ~ "Cost / interest claim",
    TRUE ~ "Other delivery concern")
}
fl_tab <- as.data.frame(table(classify(cf$issue_flagged)), stringsAsFactors = FALSE) |>
  arrange(desc(Freq))
FLAG_COUNTS <- unname(Map(function(a, b) list(a, b), fl_tab$Var1, as.integer(fl_tab$Freq)))

# ---- delivery status by year (stacked) --------------------------------------
yr <- sort(unique(as.integer(c_tbl$y)))
pick <- function(lv) sapply(yr, function(Y) sum(c_tbl$del[as.integer(c_tbl$y) == Y] == lv))
DELIVERY <- list(
  years  = as.character(yr),
  data   = list(Delivered = pick("Yes"), Partial = pick("Partial"),
                `Not delivered` = pick("No"), `Not stated` = pick("NA")),
  colors = list(Delivered = "#1baf7a", Partial = "#eda100",
                `Not delivered` = "#e34948", `Not stated` = "#c2c8d0"))

# ---- scalar counts the page prints ------------------------------------------
vK  <- valued |> filter(currency == "K")   |> summarise(n = n(), t = sum(amount, na.rm = TRUE))
vUS <- valued |> filter(currency == "US$") |> summarise(n = n(), t = sum(amount, na.rm = TRUE))
COUNTS <- list(
  contracts         = nrow(c_tbl),
  notFullyDelivered = sum(c_tbl$del %in% c("No", "Partial")),
  delivered         = dn[["Yes"]], partial = dn[["Partial"]],
  notDelivered      = dn[["No"]],  notStated = dn[["NA"]],
  singleSource      = sum(classify(cf$issue_flagged) == "Single-source / uncompetitive"),
  valued            = nrow(valued),
  valuedKbn         = round(vK$t  / 1e9, 1),
  valuedUSDbn       = round(vUS$t / 1e9, 2),
  valuedKn          = vK$n, valuedUSDn = vUS$n,
  cases             = nrow(cases))

# ---- MASTER contract table (the 182 valued UNION the 34 deep-verified) ------
# One row per contract line-item. Every "contract sum" from the reports is here;
# the 34 deep-verified cases carry supplier, delivery status and the flag, and
# are matched onto their valued row where the amount and page line up, else
# appended. A single `v` flag says whether the row was deep-verified.
vrow <- valued |>
  mutate(amt_raw = suppressWarnings(as.numeric(amount))) |>
  transmute(y = as.integer(financial_year),
            m = short_ministry(ministry), sup = "", del = "",
            amt_raw, cur = currency, amt = mapply(fmt_val, amt_raw, currency),
            flag = str_squish(context), p = as.integer(pdf_page), v = FALSE,
            matched = FALSE)

fl <- cf |>
  mutate(cv = suppressWarnings(as.numeric(contract_value)),
         ai = suppressWarnings(as.numeric(amount_at_issue)),
         y  = as.integer(financial_year), p = as.integer(source_pdf_page),
         usedrow = NA_integer_)

# match each deep-verified case to a valued row (same year + page + amount)
for (i in seq_len(nrow(fl))) {
  cand <- which(!vrow$matched & vrow$y == fl$y[i] & vrow$p == fl$p[i] &
                (abs(vrow$amt_raw - fl$cv[i]) < 1 | abs(vrow$amt_raw - fl$ai[i]) < 1))
  if (length(cand)) {
    k <- cand[1]
    vrow$matched[k] <- TRUE; vrow$v[k] <- TRUE
    vrow$m[k] <- short_ministry(fl$ministry_std[i])
    vrow$sup[k] <- fl$supplier[i]
    vrow$del[k] <- recode(coalesce(fl$delivered[i], "NA"),
                          Yes = "Yes", No = "No", Partial = "Partial", .default = "NA")
    vrow$flag[k] <- str_squish(fl$issue_flagged[i])
    fl$usedrow[i] <- k
  } else fl$usedrow[i] <- NA_integer_
}

# deep-verified cases with no matching valued row -> append as verified rows
extra <- fl |> filter(is.na(usedrow)) |>
  transmute(y, m = short_ministry(ministry_std), sup = supplier,
            del = recode(coalesce(delivered, "NA"),
                         Yes = "Yes", No = "No", Partial = "Partial", .default = "NA"),
            amt_raw = coalesce(cv, ai),
            cur = recode(coalesce(contract_currency, amount_currency),
                         USD = "US$", ZMW = "K", .default = "K"),
            amt = mapply(fmt_val, coalesce(cv, ai),
                         coalesce(contract_currency, amount_currency)),
            flag = str_squish(issue_flagged), p, v = TRUE)

master <- bind_rows(vrow |> select(-matched), extra) |>
  arrange(desc(v), desc(y), p) |>
  transmute(y = as.character(y), m, sup, amt, del,
            flag, p = paste0("p", p), v)
MASTER <- unname(as.list(as.data.frame(t(as.matrix(master)), stringsAsFactors = FALSE)))
# force the verified flag back to real booleans in the array (matrix made them chr)
MASTER <- lapply(seq_len(nrow(master)), function(i)
  list(master$y[i], master$m[i], master$sup[i], master$amt[i],
       master$del[i], master$flag[i], master$p[i], isTRUE(master$v[i])))

COUNTS$master         <- nrow(master)
COUNTS$masterVerified <- sum(master$v)

# ---- write ------------------------------------------------------------------
j <- function(x) toJSON(x, auto_unbox = TRUE, na = "string")
js <- paste0(
  "/* generated by R/10_dashboard_data.R - do not edit by hand.\n",
  "   Single source of truth for the contract table and every derived count. */\n",
  "const CONTRACTS = ",       toJSON(CONTRACTS, auto_unbox = TRUE), ";\n",
  "const CONTRACT_STATUS = ", j(CONTRACT_STATUS), ";\n",
  "const FLAG_COUNTS = ",     toJSON(FLAG_COUNTS, auto_unbox = TRUE), ";\n",
  "const DELIVERY = ",        j(DELIVERY), ";\n",
  "const MASTER = ",          toJSON(MASTER, auto_unbox = TRUE), ";\n",
  "const COUNTS = ",          j(COUNTS), ";\n")
writeLines(js, "site/dashboard_data.js")

cat("CONTRACTS:", nrow(c_tbl), "| not fully delivered:", COUNTS$notFullyDelivered, "\n")
cat("status donut:", paste(names(dn), dn, collapse = "  "), "\n")
cat("flag categories:\n"); print(fl_tab)
cat("valued:", COUNTS$valued, "| K", COUNTS$valuedKbn, "bn (", vK$n, ") | US$",
    COUNTS$valuedUSDbn, "bn (", vUS$n, ") | cases:", COUNTS$cases, "\n")
cat("MASTER rows:", COUNTS$master, "| verified:", COUNTS$masterVerified,
    "| matched onto valued:", sum(!is.na(fl$usedrow)),
    "| appended:", sum(is.na(fl$usedrow)), "\n")
