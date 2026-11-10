# =============================================================================
# 12_coverage_audit.R  -  Honest completeness check. Pull every company-like
# name out of the FULL report text (all pages, all 5 years) and compare against
# what we captured in supplier_index.csv. Reports a coverage ratio and a sample
# of names present in the reports but missing from our data.
# =============================================================================
suppressMessages({library(readr); library(dplyr); library(stringr)})
FF <- rawToChar(as.raw(12))

# company-name suffixes that reliably mark an organisation in these reports
SUF <- paste0("(Limited|Ltd|Company|Enterprises?|Investments?|Holdings|Services|",
              "Agency|Trading|Suppliers|Construction|Engineering|Contractors?|",
              "Pharmaceuticals?|Industries|Corporation|Consultants?|Consulting|",
              "General Dealers|Technologies|Ventures|Logistics|Motors|Farms?)")
NAME_RE <- paste0("\\b([A-Z][A-Za-z&'\\-]+(?:\\s+[A-Z][A-Za-z&'\\-]+){0,4}\\s+", SUF, ")\\b")

clean <- function(s) iconv(s, to = "UTF-8", sub = "")       # drop bad bytes

# pull candidate names from one year's body text (skip ToC: pages >= 11)
names_in_year <- function(y) {
  f <- sprintf("extraction/AG_%d_layout.txt", y)
  if (!file.exists(f)) return(character())
  raw <- readChar(f, file.info(f)$size, useBytes = TRUE)
  pages <- strsplit(raw, FF, fixed = TRUE, useBytes = TRUE)[[1]]
  if (length(pages) > 11) pages <- pages[11:length(pages)]
  body <- clean(paste(pages, collapse = "\n"))
  m <- regmatches(body, gregexpr(NAME_RE, body, perl = TRUE))[[1]]
  unique(str_squish(m))
}

all_names <- unique(unlist(lapply(2021:2025, names_in_year)))

# normalise for comparison (same rule family as the index builder)
nk <- function(x) x |> str_to_lower() |>
  str_replace_all("\\b(limited|ltd|co|company|incorporated|inc|plc|pte|pty)\\b", " ") |>
  str_replace_all("[^a-z0-9 ]", " ") |> str_squish()

idx <- read_csv("data_clean/supplier_index.csv", show_col_types = FALSE)
idx_keys <- unique(nk(idx$supplier))

found <- tibble(name = all_names, key = nk(all_names)) |>
  mutate(captured = key %in% idx_keys) |>
  filter(nchar(key) >= 3) |>
  distinct(key, .keep_all = TRUE)

n_total <- nrow(found); n_cap <- sum(found$captured)
cat("=== Supplier-name coverage audit ===\n")
cat("Distinct company-like names in the report text:", n_total, "\n")
cat("Of those, present in our supplier_index:", n_cap,
    sprintf("(%.0f%%)\n", 100 * n_cap / n_total))
cat("Missing from our data:", n_total - n_cap, "\n\n")

# spot-check the names the user named
for (q in c("zammsa", "mikalile")) {
  hit <- found |> filter(str_detect(key, q))
  cat(sprintf("  '%s' in text-derived names: %s | captured: %s\n", q,
      nrow(hit) > 0, ifelse(nrow(hit) > 0, all(hit$captured), NA)))
}

cat("\n--- 40 examples present in the reports but MISSING from our data ---\n")
miss <- found |> filter(!captured) |> arrange(name)
print(miss$name[seq_len(min(40, nrow(miss)))])

write_csv(found, "data_clean/coverage_audit.csv")
cat("\nFull list written to data_clean/coverage_audit.csv\n")
