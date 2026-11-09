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

## data_clean/contracts_flagged.csv
Named contracts the reports question. A first batch, drawn from the reports' highlighted cases (the bodies name many more). One row per contract.

| column | meaning |
|---|---|
| financial_year | Report year (2021-2025). |
| ministry_std | Standardised portfolio. |
| supplier | Contractor or supplier named in the report ("not named" where the report withholds it). |
| description | What the contract was for. |
| contract_value | Contract sum, where stated. |
| contract_currency | ZMW or USD. |
| procurement_method | single-source, uncompetitive, competitive, concession, joint-venture, or unknown. |
| delivered | Yes, No, Partial, or NA (not stated / not applicable) at the report's cut-off. |
| issue_flagged | What the auditors questioned (e.g. undelivered, overpriced, unsupported payment, cover bidding, under-declaration). |
| amount_at_issue | The amount the finding turns on (paid-but-undelivered, unrecovered, over-paid, etc.), where stated. |
| amount_currency | ZMW or USD for amount_at_issue. |
| source_pdf_page | Page citation. |
| note | Extra detail. |

Kwacha and US dollar amounts are never added together. A flagged contract is a question the auditors raised, not a proven loss.

## data_clean/seed_delivery_2022.csv
Supplier-level detail of the 2022/2023 FISP seed procurement, from "Table 7: Seed Not Delivered as at 15th January 2023" in the 2022 report (PDF page 215, printed page 198). One row per supplier; base figures transcribed from the table, derived figures computed in code.

| column | meaning |
|---|---|
| supplier | Seed supplier as named in the table. |
| contract_sum_zmw | Contract sum (ZMW). |
| amount_paid_zmw | Amount paid at the cut-off (ZMW); "-" in the source recorded as 0. |
| qty_contracted_mt | Quantity contracted, metric tonnes. |
| qty_delivered_mt | Quantity delivered by 15 Jan 2023, metric tonnes. |
| qty_undelivered_mt | Quantity undelivered (contracted minus delivered); two rows show a small negative/rounding as printed. |
| pct_undelivered_reported | Percentage undelivered, as printed. |
| source_pdf_page | PDF page (215). |

Verified against the printed totals: 33,283.04 MT contracted, 9,176.89 delivered (27.6%), 24,106.15 undelivered. The 13 suppliers at 100% undelivered were paid K786,008,813 of their K1,199,203,190 contracts. A later check found most delivered late, between mid January and end March 2023. Delivery is "not delivered" only as at the report's cut-off.

## data_clean/supplier_index.csv
A broad index of company names that appear across the reports, produced by `R/04_supplier_index.R` from an auto-extraction (`data_raw/supplier_index_raw.csv`). It is cleaned (parsing artifacts, section headers, place names and seed types removed), near-duplicate names merged, and each name checked against the report text. This is an index of **appearances**, not a verified contract register; the valued, delivery-checked contracts are in `contracts_flagged.csv`. Residual auto-extraction noise may remain.

| column | meaning |
|---|---|
| supplier | Canonical company name (longest of the merged variants). |
| years_appearing | Report years the name appears in, semicolon-separated. |
| n_years | Number of distinct report years. |
| total_mentions | Total mentions across reports (from the extraction). |
| pages | Reported PDF pages by year. |
| verified_in_text | TRUE if the name is found in the extracted text of a claimed year. |

After cleaning: ~594 names, ~454 text-verified; 28 appear in more than one report. Distinct verified suppliers per report: 2021 ~188, 2022 ~98, 2023 ~57, 2024 ~108, 2025 ~32.

## data_clean/audit_opinions.csv
The Auditor General's formal opinion on the Republic's consolidated financial statements, from the "Audit Opinion on the Accounts" section of each report. One row per year.

| column | meaning |
|---|---|
| financial_year | Financial year. |
| opinion | Opinion type: Unqualified, Qualified, Adverse, Disclaimer, or NA. |
| opinion_wording | The report's own phrasing ("present fairly in all material respects"). |
| framework | Reporting framework the opinion is given against (IPSAS Cash Basis / CGAPs No. 2). |
| source_pdf_page | PDF page of the opinion statement. |
| note | Context. |

2021 has no formal opinion section (introduced from the 2022 report). 2022-2025 each received an **unqualified (clean)** opinion. An unqualified opinion concerns the consolidated statements overall; it does not certify every transaction, and the findings elsewhere sit below the statements' materiality threshold.

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
