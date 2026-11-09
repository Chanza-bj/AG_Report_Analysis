# Changelog

All notable changes to this project are recorded here. Versions follow
[Semantic Versioning](https://semver.org/). Corrections to any published figure
will appear as a new version so that changes stay visible.

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
