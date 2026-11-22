# =============================================================================
# Auditor General of Zambia - Reports on the Accounts of the Republic
# Financial years ended 31 December 2021 - 2025
# Reproducible analysis: value of audit findings and ministry recurrence
#
# Input  : data_raw/ag_trend_tables_asprinted.csv   (faithful transcription)
#          data_clean/unresolved_paragraphs.csv      (one row per findings paragraph)
#          data_clean/report_metadata.csv
# Output : data_clean/findings_by_category_tidy.csv  (tidy long, one row per obs)
#          data_clean/reconciliation_checks.csv
#          data_clean/ministry_recurrence.csv
#          output/*.png  (charts), output/*.csv (summary tables)
#
# The tidyverse meta-package is not installed on this machine, so the component
# packages are loaded individually. The code is standard tidyverse.
# =============================================================================

library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(forcats)
library(ggplot2)
library(scales)

# ---- Paths (relative to project root; run from the repo root) ---------------
raw_dir   <- "data_raw"
clean_dir <- "data_clean"
out_dir   <- "output"
dir.create(out_dir, showWarnings = FALSE)

# A plain, print-friendly theme (no decorative elements)
theme_ag <- theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(),
        plot.title.position = "plot",
        plot.caption = element_text(colour = "grey40", hjust = 0))
wrapcap <- function(x) str_wrap(x, width = 95)   # keep captions inside the canvas
SRC <- "Source: Office of the Auditor General, Reports on the Accounts of the Republic (Zambia)."

# =============================================================================
# 1. CATEGORY VALUES  -- read the faithful transcription of the two trend tables
# =============================================================================
asprinted <- read_csv(file.path(raw_dir, "ag_trend_tables_asprinted.csv"),
                      show_col_types = FALSE)

# Separate the printed TOTAL rows (row_no == 99) from the category rows
totals_printed <- asprinted %>% filter(row_no == 99)
cats_raw       <- asprinted %>% filter(row_no != 99)

# Each report's two amount columns map to two financial years:
#   2022 report -> prior = FY2021, current = FY2022
#   2023 report -> prior = FY2022, current = FY2023
col_year <- tibble(
  report_year = c(2022L, 2022L, 2023L, 2023L),
  which_col   = c("amt_prior_kwacha","amt_current_kwacha",
                  "amt_prior_kwacha","amt_current_kwacha"),
  financial_year = c(2021L, 2022L, 2022L, 2023L)
)

# Pivot to tidy long form: one row per (report_year, category, financial_year)
findings_long <- cats_raw %>%
  select(report_year, row_no, category_printed,
         amt_prior_kwacha, amt_current_kwacha, source_pdf_page, printed_page) %>%
  pivot_longer(c(amt_prior_kwacha, amt_current_kwacha),
               names_to = "which_col", values_to = "amount_kwacha") %>%
  left_join(col_year, by = c("report_year","which_col")) %>%
  mutate(amount_kwacha = as.numeric(amount_kwacha))  # "-" already blank -> NA

# ---- Standardise category labels so OCR/wording variants reconcile ----------
# The printed labels differ slightly between the two reports (OCR and edits).
# category_std is a cleaned key used only for matching; category_printed is kept.
clean_key <- function(x) {
  x %>%
    str_to_lower() %>%
    str_replace_all("tranfer", "transfer") %>%
    str_replace_all("withdraw\\b", "withdrawal") %>%
    str_replace_all("unaquitted|unacquited", "unacquitted") %>%
    str_replace_all("farmers inputs", "farming inputs") %>%
    str_replace_all("distribution of inputs", "distribution of farming inputs") %>%
    str_replace_all("[^a-z0-9 ]", " ") %>%
    str_squish() %>%
    # "Unacquitted Inputs" and "Unacquitted Farming Inputs" are the same category
    str_replace_all("^unacquitted inputs$", "unacquitted farming inputs")
}
findings_long <- findings_long %>%
  mutate(category_std = clean_key(category_printed))

# Write the tidy dataset (the deliverable the charts are rebuilt from)
findings_out <- findings_long %>%
  arrange(report_year, financial_year, row_no) %>%
  select(report_year, financial_year, row_no, category_printed, category_std,
         amount_kwacha, source_pdf_page, printed_page)
write_csv(findings_out, file.path(clean_dir, "findings_by_category_tidy.csv"))

# =============================================================================
# 2. INTERNAL CHECKS  -- "do the components add up?"
# =============================================================================
checks <- list()

# (a) Recompute each report's column totals from the categories and compare with
#     the printed Total row.
computed_totals <- findings_long %>%
  group_by(report_year, financial_year) %>%
  summarise(computed_total = sum(amount_kwacha, na.rm = TRUE), .groups = "drop")

printed_totals_long <- totals_printed %>%
  transmute(report_year,
            FY_prior   = amt_prior_kwacha,
            FY_current = amt_current_kwacha) %>%
  pivot_longer(c(FY_prior, FY_current), values_to = "printed_total") %>%
  mutate(financial_year = case_when(
    report_year == 2022 & name == "FY_prior"   ~ 2021L,
    report_year == 2022 & name == "FY_current" ~ 2022L,
    report_year == 2023 & name == "FY_prior"   ~ 2022L,
    report_year == 2023 & name == "FY_current" ~ 2023L)) %>%
  select(report_year, financial_year, printed_total)

total_check <- computed_totals %>%
  left_join(printed_totals_long, by = c("report_year","financial_year")) %>%
  mutate(difference = computed_total - printed_total,
         matches = difference == 0)
checks$total_check <- total_check

# (b) Cross-report check of the overlapping FY2022 column (2022 report current
#     vs 2023 report prior), matched on the cleaned category key.
fy2022_22 <- findings_long %>% filter(report_year==2022, financial_year==2022) %>%
  select(category_std, amount_2022rep = amount_kwacha)
fy2022_23 <- findings_long %>% filter(report_year==2023, financial_year==2022) %>%
  select(category_std, amount_2023rep = amount_kwacha)
fy2022_recon <- full_join(fy2022_22, fy2022_23, by = "category_std") %>%
  mutate(across(starts_with("amount"), ~replace_na(., 0)),
         diff = amount_2022rep - amount_2023rep) %>%
  arrange(desc(abs(diff)))
checks$fy2022_recon <- fy2022_recon

# (c) Do the printed variance figures equal (current - prior)? Spot internal maths.
var_check <- cats_raw %>%
  mutate(amt_prior = as.numeric(amt_prior_kwacha),
         amt_curr  = as.numeric(amt_current_kwacha),
         printed_var = as.numeric(printed_variance),
         computed_var = coalesce(amt_curr,0) - coalesce(amt_prior,0),
         var_matches = printed_var == computed_var) %>%
  select(report_year, row_no, category_printed, amt_prior, amt_curr,
         printed_var, computed_var, var_matches)
checks$variance_check <- var_check

# Save a compact reconciliation file
recon_summary <- bind_rows(
  total_check %>% transmute(check="column_total_vs_printed",
                            key=paste0("report",report_year,"_FY",financial_year),
                            value_a=computed_total, value_b=printed_total,
                            difference, ok=matches),
  fy2022_recon %>% transmute(check="FY2022_cross_report",
                             key=category_std, value_a=amount_2022rep,
                             value_b=amount_2023rep, difference=diff, ok=(diff==0))
)
write_csv(recon_summary, file.path(clean_dir, "reconciliation_checks.csv"))

cat("\n--- CHECK (a): computed column totals vs printed totals ---\n")
print(total_check)
cat("\n--- CHECK (b): FY2022 categories that differ between the 2022 and 2023 reports ---\n")
print(fy2022_recon %>% filter(diff != 0))
cat(sprintf("\nVariance arithmetic matches printed in %d of %d category rows.\n",
            sum(var_check$var_matches, na.rm=TRUE), nrow(var_check)))

# =============================================================================
# 3. HEADLINE TREND  -- reported value of findings, with and without tax arrears
# =============================================================================
TAX_ARREARS <- "failure to collect tax arrears"

# Preferred single series per financial year:
#   FY2021 from 2022 report; FY2022 from 2023 report (reconciled); FY2023 from 2023 report.
pick <- tribble(
  ~financial_year, ~report_year,
  2021L,           2022L,
  2022L,           2023L,
  2023L,           2023L)

series <- findings_long %>%
  inner_join(pick, by = c("financial_year","report_year")) %>%
  mutate(is_tax_arrears = category_std == TAX_ARREARS)

trend_totals <- series %>%
  group_by(financial_year) %>%
  summarise(total_all          = sum(amount_kwacha, na.rm = TRUE),
            tax_arrears        = sum(amount_kwacha[is_tax_arrears], na.rm = TRUE),
            total_excl_arrears = sum(amount_kwacha[!is_tax_arrears], na.rm = TRUE),
            .groups = "drop")
write_csv(trend_totals, file.path(out_dir, "table_trend_totals.csv"))
cat("\n--- Reported value of findings by financial year (Kwacha) ---\n")
print(trend_totals)

# Chart 1: total vs total-excluding-tax-arrears (Kwacha, billions)
trend_plot <- trend_totals %>%
  select(financial_year, total_all, total_excl_arrears) %>%
  pivot_longer(-financial_year, names_to = "measure", values_to = "kwacha") %>%
  mutate(measure = recode(measure,
            total_all = "All query categories",
            total_excl_arrears = "Excluding Failure to Collect Tax Arrears"))

p1 <- ggplot(trend_plot, aes(factor(financial_year), kwacha/1e9, fill = measure)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.65) +
  geom_text(aes(label = comma(kwacha/1e9, accuracy = 0.1)),
            position = position_dodge(width = 0.7), vjust = -0.4, size = 3.2) +
  scale_fill_manual(values = c("All query categories" = "#1b4965",
                               "Excluding Failure to Collect Tax Arrears" = "#cae9ff")) +
  labs(title = "Reported value of audit findings, Zambia",
       subtitle = "Query-category totals, financial years 2021-2023 (comparable table only)",
       x = NULL, y = "Kwacha (billions)", fill = NULL,
       caption = wrapcap(paste(SRC, "Comparable category table appears only in the 2022 and 2023 reports."))) +
  theme_ag + theme(legend.position = "top")
ggsave(file.path(out_dir, "chart1_trend_totals.png"), p1, width = 8, height = 5, dpi = 150)

# Chart 2: top categories by value, FY2023 (excluding the dominant tax-arrears line)
top_cats_2023 <- series %>%
  filter(financial_year == 2023, !is_tax_arrears, !is.na(amount_kwacha), amount_kwacha > 0) %>%
  slice_max(amount_kwacha, n = 10) %>%
  mutate(category_printed = fct_reorder(category_printed, amount_kwacha))
write_csv(series %>% filter(financial_year==2023) %>%
            select(category_printed, amount_kwacha, source_pdf_page),
          file.path(out_dir, "table_fy2023_categories.csv"))

p2 <- ggplot(top_cats_2023, aes(amount_kwacha/1e6, category_printed)) +
  geom_col(fill = "#1b4965") +
  geom_text(aes(label = comma(amount_kwacha/1e6, accuracy = 1)), hjust = -0.1, size = 3) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Largest query categories by value, FY2023",
       subtitle = "Excludes Failure to Collect Tax Arrears (K66.99 billion, ZRA-sourced)",
       x = "Kwacha (millions)", y = NULL, caption = wrapcap(SRC)) +
  theme_ag
ggsave(file.path(out_dir, "chart2_top_categories_2023.png"), p2, width = 8, height = 5, dpi = 150)

# =============================================================================
# 4. MINISTRY RECURRENCE  -- which entities recur across the five reports
# =============================================================================
paras <- read_csv(file.path(clean_dir, "unresolved_paragraphs.csv"),
                  show_col_types = FALSE)

# Paragraphs per report (volume of unresolved findings) - comparable across 5 years
paras_per_year <- paras %>% count(financial_year, name = "n_paragraphs")
write_csv(paras_per_year, file.path(out_dir, "table_paragraphs_per_year.csv"))

# Recurrence by standardised ministry/portfolio
ministry_recurrence <- paras %>%
  group_by(ministry_std) %>%
  summarise(years_present   = n_distinct(financial_year),
            total_paragraphs = n(),
            years_list = paste(sort(unique(financial_year)), collapse = ", "),
            .groups = "drop") %>%
  arrange(desc(years_present), desc(total_paragraphs))
write_csv(ministry_recurrence, file.path(clean_dir, "ministry_recurrence.csv"))
cat("\n--- Ministry recurrence across the five reports ---\n")
print(ministry_recurrence, n = 40)

# Chart 3: ministries present in all five years, by total paragraphs
recur_plot <- ministry_recurrence %>%
  filter(years_present == 5) %>%
  mutate(ministry_std = fct_reorder(ministry_std, total_paragraphs))

p3 <- ggplot(recur_plot, aes(total_paragraphs, ministry_std)) +
  geom_col(fill = "#1b4965") +
  geom_text(aes(label = total_paragraphs), hjust = -0.3, size = 3.2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "Portfolios flagged in every report, 2021-2025",
       subtitle = "Total unresolved-findings paragraphs over the five years",
       x = "Number of paragraphs (2021-2025)", y = NULL,
       caption = wrapcap(paste(SRC, "Counts of Table-of-Contents paragraphs; a paragraph is not a monetary total."))) +
  theme_ag
ggsave(file.path(out_dir, "chart3_ministry_recurrence.png"), p3, width = 8, height = 5.5, dpi = 150)

# Chart 4: paragraphs per report year (volume trend, all five years)
p4 <- ggplot(paras_per_year, aes(factor(financial_year), n_paragraphs)) +
  geom_col(fill = "#1b4965", width = 0.65) +
  geom_text(aes(label = n_paragraphs), vjust = -0.4, size = 3.5) +
  labs(title = "Number of unresolved-findings paragraphs per report",
       subtitle = "Financial years 2021-2025",
       x = NULL, y = "Paragraphs (Table of Contents)",
       caption = wrapcap(SRC)) +
  theme_ag
ggsave(file.path(out_dir, "chart4_paragraphs_per_year.png"), p4, width = 7, height = 4.5, dpi = 150)

# Heat-style matrix: ministry x year paragraph counts
ministry_year <- paras %>%
  count(ministry_std, financial_year) %>%
  pivot_wider(names_from = financial_year, values_from = n, values_fill = 0) %>%
  arrange(desc(rowSums(across(where(is.numeric)))))
write_csv(ministry_year, file.path(out_dir, "table_ministry_by_year.csv"))

cat("\nAll outputs written to", out_dir, "and", clean_dir, "\n")
