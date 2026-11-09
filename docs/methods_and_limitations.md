# Methods and limitations

## What was measured
Two measures, each tied to a definition the Office of the Auditor General uses in the reports.

1. **Value of findings** = the Kwacha amount the Office assigns to each "query category" in its "Trend Analysis of Audit Findings" table. This table appears only in the 2022 and 2023 reports, and each table shows two financial years (prior and current). Together they give comparable category amounts for financial years 2021, 2022, and 2023.

2. **Recurrence of findings** = the number of unresolved-findings paragraphs listed in each report's Table of Contents, attributed to a portfolio by the printed entity name. This is available for all five years and is the basis for the ministry-recurrence analysis.

## How figures were extracted
The five PDFs are text-based but the automated text layer misaligns the columns of the summary tables (the two year columns and the category labels do not line up when extracted as plain text). To avoid transcription errors, each summary-table page and each Table-of-Contents page was rendered to an image from the PDF (R `pdftools::pdf_convert`) and read directly. Figures in `data_raw/ag_trend_tables_asprinted.csv` and `data_clean/unresolved_paragraphs.csv` are transcribed from those rendered pages, each with its page citation. No value was estimated or inferred; dashes in the source are recorded as NA.

## Format change across years (scope flag)
The reports are not uniform.
- 2021: narrative executive summary, no comparative category table.
- 2022 and 2023: quantitative "Trend Analysis of Audit Findings" table.
- 2024 and 2025: narrative "notable observations", no comparative category table.

So the category value series is only comparable for 2021-2023. For 2024 and 2025 the category total is NA because the report does not publish one. This is a reporting-format difference, not a statement that there were no findings.

## Internal checks performed (results in reconciliation_checks.csv)
1. **Component sums vs printed totals.** The FY2022 column total equals the printed total in both the 2022 and 2023 reports (K103,519,546,579). The FY2021 and FY2023 printed totals each differ from the sum of their components by one Kwacha, a rounding difference in the source.
2. **Cross-report check of the overlapping FY2022 column.** The 2022 report (current column) and 2023 report (prior column) agree category by category, with one exception: a K7,262,410 reallocation between "Irregular Distribution of Farming Inputs" and "Irregular Inclusion of Beneficiaries for Farming Inputs" that nets to zero. The reports restated how this amount splits between the two categories.
3. **Printed variance vs recomputed variance.** Printed variance equals (current minus prior) in 75 of 76 category rows. The exception is "Wasteful Expenditure" in the 2022 report, where the printed variance is one Kwacha off.

## Data-quality notes
- **Head codes are not stable.** The same budget Head code is reused for different ministries between years (for example Head 52 is "Green Economy and Environment" in 2023 and "Water Development and Sanitation" in 2024). Ministry identity is therefore keyed on the printed entity name, not the code.
- **Category labels change and contain source typos** ("Tranfer", "Withdraw", "Unacquited", "Unaquitted"). A cleaned key (`category_std`) is used only to match categories across the two reports; the original label is kept in `category_printed`.
- **One externally sourced line dominates.** "Failure to Collect Tax Arrears" is taken by the Office from the Zambia Revenue Authority's annual report and is a stock of arrears, not an in-year loss. Totals are reported both with and without it.
- **Two very large single-year 2021 lines.** "Over Commitment" (K16.86bn) and "Uncompetitive Procurement" (K12.83bn) are reported in 2021 and fall to near zero in 2022. Their basis is not explained in the summary table; they are reported as printed and flagged.
- **Paragraph numbering is imperfect in the source** (for example the 2022 Table of Contents numbers two separate entries "7"). Counts here follow the entity entries as printed.

## Limitations
- The value series covers 2021-2023 only.
- Totals are dominated by one externally sourced figure and, in 2021, by two large categories.
- Paragraph counts measure the volume of findings, not their monetary size, and are not a value by ministry.
- US dollar amounts in the narrative are not converted and are excluded from Kwacha totals.
- The 2024 "ONLINE PUBLICATION" PDF is large (about 102 MB); all five were readable as text, so no page needed optical character recognition, but scanned exhibits inside any report would not be captured by text tools.
- The analysis uses the published main reports only. It does not include working papers, the Estimates of Revenue and Expenditure, Treasury Minutes, or Public Accounts Committee outcomes.

## Budget execution and surplus (2022-2025)
`data_clean/fiscal_outturn.csv` holds the fiscal outturn from "Statement B – Statement of Comparison of Budget and Actual Amounts (Budget Execution)", which appears on printed page 5 of the 2022, 2023, 2024, and 2025 reports. Figures were read from the rendered statement pages. Budget execution is actual payments divided by the final budget; the surplus is actual receipts minus actual payments.

- 2022: final budget K175.24bn, actual payments K133.76bn, execution 76.3%, surplus K30,183,770,492.
- 2023: final budget K178.45bn, actual payments K156.55bn, execution 87.7%, surplus K19,710,561,294.
- 2024: final budget K231.57bn, actual payments K189.35bn, execution 81.8%, surplus K2,673,504,185.
- 2025: final budget K250.68bn, actual payments K216.30bn, execution 86.3%, surplus K2,111,879,747.

Two cautions on interpretation:
- **2021 is left out.** The 2021 report does not contain Statement B, so there is no comparable budget-execution or surplus figure for that year. This is one of the "2021 budget tables" that are not available.
- **Execution is not monotonic.** The rise from 76% (2022) to 86% (2025) holds at the endpoints only. It was 88% in 2023 and 82% in 2024. A surplus or higher execution is not in itself evidence of better service delivery; under-spending can reflect delayed projects or financing that did not arrive.

## Narrative observations and value by ministry (2021, 2024, 2025)
The 2021, 2024, and 2025 executive summaries present findings as notable observations organised by ministry. `data_clean/notable_observations.csv` transcribes those items with amounts and page citations, read from the rendered executive-summary pages. Points to keep in mind:
- These are the selected items the Office chose to highlight. They are not a comprehensive total of each ministry's findings, so the by-ministry Kwacha figures understate the full picture and should not be compared with the category totals for 2021-2023.
- Kwacha and US dollar amounts are held in separate columns and never added. Several large 2021 items are US dollar denominated (for example Agriculture direct-bidding US$430m, two Health hospital contracts near US$99m each).
- Where a report prints both a US dollar figure and a Kwacha equivalent, the equivalent is recorded in a separate column.
- One 2021 item (the Lodestar International arbitration award, US$2,000,000) could not be tied to a named ministry from the extract and is flagged for verification on page 13.
- The ZRA tax-arrears line (K85.78 billion, 2021) is a stock figure and is excluded from the by-ministry chart so it does not dominate the scale.

## Interpretation boundary
Audit findings are matters the Office could not resolve by its cut-off date (stated in each report, for example 30 September of the following year). They are not proof of wrongdoing, and the reports state that Controlling Officers' explanations may still be pending. This analysis reports what the documents record and separates that from interpretation.
