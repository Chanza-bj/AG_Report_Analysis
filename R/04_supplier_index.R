# =============================================================================
# 04_supplier_index.R  -  Clean the auto-extracted supplier index into a
# usable list of company names that appear across the reports, with the years
# and PDF pages they appear on. This is an INDEX of named companies (appearances),
# not a verified contract register; contracts_flagged.csv is the valued layer.
#
# Input : data_raw/supplier_index_raw.csv  (user-supplied auto-extraction)
#         extraction/AG_<year>_text.txt    (for text verification; optional)
# Output: data_clean/supplier_index.csv
# =============================================================================
suppressMessages({library(readr); library(dplyr); library(tidyr); library(stringr)})

raw <- read_csv("data_raw/supplier_index_raw.csv", show_col_types = FALSE) |>
  rename(name = supplier_name_as_written, years = years_appearing,
         mentions = total_mentions, pages = year_and_pdf_pages) |>
  mutate(name = str_squish(name))

# ---- 1. Drop parsing artifacts (table headers, fragments, place/section names,
#         seed TYPES, generic construction/works fragments) --------------------
noise_lead <- str_c("^(Amount|Assets|Acronyms|Background|Date|Qty|Personnel|",
  "Selected|Same|Seed Suppliers|Seed Seed|Suppliers|Supplies|Supply|Traders|",
  "Projects?|Phase|Weeks?|Other|Others|Infrastructure|Delivered|Overpaid|",
  "Uncontracted|Undistributed|Beneficiaries|Bidding|Required Bid|Tax Registration|",
  "ZPPA|Districts?|Northern|Southern|Eastern|Western|Central|Lusaka|Muchinga|",
  "Luapula|Copperbelt|North Western|Incomplete|Commenc|Washed Away|Stalled|",
  "Revised|Completion|Funding|Existing|Related|Maintenance|Refurbishment|Nursing|",
  "Biomedical|Mechanical|Electrical|Fire Services|Health Post|Health Sciences|",
  "Hospital|General Hospital|School|Secondary|High School|Bus Station|Sanitation|",
  "Drainage|Painting|Roofing|Wall Fence|Staircases|First Floor|Prefabricated|",
  "Manually Drilled|Water Mechanisation|Chancery Construction|Palaces|Houses|",
  "Lodges?|Country Lodge|Investment$|Investments$|Limited|Construction$|Engineering$|",
  "Enterprises? Ltd$|Years|July|June|January|February|March|December|October|",
  "Capacity Building|Builders|Mining Limited$|Grain|Group Ltd$|III |Km |Lot |Lines|",
  "Society Limited$|Supply|Corporation Ltd$|Company Zambia Ltd$|Electrical|Date Balance)")
# seed TYPES (not companies): a crop word immediately before "Seed"
seed_type <- str_c("(Soya|Sunflower|Spinach|Pumpkin|Rice|Groundnut|Forage|Pasture|",
  "Excess Beans?|Poor|Certified|Beneficiaries|Uncontracted|Undistributed|Kabulangeti|",
  "Mbereshi|Masaiti|Ferts?|Pannar Seed$|Soya Beans?|Qty Price|Selected Seed|Seed Seed|",
  "Groundnut|Districts Farmers|Stylosanthesis|Dlroba|Kekeli|Certification Institute|",
  "Beneficiaries Seed)")
drop_contains <- "(Amount Station|Seed Suppliers No|Qty Price Total|Programme Sub-Programme|Bidding Companies|Required Bid|Tax Registration|ZPPA Registration|Delivered Goods|Development Trust|Date Balance Season)"

# purely-generic names (a generic stem + a company suffix, nothing distinctive)
generic <- str_c("^(General Dealers|Investments?|Solutions|Supply Company|Suppliers|",
  "Supplies|Supply|Traders|Trading|Grain|Cropping|Society|Houses|Lodges?|Marketing|",
  "Monitors|Lines|Builders|Maintenance|Electrical|Mining|Logistics|Veterinary|Secondary|",
  "Enterprises|Corporation|Group|Company Zambia|Engineering Company|Capacity Building|",
  "Enhanced Smallholder|Correctional Industries|Hand|Multi-Industry|Managed Solutions|",
  "Star Agency Constructors|Supply Ltd|Society|Investment|School Investments|",
  "Phase II Investments|Regional Investment|Western Investment|Manually Drilled Investment|",
  "Maternity Annex Investments|Spring Creek Investment|Lindham Investment|Floyven Investment)",
  "( Limited| Ltd| Ltd\\.|$)")

clean <- raw |>
  filter(!str_detect(name, regex(noise_lead, ignore_case = TRUE)),
         !str_detect(name, regex(paste0("\\b", seed_type, "\\b.*Seed$"), ignore_case = TRUE)),
         !str_detect(name, regex(drop_contains, ignore_case = TRUE)),
         !str_detect(name, regex(generic, ignore_case = TRUE)),
         str_count(name, "\\w+") <= 8,                 # drop long header-like strings
         str_detect(name, "[A-Za-z]"))

# ---- 2. Merge near-duplicate names (Ltd/Limited/Co variants, spacing) --------
norm_key <- function(x) x |>
  str_to_lower() |>
  str_replace_all("\\b(limited|ltd|ltd\\.|co\\.|co|company|incorporated|inc|plc|pte|pty)\\b", " ") |>
  str_replace_all("[^a-z0-9 ]", " ") |> str_squish()

merged <- clean |>
  mutate(key = norm_key(name)) |>
  filter(key != "") |>
  group_by(key) |>
  summarise(
    supplier = name[which.max(nchar(name))],           # canonical = longest variant
    years_appearing = paste(sort(unique(unlist(str_split(paste(years, collapse=";"), ";")))), collapse=";"),
    n_years = length(unique(unlist(str_split(paste(years, collapse=";"), ";")))),
    total_mentions = sum(mentions),
    pages = paste(unique(pages), collapse=" | "),
    .groups = "drop") |>
  select(supplier, years_appearing, n_years, total_mentions, pages) |>
  arrange(desc(n_years), desc(total_mentions), supplier)

# ---- 3. Text-verify each supplier appears in a claimed year's report ---------
texts <- list()
for (yr in c("2021","2022","2023","2024","2025")) {
  fp <- file.path("extraction", paste0("AG_", yr, "_text.txt"))
  if (!file.exists(fp)) fp <- file.path("extraction", paste0("AG_", yr, "_layout.txt"))
  texts[[yr]] <- if (file.exists(fp)) paste(readLines(fp, warn = FALSE), collapse = " ") else ""
}
verify_one <- function(supplier, years) {
  ys <- unlist(str_split(years, ";"))
  any(vapply(ys, function(y) {
    t <- texts[[y]]; if (is.null(t) || t == "") return(NA)
    str_detect(t, fixed(supplier, ignore_case = TRUE))
  }, logical(1)), na.rm = TRUE)
}
merged <- merged |>
  rowwise() |>
  mutate(verified_in_text = verify_one(supplier, years_appearing)) |>
  ungroup()

write_csv(merged, "data_clean/supplier_index.csv")

cat("Raw rows:", nrow(raw), "| after cleaning:", nrow(clean),
    "| after dedupe:", nrow(merged), "\n")
cat("Verified present in report text:", sum(merged$verified_in_text), "/", nrow(merged), "\n")
cat("Appearing in more than one year:", sum(merged$n_years > 1), "\n\n")
cat("--- Suppliers named in 2 or more reports (text-verified) ---\n")
print(merged |> filter(n_years > 1, verified_in_text) |>
      select(supplier, years_appearing, total_mentions), n = 40)
# per-year distinct supplier counts
py <- merged |> filter(verified_in_text) |>
  separate_rows(years_appearing, sep=";") |> count(years_appearing, name="n_suppliers")
cat("\n--- Distinct verified suppliers named per report ---\n"); print(py)
