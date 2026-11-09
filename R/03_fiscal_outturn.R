# =============================================================================
# Budget execution and fiscal outturn, from "Statement B - Statement of
# Comparison of Budget and Actual Amounts (Budget Execution)" in each report.
# Available for 2022-2025 only; the 2021 report has no equivalent statement.
#
# Input : data_clean/fiscal_outturn.csv  (transcribed from rendered statement pages)
# Output: output/table_fiscal_outturn.csv
#         output/chart6_budget_execution.png
#         output/chart7_surplus_trend.png
# =============================================================================

library(readr); library(dplyr); library(ggplot2); library(scales); library(stringr)

root <- "E:/AG_Report_Analysis"; out_dir <- file.path(root, "output")
theme_ag <- theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(), plot.title.position = "plot",
        plot.caption = element_text(colour = "grey40", hjust = 0))
wrapcap <- function(x) str_wrap(x, 90)
SRC <- "Source: Office of the Auditor General, Statement B (Budget Execution), Zambia. 2021: no equivalent statement."

fisc <- read_csv(file.path(root, "data_clean/fiscal_outturn.csv"), show_col_types = FALSE) %>%
  mutate(budget_execution_pct = 100 * actual_payments / final_budget_payments,
         surplus_bn = surplus_deficit / 1e9)
write_csv(fisc %>% select(financial_year, final_budget_payments, actual_payments,
                          budget_execution_pct, surplus_deficit, surplus_bn,
                          source_pdf_page, printed_page),
          file.path(out_dir, "table_fiscal_outturn.csv"))

cat("\n--- Budget execution and surplus (2022-2025) ---\n")
print(fisc %>% select(financial_year, budget_execution_pct, surplus_bn))

f2 <- fisc %>% filter(!is.na(actual_payments))

# Chart 6: budget execution (actual payments / final budget)
p6 <- ggplot(f2, aes(factor(financial_year), budget_execution_pct)) +
  geom_col(fill = "#1b4965", width = 0.6) +
  geom_text(aes(label = sprintf("%.0f%%", budget_execution_pct)), vjust = -0.4, size = 3.6) +
  scale_y_continuous(limits = c(0, 100), expand = expansion(mult = c(0, 0.08))) +
  labs(title = "Budget execution: actual payments as a share of final budget",
       subtitle = "Zambia, financial years 2022-2025 (2021 not reported)",
       x = NULL, y = "Percent of final budget",
       caption = wrapcap(paste(SRC, "Execution was not monotonic: 76%, 88%, 82%, 86%."))) +
  theme_ag
ggsave(file.path(out_dir, "chart6_budget_execution.png"), p6, width = 7.5, height = 4.6, dpi = 150)

# Chart 7: fiscal surplus trend
p7 <- ggplot(f2, aes(factor(financial_year), surplus_bn)) +
  geom_col(fill = "#1b4965", width = 0.6) +
  geom_text(aes(label = comma(surplus_bn, accuracy = 0.1)), vjust = -0.4, size = 3.6) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "Reported fiscal surplus (actual receipts minus actual payments)",
       subtitle = "Zambia, financial years 2022-2025",
       x = NULL, y = "Kwacha (billions)", caption = wrapcap(SRC)) +
  theme_ag
ggsave(file.path(out_dir, "chart7_surplus_trend.png"), p7, width = 7.5, height = 4.6, dpi = 150)

cat("\nWritten to", out_dir, "\n")
