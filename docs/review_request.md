# Draft: request for expert review

A short note to send to a parliamentary analyst or to Transparency International
Zambia before publishing figures widely. Replace the bracketed parts. Keep it
short; attach or link the repository and the rendered report.

---

**Subject:** Request for a sanity check - Auditor General reports 2021-2025 (reproducible dataset)

Dear [name],

I have built a small, reproducible dataset and analysis from the Auditor
General's Reports on the Accounts of the Republic for 2021 to 2025. Before I
share any figures publicly, I would value your eyes on the method and the three
headline points. Everything is transcribed from the reports with the PDF page
recorded for each figure, and the code and data are here:
https://github.com/Chanza-bj/AG_Report_Analysis
The rendered report is at: https://Chanza-bj.github.io/AG_Report_Analysis/
(available once GitHub Pages is enabled).

A one-page summary of the findings is in docs/key_findings_brief.md. The main points:

1. Budget execution rose from 76% of the final budget in 2022 to 86% in 2025
   (not a straight line: 88% in 2023, 82% in 2024); the surplus shrank from
   about K30.2bn to about K2.1bn. 2021 has no comparable statement.
2. The financial statements received an unqualified ("clean") opinion every year
   from 2022 to 2025, alongside large transaction-level findings.
3. The same problems recur: 26 of 39 finding categories appear every comparable
   year, nine ministries appear in all five reports, and unpaid bills rose from
   K3.9bn to K5.2bn.
4. 34 named contracts are deep-verified and page-checked (e.g. ZTE Safe City
   US$210m with US$178.5m in loans outstanding; K786m paid to seed suppliers
   that delivered nothing by the deadline). These sit inside a master table of
   206 contracts, each row carrying a single verified / unverified flag: the 34
   verified rows are citable now; an unverified row is an amount the report
   names on a page, with the supplier and detail still to be deep-checked.
5. In-report figures show at least K47.7bn in ministry underfunding over
   2023-2025, which the reports link to activities being dropped.

On reliability: a reproducible sampling QA (`docs/qa_sampling.md`,
`Rscript R/11_qa_sampling.R`) re-checked random rows from the bulk layers
against their cited pages - valued amounts 30/30, index names 25/25, supplier
cases 19/20 landed on the page they cite. So the page citations hold; what is
not yet established for the unverified rows is whether a named amount is the
final contract value and whether the supplier detail is complete.

I would be grateful for your view on three questions:

- The findings totals are dominated by one line, "Failure to Collect Tax
  Arrears", which the Office takes from ZRA and which is a stock of arrears, not
  an in-year loss. Should that line always be shown stripped out, or is there a
  standard way readers expect to see it?
- Is comparing budget execution across years sound given the large
  supplementary provisions, or should I frame it only as "payments against the
  final budget" without implying a trend?
- Am I right to treat the 2024 and 2025 category values as not comparable with
  2021-2023 because those reports dropped the trend table?
- Before I name any supplier or ministry publicly, is the verified / unverified
  split the right line to hold - naming only the 34 deep-verified contracts, and
  leaving the unverified amounts as "the report records this on this page"
  without attaching a supplier in public? A finding is a query to answer, not a
  proven wrong, and I want the framing to make that plain.

I am keeping everything version-tagged so any correction stays visible. Any
errors you spot would be very welcome. Thank you for your time.

[your name]
