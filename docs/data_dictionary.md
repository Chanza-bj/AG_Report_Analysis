# Data dictionary

All monetary values are Zambian Kwacha (K). Blank numeric cells mean the source printed a dash ("-"), read as NA (nil / not reported). "source_pdf_page" is the physical page of the PDF file; "printed_page" is the page number printed on the page.

## data_raw/ag_trend_tables_asprinted.csv
Faithful transcription of the "Trend Analysis of Audit Findings" tables, read from the rendered pages of the 2022 and 2023 reports. This is the source of truth for category values. One row per printed table row.

| column | meaning |
|---|---|
| report_year | Report the row is taken from (2022 or 2023). |
| row_no | Printed row number (1-38); 99 marks the printed Total row. |
| category_printed | Query category exactly as printed, including source spelling. |
| amt_prior_kwacha | Amount in the left (prior-year) column. 2022 report = FY2021; 2023 report = FY2022. |
| amt_current_kwacha | Amount in the right (current-year) column. 2022 report = FY2022; 2023 report = FY2023. |
| printed_variance | Variance exactly as printed (current minus prior). |
| printed_variance_pct | Variance percentage as printed. |
| source_pdf_page | PDF page of the table. |
| printed_page | Page label printed on the page (ii). |

## data_clean/findings_by_category_tidy.csv
Tidy long form produced by R from the file above. One row per observation = one (report_year, financial_year, category) amount.

| column | meaning |
|---|---|
| report_year | Report the value is taken from. |
| financial_year | Financial year the amount refers to (2021, 2022, or 2023). |
| row_no | Printed row number in the source table. |
| category_printed | Category as printed. |
| category_std | Cleaned matching key (lower case, OCR fixes) used to reconcile across reports. |
| amount_kwacha | Amount in Kwacha; NA where the source printed a dash. |
| source_pdf_page, printed_page | Page citation. |

## data_clean/unresolved_paragraphs.csv
One row per findings paragraph listed in each report's Table of Contents (the inventory of unresolved matters). Read from the rendered Table-of-Contents pages.

| column | meaning |
|---|---|
| financial_year | Financial year of the report (2021-2025). |
| para_no | Paragraph number as printed in the Table of Contents. |
| head_code | Government Head (budget vote) code as printed. Note: Head codes are reused for different ministries between years. |
| entity_printed | Ministry, province, or agency exactly as printed. |
| ministry_std | Standardised portfolio name used for recurrence counts. |
| province | Province name where the entity is a provincial administration, else NA. |
| toc_pdf_page | PDF page of the Table of Contents entry. |

## data_clean/notable_observations.csv
Itemised "notable observations" from the executive-summary narratives of the 2021, 2024, and 2025 reports, which the Office organises by ministry. One row per enumerated observation. These are the AG's selected notable items with a headline amount; they are NOT a comprehensive total of a ministry's findings. Transcribed from the rendered executive-summary pages. The 2022 and 2023 reports are not included because they use the category table instead of a narrative.

| column | meaning |
|---|---|
| financial_year | Financial year of the report (2021, 2024, or 2025). |
| section | "Revenue" or "Expenditure", as grouped in the report. |
| ministry_std | Standardised portfolio name (same scheme as unresolved_paragraphs.csv). |
| entity_printed | Ministry or agency as named in the narrative, including sub-unit. |
| observation | Short description of the finding. |
| headline_amount | The amount that characterises the finding; NA where the report states none. |
| currency | ZMW or USD. Kwacha and US dollar amounts are never added together. |
| kwacha_equivalent | Kwacha equivalent where the report prints one next to a US dollar figure, else NA. |
| source_pdf_page, printed_page | Page citation. |
| note | Secondary amounts, counts, or attribution caveats. |

## data_clean/fiscal_outturn.csv
Budget execution and fiscal balance from "Statement B – Statement of Comparison of Budget and Actual Amounts (Budget Execution)" in each report. One row per financial year. Transcribed from the rendered statement pages. 2021 is all NA because the 2021 report has no equivalent statement.

| column | meaning | source |
|---|---|---|
| financial_year | Financial year ended 31 December. | - |
| original_budget_payments | Total payments, original budget (K). | Statement B |
| adjustments_payments | Supplementary provision / adjustments to payments (K). | Statement B |
| final_budget_payments | Total payments, final budget (K). | Statement B |
| actual_payments | Total actual payments / expenditure (K). | Statement B |
| payment_variance | Final budget minus actual payments (net under-expenditure, K). | Statement B |
| budgeted_receipts_final | Total receipts, final budget (K). | Statement B |
| actual_receipts | Total actual receipts / revenue collected (K). | Statement B |
| surplus_deficit | Actual receipts minus actual payments (K). | Statement B |
| source_pdf_page, printed_page | Page citation (printed page 5 in each of the 2022-2025 reports). | - |

Budget execution percent (actual payments / final budget) and the surplus in billions are computed in `R/03_fiscal_outturn.R`, not stored.

## data_clean/report_metadata.csv
One row per report.

| column | meaning |
|---|---|
| financial_year | Financial year ended 31 December. |
| report_title | Full title. |
| signing_officer, officer_title | Who signed the report and in what capacity. |
| approx_pages | Approximate page count from text extraction. |
| paragraphs_stated | Number of paragraphs the report states it contains (NA where not stated). |
| exec_summary_style | "trend_table" (quantitative comparative table) or "narrative" (prose notable observations). |
| has_category_trend_table | TRUE only for 2022 and 2023. |
| reported_total_current_year_kwacha | Printed total for the report's own year, where a comparative table exists. |
| source_file | PDF file name. |

## data_clean/reconciliation_checks.csv
Results of the internal checks: category column totals versus printed totals, and the FY2022 cross-report comparison.

## data_clean/ministry_recurrence.csv
One row per standardised portfolio: years_present (out of 5), total_paragraphs, and the list of years.

## output/
Generated tables (CSV) and charts (PNG). Rebuilt by `R/01_analysis.R`:
- chart1_trend_totals.png - reported value 2021-2023, with and without tax arrears.
- chart2_top_categories_2023.png - largest categories by value, FY2023.
- chart3_ministry_recurrence.png - portfolios flagged in all five reports.
- chart4_paragraphs_per_year.png - paragraph counts per report.
- table_trend_totals.csv, table_fy2023_categories.csv, table_paragraphs_per_year.csv, table_ministry_by_year.csv.

Rebuilt by `R/02_notable_observations.R`:
- chart5_notable_by_ministry.png - Kwacha value of selected notable observations by ministry (narrative years).
- table_notable_by_ministry_year.csv - Kwacha and US dollar totals and observation counts per ministry per year.
- table_notable_usd.csv - the US dollar observations listed on their own.
