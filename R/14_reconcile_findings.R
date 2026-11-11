# =============================================================================
# 14_reconcile_findings.R  -  Check that the findings category rows add up to
# the totals the reports print. Each of the 2022 and 2023 reports prints a
# "Trend Analysis of Audit Findings" table with TWO financial-year columns
# (prior year and current year), so rows must be summed by report AND
# financial year, never by report alone. The 2024 and 2025 reports print no
# such table.
#
# Stops with an error if any sum differs from its printed total by more than
# K2 (the printed figures are rounded to the kwacha).
# Input : data_clean/findings_by_category_tidy.csv
#         data_clean/findings_totals_printed.csv
# =============================================================================
suppressMessages({library(readr); library(dplyr)})

cats <- read_csv("data_clean/findings_by_category_tidy.csv", show_col_types = FALSE)
printed <- read_csv("data_clean/findings_totals_printed.csv", show_col_types = FALSE)

check <- cats |>
  group_by(report_year, financial_year) |>
  summarise(sum_rows = sum(amount_kwacha, na.rm = TRUE), .groups = "drop") |>
  inner_join(printed, by = c("report_year" = "source_report_year", "financial_year")) |>
  mutate(diff = sum_rows - printed_total_kwacha, ok = abs(diff) <= 2)

print(check |> transmute(report_year, financial_year,
                         sum_rows = format(sum_rows, big.mark = ",", scientific = FALSE),
                         printed  = format(printed_total_kwacha, big.mark = ",", scientific = FALSE),
                         diff, ok, page = source_pdf_page))

if (nrow(check) != nrow(printed)) stop("Some printed totals have no matching category rows.")
if (!all(check$ok)) stop("Findings category rows do not reconcile with the printed totals.")
cat("All findings totals reconcile with the printed tables (within K2).\n")
