# Changelog

All notable changes to this project are recorded here. Versions follow
[Semantic Versioning](https://semver.org/). Corrections to any published figure
will appear as a new version so that changes stay visible.

## [1.1.0] - 2026-11-09

Major analytical expansion and a new interactive dashboard.

### Added
- **Interactive dashboard** (`site/index.html`, ECharts) published as the landing page; the written report moved to `full-report.html`.
- **Contracts flagged** (`contracts_flagged.csv`) expanded from 19 to **32 named contracts** across ~15 ministries, each verified against its PDF page (AVIC, ZTE, Siemens, Jiangsu Gold, Augusta, IHMSA, Nyiombo, Pozzolana, Buywell, Henina, Menov, Joshisa, …).
- **Supplier index** (`supplier_index.csv`, `R/04`, `R/05`) - ~471 text-verified company names across the reports, with a searchable dashboard table and recurring-supplier view.
- **2022 FISP seed delivery** (`seed_delivery_2022.csv`) - 17 suppliers, 33,283 MT, verified against page 215.
- **Audit opinions** (`audit_opinions.csv`) - 2022-2025 all unqualified; 2021 none.
- **Repeat/unresolved findings** (`repeat_findings.csv`, `R/06`) - 26 of 39 categories recur; 4 rose every year.
- **Materiality** (`ministry_funding_gaps.csv`) - 13 in-report underfunding figures (K47.7bn), ministry-attributed.
- Budget-execution, surplus, and delivery-status analyses; red-flag signals.

### Changed
- Report rewritten for a general audience (code hidden); professional, CVD-validated chart palette.
- Removed the "ZM" placeholder logo; strengthened mobile responsiveness.

### Verified
- Every headline figure and every contract checked against its rendered source page.

## [1.0.0] - 2026-11-09

First published version. Covers the Auditor General of Zambia's Reports on the
Accounts of the Republic for the financial years ended 31 December 2021-2025.

### Added
- `data_clean/fiscal_outturn.csv` - budget execution and surplus, 2022-2025 (Statement B, printed page 5). 2021 has no equivalent statement.
- `data_clean/findings_by_category_tidy.csv` - category values, 2021-2023 (trend tables in the 2022 and 2023 reports).
- `data_clean/unresolved_paragraphs.csv` - one row per findings paragraph, 2021-2025, for ministry recurrence.
- `data_clean/notable_observations.csv` - itemised narrative amounts, 2021, 2024, 2025.
- `data_raw/ag_trend_tables_asprinted.csv` - faithful transcription of the two trend tables.
- R scripts `00_extract.R`, `01_analysis.R`, `02_notable_observations.R`, `03_fiscal_outturn.R`.
- Quarto report `report/zambia_ag_reports_2021_2025.qmd`.
- Documentation: summary, methods and limitations, data dictionary, follow-up questions.

### Verified
- All three headline claims checked against the source PDF pages: unresolved paragraphs 40 (2022) to 27 (2025); budget execution 76% (2022) to 86% (2025); surplus K30.18bn (2022) to K2.11bn (2025).
- Quality-assurance spot-check of a fresh sample of figures across all datasets against their cited pages: all matched.
- Internal reconciliation: the FY2022 category total is identical in the 2022 and 2023 reports (K103,519,546,579).

### Known limitations
- Budget-execution series starts in 2022; 2021 has no Statement B.
- Budget execution is not monotonic (76%, 88%, 82%, 86%).
- The findings-value series is comparable for 2021-2023 only and is dominated by the ZRA tax-arrears line.
- One 2021 notable observation (Lodestar arbitration) is flagged for ministry verification on page 13.
