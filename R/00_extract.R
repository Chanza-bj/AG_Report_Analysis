# =============================================================================
# 00_extract.R  -  Extraction pipeline (documents how figures were obtained)
#
# This script turns the five source PDFs into (a) layout-preserving text and
# (b) rendered images of the specific pages that hold the figures used in this
# project. The cleaned CSVs in data_clean/ were transcribed by reading those
# rendered images, because automated text extraction misaligns the table
# columns in the summary, budget, and Table-of-Contents pages.
#
# Requirements: R package 'pdftools'. The PDFs are NOT in this repository
# (they are large public documents). Download them from the Office of the
# Auditor General of Zambia (https://www.ago.gov.zm) and set PDF_DIR below.
# =============================================================================

library(pdftools)

# --- Configure: folder containing the five source PDFs ----------------------
PDF_DIR <- Sys.getenv("AG_PDF_DIR", unset = "C:/Users/user/Downloads")
OUT     <- "extraction"
dir.create(OUT, showWarnings = FALSE)

# File names as published
files <- c(
  "2021" = "Auditor-Generals-Main-Report-2021.pdf",
  "2022" = "Auditor-Generals-Main-Report-2022.pdf",
  "2023" = "Auditor-Generals-Main-Report-2023.pdf",
  "2024" = "Auditor-General-Report-for-the-Financial-Year-2024-ONLINE-PUBLICATION.pdf",
  "2025" = "AUDITOR-GENERAL-REPORT-On-the-Accounts-of-the-Republic-for-the-Financial-Year-Ended-31st-Dec-2025.pdf"
)

# Key pages that were read to transcribe the data (physical PDF page numbers).
# trend  = Trend Analysis of Audit Findings table (category values)
# toc    = Table of Contents (ministry/paragraph inventory)
# stmt   = Statement B, Budget Execution (fiscal outturn)
# exec   = executive-summary narrative pages (notable observations)
key_pages <- list(
  "2021" = list(toc = 6:7, exec = 8:16),                 # no trend table, no Statement B
  "2022" = list(toc = 5:6, trend = 8,  stmt = 19),
  "2023" = list(toc = 6:7, trend = 9,  stmt = 22),
  "2024" = list(toc = 6:7, stmt = 24,  exec = 8:12),     # no trend table
  "2025" = list(toc = 5:6, stmt = 21,  exec = 7:11)      # no trend table
)

for (yr in names(files)) {
  pdf <- file.path(PDF_DIR, files[[yr]])
  if (!file.exists(pdf)) { message("Missing PDF for ", yr, ": ", pdf); next }

  # (a) layout-preserving text of the whole report
  txt <- pdf_text(pdf)  # pdftools uses the same poppler engine as pdftotext -layout
  writeLines(txt, file.path(OUT, sprintf("AG_%s_text.txt", yr)), useBytes = TRUE)

  # (b) render the key pages to PNG for visual transcription / verification
  for (kind in names(key_pages[[yr]])) {
    for (p in key_pages[[yr]][[kind]]) {
      out_png <- file.path(OUT, sprintf("%s_%s_p%d.png", toupper(kind), yr, p))
      try(pdf_convert(pdf, format = "png", pages = p, dpi = 175, filenames = out_png),
          silent = TRUE)
    }
  }
  message("Extracted ", yr)
}

message("Done. Review rendered pages in '", OUT, "/' against data_clean/ CSVs.")
