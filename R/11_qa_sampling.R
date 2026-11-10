# =============================================================================
# 11_qa_sampling.R  -  Sampling QA on the three bulk layers that were auto- or
# bulk-extracted (not every row deep-checked): the 182 valued contracts, the
# 89 supplier cases, and the verified supplier-name index. For a random sample
# from each, re-open the cited page in the pdftotext -layout text and confirm
# the amount (valued) or the supplier name (cases, index) is actually there.
# Reports a pass rate = an honest estimate of how reliable each layer is.
#
# Output: data_clean/qa_sample_checks.csv  + a printed summary.
# =============================================================================
suppressMessages({library(readr); library(dplyr); library(stringr)})
clean <- function(x) str_trunc(iconv(as.character(x), to = "UTF-8", sub = ""), 60)
set.seed(42)
FF <- rawToChar(as.raw(12))

# page text, byte-safe, cached per year ---------------------------------------
load_pages <- function(y) {
  f <- sprintf("extraction/AG_%d_layout.txt", y)
  if (!file.exists(f)) return(character())
  raw <- readChar(f, file.info(f)$size, useBytes = TRUE)
  strsplit(raw, FF, fixed = TRUE, useBytes = TRUE)[[1]]
}
PG <- setNames(lapply(2021:2025, load_pages), as.character(2021:2025))
page_txt <- function(y, p) {
  pg <- PG[[as.character(y)]]; p <- suppressWarnings(as.integer(p))
  if (length(pg) && !is.na(p) && p >= 1 && p <= length(pg)) pg[p] else ""
}
has_str  <- function(y, p, s) grepl(s, page_txt(y, p), fixed = TRUE, useBytes = TRUE)
has_ci   <- function(y, p, s) grepl(s, page_txt(y, p), ignore.case = TRUE, useBytes = TRUE)

# distinctive supplier token (drop generic company words) ---------------------
generic <- c("limited","ltd","company","co","the","and","investments","enterprises",
             "general","dealers","services","construction","engineering","international",
             "group","holdings","zambia","trading","supplies","industries","plc")
token <- function(name) {
  w <- str_split(str_to_lower(str_replace_all(name, "[^A-Za-z ]", " ")), "\\s+")[[1]]
  w <- w[nchar(w) >= 4 & !w %in% generic]
  if (length(w)) w[1] else NA_character_
}

checks <- list()

# ---- 1. valued contracts (182): amount present on cited page ----------------
v <- read_csv("data_raw/contracts_valued_all.csv", show_col_types = FALSE)
vs <- v[sample(nrow(v), 30), ]
amt_commas <- function(a) formatC(floor(a), format = "f", digits = 0, big.mark = ",")
vs$target <- amt_commas(vs$amount)
vs$found  <- mapply(has_str, vs$financial_year, vs$pdf_page, vs$target)
checks$valued <- tibble(layer = "valued(182)", year = vs$financial_year,
  page = vs$pdf_page, target = paste0(vs$currency, vs$target),
  found = vs$found, detail = clean(vs$context))

# ---- 2. supplier cases (89): named supplier on cited page -------------------
cs <- read_csv("data_clean/supplier_cases.csv", show_col_types = FALSE) |>
  filter(named) |>                                    # skip "not named in extract"
  mutate(tok = sapply(supplier, token)) |>
  filter(!is.na(tok))
cs <- cs[sample(nrow(cs), 20), ]
cs$found <- mapply(has_ci, cs$report_year, cs$pdf_page, cs$tok)
checks$cases <- tibble(layer = "cases(89)", year = cs$report_year,
  page = cs$pdf_page, target = cs$supplier, found = cs$found,
  detail = clean(cs$item))

# ---- 3. supplier index (verified): name on any of its cited pages -----------
ix <- read_csv("data_clean/supplier_index.csv", show_col_types = FALSE) |>
  filter(verified_in_text) |> mutate(tok = sapply(supplier, token)) |> filter(!is.na(tok))
ix <- ix[sample(nrow(ix), 25), ]
# parse "2021: pdf p308,309; 2022: pdf p97" -> (year, page) pairs, test any
check_index <- function(tok, pages) {
  grps <- str_match_all(pages, "(20\\d\\d)\\s*:\\s*pdf\\s*p?([0-9,\\s]+)")[[1]]
  if (!nrow(grps)) return(NA)
  for (g in seq_len(nrow(grps))) {
    y  <- as.integer(grps[g, 2])
    ps <- as.integer(str_trim(str_split(grps[g, 3], ",")[[1]]))
    for (p in ps[!is.na(ps)]) if (has_ci(y, p, tok)) return(TRUE)
  }
  FALSE
}
ix$found <- mapply(check_index, ix$tok, ix$pages)
checks$index <- tibble(layer = "index(454)", year = NA, page = NA,
  target = ix$supplier, found = ix$found, detail = clean(ix$pages))

# ---- report -----------------------------------------------------------------
all <- bind_rows(checks)
write_csv(all, "data_clean/qa_sample_checks.csv")

summ <- all |> group_by(layer) |>
  summarise(sampled = n(), passed = sum(found, na.rm = TRUE),
            unresolved = sum(is.na(found)),
            pass_rate = round(100 * sum(found, na.rm = TRUE) / n()))
cat("\n=== QA sampling summary (seed 42) ===\n"); print(summ, n = Inf)
cat("\n--- rows that did NOT match (for manual follow-up) ---\n")
print(all |> filter(!found | is.na(found)) |> select(layer, year, page, target, detail), n = Inf)
