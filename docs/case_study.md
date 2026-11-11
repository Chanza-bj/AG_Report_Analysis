# Turning five audit reports into a dataset people can check

**Boyd Chanza · Data analysis case study · R, Quarto, GitHub Pages**

Live dashboard: https://chanza-bj.github.io/AG_Report_Analysis/
Code and data: https://github.com/Chanza-bj/AG_Report_Analysis

## The problem

Zambia's Auditor General publishes a *Report on the Accounts of the Republic* each year. The five reports for 2021 to 2025 run to 1,862 PDF pages. They are the best public record of how government money was spent and where it went wrong, but almost nobody reads them. The layout changes between years, some tables exist in one year and not the next, and the same supplier or ministry can be named in several different ways.

I set out to turn them into a structured dataset where every contract and supplier row carries the PDF page it came from, so that a journalist, a committee clerk or a citizen can check any claim in under a minute.

## What I built

| Layer | Rows | How it was built |
|---|---|---|
| Deep-verified contracts | 34 | Supplier, value and delivery status read on the page |
| Master contract table | 206 | 182 auto-extracted contract amounts, plus 24 deep-verified cases from summary pages, each flagged verified or unverified |
| Goods and services cases | 89 | Supplier, item, amount and delivery status, spot-checked |
| Organisations named | 1,231 | Every supplier, contractor, agency and state firm named in the text |
| Case stories | 6 | Read in full on their pages before being written up |

Alongside these: budget execution and surplus for 2022 to 2025, findings by category, repeat findings, audit opinions and stated ministry underfunding. Thirteen R scripts rebuild the dataset from the extracted report text and the source CSVs. A dashboard, a one-page brief and a written report sit on top.

## How I checked it

**Sampling.** I drew a random sample (fixed seed, so anyone can rerun it) from the three bulk layers and re-opened each row's cited page. 74 of 75 rows matched: 30 of 30 contract amounts, 25 of 25 organisation names and 19 of 20 cases. The one miss was a placeholder label, not a wrong page.

**Coverage, not just accuracy.** Sampling only tells you whether the rows you have are right. It cannot tell you what is missing. When I looked for agencies I knew appeared in the reports, the organisation index was missing ZAMMSA, NAPSA, Trade Kings and Zambia Seed Company. I measured coverage against every company name in the text and found it at 73%. The cause was an extraction step that filtered out acronym names, plus a bug that discarded names split across the PDF's column spacing. After rebuilding the extractor, the index grew from 594 to 1,231 names, and coverage rose to 90% matched directly and 94% once extraction artifacts are set aside.

**Errors I found and corrected**, each recorded as a new version in the changelog:

- The dashboard said K786 million was "paid for nil delivery" to 13 seed suppliers. The report says they had not delivered by the 15 January deadline, and a July 2023 verification found most delivered by March. The wording now says "paid before delivery".
- Headline counts were typed by hand and had drifted from the data: a supplier total of 471 against 479 computed, and a "32 contracts" caption when there were 34. Every count now generates from the data.
- A findings chart included a 2021 bar, but a comparable single findings total is reported only for 2022 and 2023. It now shows those two years only.
- Reading the case-story pages turned up two errors in my own case table: a contract listed two of its four contractors, and a row cited the wrong page.
- The site claimed "every figure is page-cited". Contract and supplier rows are; budget and findings figures cite the report year. The claim now says exactly that.

## Data quality decisions

- **No estimates.** Where a report does not state a value, the cell is empty and the reason is noted.
- **Currencies kept apart.** Kwacha and US dollar amounts are never added together.
- **One outlier shown on its own.** Unpaid tax arrears are a stock built up over years and dominate every findings total, so they are reported separately.
- **Unnamed suppliers stay unnamed.** "Contractor (not named)" is recorded as such, never guessed.
- **PDF page, not printed page.** The two differ, and only the PDF page lets someone jump straight to the source.
- **A finding is a question.** Being named in an audit paragraph is not being found at fault, and the site says so wherever names appear.

## What the data shows

1. **Budget execution rose but not steadily.** Payments reached 76.3% of the final budget in 2022 and 86.3% in 2025, with 87.7% and 81.8% in between. The surplus of receipts over payments fell from K30.2 billion to K2.1 billion.
2. **Clean accounts, persistent problems.** The consolidated accounts received an unqualified opinion every year from 2022 to 2025, while 26 of 39 finding categories recurred in every comparable year (2021 to 2023). Unpaid bills rose from K3.9 billion to K5.2 billion over that period.
3. **Delivery is the weak point in the cases the auditors chose to highlight.** Of 34 contracts checked against their pages, 20 were not fully delivered at the audit cut-off. These are highlighted cases, not a random sample, so they show where problems were found, not how common they are.

## What it cannot show

The data records each report's position on its audit date, so later deliveries and recoveries are not reflected. Ministries' responses in later reports and before parliamentary committees are not included. 2021 has no comparable budget statement, and a single findings total exists only for 2022 and 2023. The organisation index captures about 94% of named companies, not all of them.

## Reproduce it

Download the five reports from the Auditor General's website (https://www.ago.gov.zm), point the `AG_PDF_DIR` environment variable at that folder, clone the repository, run the R scripts in `R/` in numbered order, and render the Quarto report. The data dictionary, methods note, sampling QA, coverage audit and changelog are in `docs/` and at the repository root. Errors can be reported through a form on the dashboard.
