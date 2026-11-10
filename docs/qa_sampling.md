# Sampling QA: how reliable are the bulk layers?

The dashboard holds four layers of contract and supplier data. Two were built
by deep, row-by-row verification; three were built by bulk or automated
extraction and are large enough that not every row could be hand-checked. This
note is a sampling check on those bulk layers, so a reader knows how far to
trust them before any name is acted on.

## What was checked

| Layer | Rows | How built | Sampled |
|-------|------|-----------|---------|
| Valued contracts | 182 | Every "contract sum of K/US$…" pulled from the reports, with amount, ministry and page | 30 |
| Supplier cases (goods & services) | 89 | Supplier/item/amount/delivery, spot-verified | 20 named |
| Organisation index | 1,103 | Suppliers, contractors, agencies and state firms, extracted directly from the report text | 25 |

The 34 deep-verified contracts are **not** sampled here. Every one of them was
already read against its page, so they are the reference layer, not a layer
under test.

## Coverage: how complete is the organisation index?

Sampling tells you whether the rows you have are right. It does not tell you how
many you are missing. An earlier version of the index was built by filtering a
pre-made extract and demonstrably missed real organisations: agencies that go by
initials (ZAMMSA, NAPSA, ZPPA) were absent, and firms such as Trade Kings,
Zambia Seed Company and Nitrogen Chemicals of Zambia were dropped.

The index was rebuilt (`R/04_supplier_index.R`) to extract names directly from
the report text, with broader name patterns and a curated set of acronym and
state-firm names, then measured (`R/12_coverage_audit.R`):

| Measure | Before | After |
|---------|--------|-------|
| Distinct organisations indexed | 594 | 1,231 |
| Capture of clearly-named companies (ending "Limited"/"Ltd"), direct | 73% | 90% |
| Effective capture (counting conflations whose real company is captured under a clean name) | — | 94% |
| Agency acronyms (ZAMMSA, NAPSA, ZPPA) captured | no | yes |
| Names with a connector joined ("Henina Engineering **and** Construction", "Nitrogen Chemicals **of** Zambia") | no | yes |

The direct figure is 90%. Of the ~10% not matched, inspection shows almost all
are extraction artifacts the index correctly rejects: sentence fragments
("Construction of Cancer AVIC International Limited"), two firms joined by "and"
("Ministry and NMS Infrastructure Limited"), and table noise. The real company
inside each is captured under a clean name, which is why effective coverage is
94%. The handful genuinely missed are initials-heavy names (for example
"H.M Milling Ltd", "V.B.S General Dealers Ltd"), dropped because their only
long word is a generic one.

The index is a strong, measured sample of the organisations named, not a
complete register; the citable layer remains the 34 deep-verified contracts.

## Method

Reproducible, one command: `Rscript R/11_qa_sampling.R` (random seed 42). For
each sampled row the script re-opens the **cited page** in the
`pdftotext -layout` text of that year's report and checks that the thing the
row claims is actually on that page:

- **Valued contracts** — the amount (integer part, comma-grouped) appears on the cited page.
- **Supplier cases** — the supplier's distinctive name token appears on the cited page.
- **Supplier index** — the name token appears on at least one of the pages the index lists for it.

Generic company words (Limited, Company, Construction, International, Zambia…)
are stripped before picking a name token, so a match is on the distinctive part
of the name, not boilerplate. Full per-row results are in
`data_clean/qa_sample_checks.csv`.

## Result

| Layer | Sampled | Matched the cited page | Pass rate |
|-------|---------|------------------------|-----------|
| Valued contracts (182) | 30 | 30 | 100% |
| Supplier cases (89) | 20 | 19 | 95% |
| Supplier name index (454) | 25 | 25 | 100% |

Every sampled amount in the valued layer was found on the page it cites, and
every sampled supplier name in the index was found on a page it cites. The page
citations in the bulk layers hold up.

### The one non-match

One supplier-cases row did not match. Its supplier field is the literal
placeholder **"Suppliers in Table 13 (not fully extracted)"** on page 394 of the
2021 report — a marker left where a multi-supplier table was not transcribed in
full, not a real company name, so there was no name token to find. The page
citation itself is correct. This is a known gap in that one row, not a wrong
attribution.

## What this does and does not establish

- It establishes that the **page citations are sound**: the amounts and names sit on the pages the data points to, so a reader can always go to the page and see the source.
- It does **not** establish that every supplier name is spelled exactly as registered, that an amount is the final contract value rather than an interim figure, or that the ministry attribution on an auto-extracted valued row is the contracting ministry rather than the Head the page sits under. Those need the deep-verify pass, which is why only 34 contracts carry the "verified" flag.
- The samples are small (30 / 20 / 25). A 100% sample pass means the true error rate is low, not provably zero.

## Before any name is published

Treat the **verified** layer (the 34, and the supplier cases that have been
spot-checked) as citable. Treat an **unverified** valued row as "the report
names this amount on this page" — true to the page, but supplier and detail
still need the deep-verify pass before the name is put forward publicly. The
review note in `docs/review_request.md` asks an outside reader to confirm this
before the named-supplier material goes out.
