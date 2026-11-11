# Contributing

Thank you for helping check and improve this project. The most useful contributions are corrections traced to the source: a wrong figure, a wrong supplier name, a missing contract, or a page reference that does not match the report.

## Ground rules

1. **Every figure needs a source.** Cite the report year and the PDF page, for example `2025 report, PDF page 118`. A figure without a page reference cannot be merged.
2. **Findings are questions, not verdicts.** Write "the report records", "the auditors could not account for", or "an explanation was still owed". Do not write "stole", "fraud", or "lost", and do not imply wrongdoing that the report does not state.
3. **Do not invent or estimate silently.** If a value is your own calculation (for example a pro-rata share), label it as an estimate in the `note` column.
4. **Respect people.** Named individuals appear only where the report names them. Do not add personal contact details, identity numbers, or private information.
5. **Keep one change per pull request** where possible.

## Ways to contribute

- **Report a data error:** use the *Data error* issue template. It asks for the report year, PDF page, the value as written, and the value in the project.
- **Verify a row:** pick an unverified row in `data_clean/supplier_cases.csv` or `data_clean/contracts_flagged.csv`, open the PDF page, and confirm supplier, value, and status. Use the verification template in `docs/qa_sampling.md`.
- **Add a case:** follow the row format in `docs/data_dictionary.md` and open a pull request with the page reference.
- **Improve the code:** the analysis lives in `R/`. Scripts run in order (`00_extract.R` to `14_reconcile_findings.R`). Please say which script your change affects.
- **Improve the writing:** plain English is preferred. Short sentences, one claim per sentence, and every claim cited.

## Working with the data

- Raw extracts live in `data_raw/`. Cleaned tables used by the site live in `data_clean/`. Do not edit the cleaned tables by hand without updating the step that produces them.
- The Auditor General's PDFs are not stored in this repository. Download them from the Office of the Auditor General of Zambia and keep them out of commits (`*.pdf` is ignored).

## Pull requests

1. Fork the repository and create a branch.
2. Make your change and, where data changed, rerun the affected scripts.
3. Fill in the pull request template, including the source page for every new figure.
4. A maintainer reviews the source before merging. Expect questions; they are part of the process.

## Questions

Open a discussion or an issue. For anything sensitive, see the Code of Conduct.
