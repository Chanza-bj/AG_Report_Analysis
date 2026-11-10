# =============================================================================
# 04_supplier_index.R  -  Build an index of ORGANISATIONS named in the reports
# (suppliers, contractors, vendors, agencies and state firms), directly from the
# pdftotext -layout text of all five reports. This is an INDEX of names that
# appear, with the years and PDF pages; it is not a verified contract register
# (contracts_flagged.csv is the deep-verified layer).
#
# Rebuilt to raise coverage: extracts company-suffix names across the body text
# AND a curated set of acronym / state-firm names (ZAMMSA, NAPSA, Nitrogen
# Chemicals, ...) that a suffix-only rule misses. Coverage is measured by
# R/12_coverage_audit.R.
#
# Input : extraction/AG_<year>_layout.txt
# Output: data_clean/supplier_index.csv
# =============================================================================
suppressMessages({library(readr); library(dplyr); library(tidyr); library(stringr)})
FF <- rawToChar(as.raw(12))
clean_bytes <- function(s) iconv(s, to = "UTF-8", sub = "")

# ---- load each year's pages (byte-safe), skip the front matter / ToC ---------
YEARS <- 2021:2025
PAGES <- list()
for (y in YEARS) {
  f <- sprintf("extraction/AG_%d_layout.txt", y)
  if (!file.exists(f)) next
  raw <- readChar(f, file.info(f)$size, useBytes = TRUE)
  pg  <- strsplit(raw, FF, fixed = TRUE, useBytes = TRUE)[[1]]
  if (length(pg) > 11) pg <- pg[11:length(pg)]        # drop cover + contents
  PAGES[[as.character(y)]] <- clean_bytes(pg)
}
BODY <- sapply(PAGES, function(p) paste(p, collapse = "\n"))

# ---- 1. company-suffix names -------------------------------------------------
SUF <- paste0("(Limited|Ltd|Company|Enterprises?|Investments?|Holdings|Services|",
  "Agency|Trading|Suppliers|Construction|Engineering|Contractors?|Pharmaceuticals?|",
  "Industries|Corporation|Consultants?|Consulting|Technologies|Ventures|Logistics|",
  "Motors|Farms?|Mills?|Milling|Agro|Chemicals|Hardware|Stores|Petroleum|General Dealers)")
NAME_RE <- paste0("\\b([A-Z][A-Za-z0-9&'.-]+(?:\\s+[A-Z0-9][A-Za-z0-9&'.-]+){0,5}\\s+", SUF, ")\\b")

suffix_names <- unique(unlist(lapply(BODY, function(b)
  str_squish(regmatches(b, gregexpr(NAME_RE, b, perl = TRUE))[[1]]))))

# ---- 2. curated acronym / state-firm names (suffix-only rule misses these) ---
CURATED <- c(
  "ZAMMSA","Zambia Medicines and Medical Supplies Agency","NAPSA","ZPPA","ZESCO",
  "ZAMTEL","Zambia Railways","Zampost","INDENI","TAZAMA","ZSIC","ZCCM-IH","ZCCM",
  "Nitrogen Chemicals of Zambia","Nitrogen Chemicals","ZAFFICO","Food Reserve Agency",
  "Road Development Agency","Zambia National Building Society","Development Bank of Zambia",
  "ZNBC","Mukuba","Kagem","Mopani","Konkola","Zambeef","Zambian Breweries","Trade Kings",
  "Zambia Seed Company","Zamseed","National Road Fund Agency","Zambia Correctional Service",
  "Zambia Air Force","Zambia National Service","Water Resources Management Authority",
  "Rural Electrification Authority","Zambia Information and Communications Technology Authority",
  "Public Service Pensions Fund","Workers Compensation Fund","Local Authorities Superannuation Fund")
curated_present <- CURATED[sapply(CURATED, function(x) any(sapply(BODY, grepl, pattern = x, fixed = TRUE)))]

cand <- unique(c(suffix_names, curated_present))

# ---- 3. drop fragments and purely-generic names ------------------------------
# Only true sentence-starts / table words that are never part of a company name.
# Region, sector and month words are NOT dropped (real firms start with them,
# e.g. "Southern Africa Ferro Alloys", "Eastern Golden Wheel Zambia").
noise_lead <- regex(str_c("^(Amount|Amounts|Although|Assets|Acronyms|Background|Date|Qty|",
  "Personnel|Selected|Same|Other|Others|These|This|That|The|Was|Were|Being|Audit|Report|",
  "Balance|Opening|Closing|Note|Figure|Annex|Total|Table|Various|Infrastructure|Delivered|",
  "Overpaid|Required|Related|Existing|Revised|Completion|Funding|Incomplete|Commenc|Washed|",
  "Stalled|Manually|Programme|Sub-Programme|Lot|Km|Under|Bidding|Phase|Weeks?|Staircases|",
  "First Floor|Prefabricated|Wall Fence|Administaration|Activities)\\b"), ignore_case = FALSE)

# single distinctive token required: drop names whose key is one generic word
GEN1 <- c("zambia","services","service","traders","trading","suppliers","supplies","supply",
  "investment","investments","enterprises","enterprise","construction","engineering","limited",
  "general","holdings","company","group","agency","corporation","contractors","industries",
  "logistics","ventures","motors","hand","associates","solutions","technologies")
nk <- function(x) x |> str_to_lower() |>
  str_replace_all("\\b(limited|ltd|ltd\\.|co\\.|co|company|incorporated|inc|plc|pte|pty)\\b"," ") |>
  str_replace_all("[^a-z0-9 ]"," ") |> str_squish()

# strip leading date / number / "No." junk tokens ("June 2022. Habitech Ltd" -> "Habitech Ltd")
MONTHS <- "January|February|March|April|May|June|July|August|September|October|November|December"
strip_lead <- function(x) {
  repeat {
    x2 <- sub(paste0("^(", MONTHS, "|No\\.?|[0-9]+\\.?)\\s+"), "", x, perl = TRUE, ignore.case = TRUE)
    if (identical(x2, x)) break; x <- x2
  }
  str_squish(x)
}
cand <- unique(vapply(cand, strip_lead, character(1)))
cand <- cand[!str_detect(cand, noise_lead)]
cand <- cand[str_count(cand, "\\w+") <= 8 & nchar(cand) >= 4]
cand <- cand[!str_detect(cand, "\\b(19|20)\\d{2}\\b")]       # drop names carrying a year
cand <- cand[!str_detect(cand, "\\bNo\\.")]                  # drop table "No." refs

# keep a name only if it has a distinctive token (not a pure sector/generic phrase);
# curated agency names are always kept even when their words are all generic.
GENERIC <- c("health","services","service","medical","supplies","supply","general","stores","store",
  "public","social","technical","support","hospital","primary","central","pharmaceutical","pharmaceuticals",
  "insurance","company","agency","national","local","government","district","districts","provincial",
  "correctional","defence","safety","geriatric","imaging","dental","nursing","maternity","surgical",
  "clinical","goods","works","project","projects","classroom","blocks","dam","chief","export","import",
  "limited","ltd","holdings","group","corporation","contractors","contractor","logistics","trading",
  "traders","suppliers","enterprises","enterprise","investment","investments","construction","engineering",
  "management","development","dealers","fund","reserve","road","building","society","authority","financial",
  "bank","trust","union","cooperative","station","office","department","ministry","programme","of","and",
  "the","zambia","zambian","industries","technologies","ventures","petroleum","chemicals","hardware",
  "consultants","consulting","motors","mills","milling","agro","farms","farm")
has_distinct <- function(x) {
  w <- str_split(str_to_lower(str_replace_all(x, "[^A-Za-z ]", " ")), "\\s+")[[1]]
  w <- w[nchar(w) >= 3]
  any(!(w %in% GENERIC))
}
cand <- cand[vapply(cand, has_distinct, logical(1)) | cand %in% curated_present]
cand <- cand[nk(cand) != ""]

# ---- 4. years, pages and mention counts for each name ------------------------
# Match against squished pages: the -layout text has column gaps (multiple
# spaces), but extracted names are squished, so fixed matching needs squished text.
PAGES_SQ <- lapply(PAGES, str_squish)
occ <- function(name) {
  yrs <- character(); pgtxt <- character(); total <- 0L
  for (y in names(PAGES_SQ)) {
    pv <- PAGES_SQ[[y]]
    hits <- which(vapply(pv, function(p) grepl(name, p, fixed = TRUE), logical(1)))
    if (length(hits)) {
      yrs <- c(yrs, y)
      total <- total + sum(vapply(pv[hits],
        function(p) lengths(gregexpr(name, p, fixed = TRUE)), integer(1)))
      pgtxt <- c(pgtxt, sprintf("%s: pdf p%s", y, paste(hits + 10, collapse = ",")))
    }
  }
  list(years = paste(yrs, collapse = ";"), n_years = length(yrs),
       mentions = total, pages = paste(pgtxt, collapse = "; "))
}

rows <- lapply(cand, occ)
idx <- tibble(
  supplier        = cand,
  years_appearing = sapply(rows, `[[`, "years"),
  n_years         = sapply(rows, `[[`, "n_years"),
  total_mentions  = sapply(rows, `[[`, "mentions"),
  pages           = sapply(rows, `[[`, "pages")) |>
  filter(n_years >= 1)

# ---- 5. merge Ltd/Limited variants (canonical = longest) ---------------------
idx <- idx |>
  mutate(key = nk(supplier)) |>
  group_by(key) |>
  summarise(
    supplier        = supplier[which.max(nchar(supplier))],
    years_appearing = paste(sort(unique(unlist(str_split(paste(years_appearing, collapse=";"), ";")))), collapse=";"),
    n_years         = length(unique(unlist(str_split(paste(years_appearing, collapse=";"), ";")))),
    total_mentions  = sum(total_mentions),
    pages           = paste(unique(pages), collapse = "; "),
    .groups = "drop") |>
  mutate(verified_in_text = TRUE) |>            # text-derived: present by construction
  select(supplier, years_appearing, n_years, total_mentions, pages, verified_in_text) |>
  arrange(desc(n_years), desc(total_mentions), supplier)

write_csv(idx, "data_clean/supplier_index.csv")

cat("Organisations indexed from report text:", nrow(idx), "\n")
cat("Named in more than one report:", sum(idx$n_years > 1), "\n")
cat("Curated agency/SOE names found present:", length(curated_present), "\n")
for (q in c("ZAMMSA","NAPSA","Nitrogen Chemicals","Trade Kings","Zambia Seed"))
  cat(sprintf("  '%s' now in index: %s\n", q, any(grepl(q, idx$supplier, ignore.case = TRUE))))
