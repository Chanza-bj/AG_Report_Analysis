# Release note for v1.0.0

Paste this into the GitHub release body (Releases -> Draft a new release ->
choose tag v1.0.0 -> title "v1.0.0" -> paste below).

---

## Zambia's public finances through the Auditor General's reports, 2021-2025 (v1.0.0)

First published version. A reproducible dataset and analysis built from the five
main reports of the Office of the Auditor General of Zambia, *Reports on the
Accounts of the Republic*, for the financial years ended 31 December 2021-2025.
Every figure is transcribed from the source PDFs with the page recorded.

**Audit findings are not proof of theft or wrongdoing.** The reports record what
the accounts show and what explanations are still needed. This project reports
what the documents say and keeps that separate from interpretation.

### What it shows (all checked against the source pages)
- **Budget execution** rose from 76% of the final budget in 2022 to 86% in 2025
  (not a straight line: 88% in 2023, 82% in 2024). 2021 has no comparable statement.
- **The fiscal surplus** shrank from K30.2 billion in 2022 to about K2.1 billion in 2025.
- **Unresolved-findings paragraphs** fell from 40 in 2022 to 27 in 2025.
- **The reported value of findings** is comparable for 2021-2023 only
  (K133.3bn, K103.5bn, K81.5bn), dominated by one ZRA tax-arrears line.
- **Nine portfolios appear in every report**; provincial administration under the
  Office of the President has the most paragraphs, then Finance, Agriculture,
  Home Affairs, Education, and Health.

### What's in the repository
- Tidy, page-cited datasets in `data_clean/`.
- R scripts (`R/`) and a Quarto report (`report/`) that reproduce every table and chart.
- A data dictionary, methods note, and written summary in `docs/`.

### Known limitations
- Budget-execution series starts in 2022 (2021 has no Statement B).
- Budget execution is not monotonic.
- The findings-value series covers 2021-2023 only and is dominated by one externally
  sourced tax-arrears figure.
- US dollar amounts are not converted and are excluded from Kwacha totals.
- Figures come from the published main reports only, not working papers or later
  Treasury Minute responses.

### How to cite
Office of the Auditor General, *Report on the Accounts of the Republic* for the
relevant year, with the PDF page given in the data. Cite this repository as
`AG_Report_Analysis`, version 1.0.0.

Corrections will appear as later tagged versions so that changes stay visible.
