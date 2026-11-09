# Zambia's public finances through the Auditor General's reports, 2021 to 2025

A reproducible analysis of the Office of the Auditor General of Zambia's *Reports on the Accounts of the Republic* for the financial years ended 31 December **2021 through 2025**. It covers budget execution and surplus, the value of audit findings, and which ministries recur most often in unresolved findings. Every figure is tied to the report year and the PDF page it came from.

> **Audit findings are not proof of theft or wrongdoing.** The reports set out what the records show and what explanations are still needed. This project reports what the documents record and separates that from interpretation. Prefer "the report records K3.56 billion in unpaid obligations" over "the ministry lost K3.56 billion."

## Key findings (all verified against the source PDFs)

- **Budget execution rose from 76% of the final budget in 2022 to 86% in 2025** (printed page 5 of each report). The path was not a straight line: 88% in 2023, 82% in 2024. The 2021 report has no equivalent statement, so 2021 is not available.
- **The fiscal surplus shrank from K30.2 billion in 2022 to about K2.1 billion in 2025** (actual receipts minus actual payments).
- **Unresolved-findings paragraphs fell from 40 in 2022 to 27 in 2025** (52 in 2021, 31 in 2023, 33 in 2024).
- **The reported value of findings is comparable only for 2021-2023** (K133.3bn, K103.5bn, K81.5bn), and is dominated by one ZRA tax-arrears line. The 2024 and 2025 reports publish no comparable total.
- **Nine portfolios appear in every report.** Provincial administration under the Office of the President has the most unresolved-findings paragraphs, then Finance, Agriculture, Home Affairs, Education, and Health.

**Live interactive dashboard:** https://chanza-bj.github.io/AG_Report_Analysis/ · one-page shareable summary: [`docs/key_findings_brief.md`](docs/key_findings_brief.md) · full written report: `report/zambia_ag_reports_2021_2025.html`.

## Repository structure

```
.
├── README.md                     This file
├── LICENSE                       MIT licence for the code
├── data_raw/
│   └── ag_trend_tables_asprinted.csv    Faithful transcription of the 2022/2023 trend tables
├── data_clean/                   Tidy, analysis-ready data (one row per observation; page-cited)
│   ├── fiscal_outturn.csv              Budget execution and surplus (2022-2025)
│   ├── findings_by_category_tidy.csv   Category values (2021-2023)
│   ├── unresolved_paragraphs.csv       One row per findings paragraph (ministry recurrence)
│   ├── notable_observations.csv        Itemised narrative amounts (2021, 2024, 2025)
│   ├── report_metadata.csv
│   ├── reconciliation_checks.csv
│   └── ministry_recurrence.csv
├── R/
│   ├── 00_extract.R              Extraction pipeline (PDF text + rendered key pages)
│   ├── 01_analysis.R            Category trend, ministry recurrence, internal checks
│   ├── 02_notable_observations.R Value-by-ministry from the narrative years
│   └── 03_fiscal_outturn.R       Budget execution and surplus
├── report/
│   └── zambia_ag_reports_2021_2025.qmd   Quarto report (code + charts + narrative)
├── output/                       Generated charts (.png) and tables (.csv)
└── docs/
    ├── summary.md                600-word written summary
    ├── methods_and_limitations.md
    ├── data_dictionary.md        Every variable, with its source page
    └── follow_up_questions.md    Questions the data cannot answer
```

## Data sources

Five public PDF reports from the Office of the Auditor General of Zambia (https://www.ago.gov.zm):

| Year | File |
|---|---|
| 2021 | Auditor-Generals-Main-Report-2021.pdf |
| 2022 | Auditor-Generals-Main-Report-2022.pdf |
| 2023 | Auditor-Generals-Main-Report-2023.pdf |
| 2024 | Auditor-General-Report-for-the-Financial-Year-2024-ONLINE-PUBLICATION.pdf |
| 2025 | AUDITOR-GENERAL-REPORT-On-the-Accounts-of-the-Republic-for-the-Financial-Year-Ended-31st-Dec-2025.pdf |

The PDFs are large and are **not** stored in this repository. Download them and point `R/00_extract.R` at the folder (set the `AG_PDF_DIR` environment variable).

## Method in brief

Automated text extraction misaligns the columns of the summary, budget, and Table-of-Contents tables in these PDFs. To avoid transcription errors, each relevant page was rendered to an image (`pdftools::pdf_convert`) and read directly; figures were transcribed into the `data_clean/` CSVs with the PDF page recorded for each. Full detail, including internal reconciliation checks and what was left out, is in `docs/methods_and_limitations.md`.

## How to reproduce

Requires R (tested on 4.3.2) with: `pdftools`, `readr`, `dplyr`, `tidyr`, `stringr`, `forcats`, `ggplot2`, `scales`; and Quarto (tested on 1.9) for the report.

```sh
# 1. Extract text and render the key pages (needs the PDFs; see Data sources)
Rscript R/00_extract.R

# 2. Build the datasets, charts, and checks
Rscript R/01_analysis.R
Rscript R/02_notable_observations.R
Rscript R/03_fiscal_outturn.R

# 3. Render the report
quarto render report/zambia_ag_reports_2021_2025.qmd
```

The cleaned CSVs are already in `data_clean/`, so steps 2 and 3 run without the PDFs. Step 1 regenerates the extraction evidence from the source PDFs.

## How to cite

Cite each figure with the report year and page, for example: *Office of the Auditor General, Report on the Accounts of the Republic for the year ended 31 December 2025, page 5.* Cite this repository by its tagged version so later corrections stay visible.

## Before you publish

- Separate facts from interpretation, and cite every number with report, year, and page.
- Give named institutions a chance to respond.
- Show uncertainty: say which years are incomplete and which measures are not comparable.
- Consider sharing a draft with a parliamentary analyst or Transparency International Zambia for review.

## Licence

Code is released under the MIT Licence (`LICENSE`). The underlying reports are public documents of the Government of the Republic of Zambia; this project adds transcription, code, and analysis only.
