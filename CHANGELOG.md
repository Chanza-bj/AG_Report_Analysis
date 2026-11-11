# Changelog

All notable changes to this project are recorded here. Versions follow
[Semantic Versioning](https://semver.org/). Corrections to any published figure
will appear as a new version so that changes stay visible.

## [1.7.0] - 2026-11-11

Case stories for readers who will not read the reports.

### Added
- **Six case stories** (`data_clean/case_stories.csv`, `R/13_case_stories.R`): laboratory equipment for 82 schools, schools' laboratory gas paid for in full with items missing, heifers for Kawambwa, bicycles for 116 cash-transfer districts, seed for 62,317 beneficiaries in 25 districts, and the unfinished Kanona early-childhood hub in Serenje. Each was read on its PDF page(s) before being written up, and shows the position on the date the auditors checked.
- **Share pages** (`site/stories/<id>.html`): each story has its own link with its own preview title and description for WhatsApp and LinkedIn, which opens the dashboard on that story. Cards carry WhatsApp, LinkedIn and copy-link buttons.

### Fixed
- `supplier_cases`: the 82-schools laboratory row named two contractors and gave the amount paid as "not stated"; the page shows four contractors and K2,169,546.90 in advances. The laboratory gas-cylinder row cited page 165; the case is on pages 163-164.

## [1.6.0] - 2026-11-11

Make the dashboard usable for people who will not read the reports.

### Added
- **Headline answer** on the first screen: "Of 34 contracts checked against the reports, 20 were not fully delivered by the audit cut-off," with the breakdown (9 none or terminated, 11 partial, 3 delivered, 11 not stated) computed from the data, and a plain note that these are highlighted cases, not a random sample.
- **Glossary** ("What the words mean") defining 14 terms, including audit finding, unqualified opinion, not fully delivered, paid before delivery, fiscal surplus (receipts minus payments, Statement B) and PDF page.
- **Report an error**: a structured GitHub issue form (`.github/ISSUE_TEMPLATE/data-error.yml`) asking where, what, report year and page, and the correct value; linked from the header and footer.

## [1.5.1] - 2026-11-11

Second credibility pass: resolve wording conflicts a close reader flagged.

### Changed
- Master-table caption no longer claims "every contract with a stated amount" (which conflicted with "about 182"); it now states 206 = ~182 named amounts + 24 deep-verified cases, and the "first set" caveat is pinned to the 34.
- The "Contracts flagged" KPI static text now reads "20 not fully delivered", matching the procurement panel's definition (no single "terminated" count).
- Budget and surplus charts carry their year range (2022-2025); the unpaid-bills tile and the method example carry years (2021-2023; K5.2bn in 2023).
- "Suppliers" relabelled to "Organisations" in the nav, section heading, tables and KPI, since the index includes agencies and state firms, not only suppliers.
- The Health-underfunding tile moved out of the procurement red-flag panel (it is shown in the underfunding chart below).
- The FISP delivery timing now cites the Office's July 2023 verification and page 215.

## [1.5.0] - 2026-11-10

Accuracy and credibility pass from a critical read of the dashboard.

### Changed
- **FISP seed wording corrected.** "Paid for nil delivery / delivered nothing" overstated the evidence; the reports say the 13 suppliers had not delivered at the 15 January 2023 deadline and most delivered late by March 2023. Reworded to "paid before delivery; delivered late" across the dashboard, brief, report and `contracts_flagged.csv`.
- **Findings-value chart limited to 2022-2023**, the only years with a comparable single total (the 2021 bar was on a different basis).
- **Counts reconciled.** The overview and method section now explain what each figure counts (34 deep-verified, ~182 valued, 206 master, 89 cases, 1,231 organisations); the stale "450+/471" supplier figures now compute from the data.
- **Overclaim removed.** "Every figure is page-cited" narrowed to the accurate statement that contract and supplier rows carry the PDF page while budget and findings figures cite the report year.
- **"Named is not fault" made explicit** in the supplier section; KPI reworded to "not fully delivered (no or partial)"; seed price range shown as exact per-tonne values so it matches the 4.1x spread.

### Added
- **"Data behind each chart"** panel linking every chart to its source CSV on GitHub.

## [1.4.0] - 2026-11-10

Push organisation-name coverage higher by joining connector names.

### Changed
- The name extractor now joins names with a lower-case connector ("Henina Engineering **and** Construction Limited", "Nitrogen Chemicals **of** Zambia"), which a capitalised-word-only rule had been truncating. It stops at the terminal word (Limited/Ltd) so two firms are not glued together, and drops leading sentence fragments and dates.
- Direct capture of clearly-named companies rose from 90% to **90%** measured on a wider, fairer denominator; **effective capture is 94%** once conflations whose real company is captured under a clean name are counted. Distinct organisations indexed rose to **1,231**. The remaining misses are extraction artifacts or initials-heavy names (`H.M Milling`, `V.B.S General Dealers`). Documented in `docs/qa_sampling.md`.

## [1.3.0] - 2026-11-10

Completeness fix: rebuild the organisation index and measure its coverage.

### Added
- **Coverage audit** (`R/12_coverage_audit.R`, `data_clean/coverage_audit.csv`): pulls every company-like name from the full report text and measures how many we captured.

### Changed
- **Organisation index rebuilt** (`R/04_supplier_index.R`) to extract names directly from the report text instead of filtering a pre-made extract. It now catches acronym-named agencies and state firms (ZAMMSA, NAPSA, ZPPA, Nitrogen Chemicals of Zambia) and firms the old filter dropped (Trade Kings, Zambia Seed Company), and fixes a space-matching bug that had been discarding valid names.
- **Coverage of clearly-named companies rose from 73% to 90%**; distinct organisations indexed rose from 594 to 1,103. Measured, not claimed (`docs/qa_sampling.md`).
- Dashboard supplier section relabelled from "suppliers" to "organisations named", states the measured 90% coverage, and the per-year chart now computes from the index rather than hand-kept numbers.

## [1.2.0] - 2026-11-10

Consolidation pass: make the dashboard data-driven and reduce drift risk.

### Added
- **Single source of truth for counts** (`R/10_dashboard_data.R` -> `site/dashboard_data.js`). The contract table, the delivery donut, the flag breakdown, the delivery-by-year chart and every headline number now generate from the page-cited CSVs, so a count can no longer drift from the rows it describes.
- **One master contract table** (206 rows) replacing the separate deep-verified (34) and all-valued (182) tables. Each row carries a single verified / unverified flag; one search box and one set of filters (verified, delivery, currency, year).
- **Sampling QA** (`R/11_qa_sampling.R`, `docs/qa_sampling.md`, `data_clean/qa_sample_checks.csv`): random rows from the bulk layers re-checked against their cited pages - valued 30/30, index 25/25, cases 19/20.

### Changed
- Contracts deep-verified total is **34** (adds NMS Infrastructure and Zhong Ding / Wah Kong King Salman). Corrected stale figures across the brief, the rendered report and the dashboard (e.g. a hand-kept supplier total of 471 now computes to 479; a "32" caption now reads 34).
- `docs/review_request.md` updated for external review before any name is published: points to the QA note and asks whether naming only the verified contracts is the right line to hold.

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
