# =============================================================================
# Narrative "notable observations" from the executive summaries of the
# 2021, 2024 and 2025 reports, attributed to ministries by the Office itself.
#
# IMPORTANT: these are the AG's SELECTED notable items, not a comprehensive
# total of all findings for a ministry. Kwacha (ZMW) and US dollar (USD)
# amounts are summarised separately and never added together.
#
# Input : data_clean/notable_observations.csv
# Output: output/table_notable_by_ministry_year.csv
#         output/table_notable_usd.csv
#         output/chart5_notable_by_ministry.png
# =============================================================================

library(readr); library(dplyr); library(tidyr); library(stringr)
library(forcats); library(ggplot2); library(scales)

out_dir <- "output"

theme_ag <- theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(), plot.title.position = "plot",
        plot.caption = element_text(colour = "grey40", hjust = 0))
wrapcap <- function(x) str_wrap(x, 78)
SRC <- "Source: Office of the Auditor General, executive-summary notable observations (Zambia)."

obs <- read_csv("data_clean/notable_observations.csv",
                show_col_types = FALSE) %>%
  mutate(headline_amount = suppressWarnings(as.numeric(headline_amount)))

# Value by ministry and year, currencies kept apart
by_min_year <- obs %>%
  group_by(financial_year, ministry_std) %>%
  summarise(zmw_total = sum(headline_amount[currency == "ZMW"], na.rm = TRUE),
            usd_total = sum(headline_amount[currency == "USD"], na.rm = TRUE),
            n_observations = n(), .groups = "drop") %>%
  arrange(financial_year, desc(zmw_total))
write_csv(by_min_year, file.path(out_dir, "table_notable_by_ministry_year.csv"))

# USD-denominated observations listed on their own (not convertible here)
usd_items <- obs %>% filter(currency == "USD") %>%
  select(financial_year, ministry_std, observation, headline_amount,
         source_pdf_page, printed_page) %>%
  arrange(desc(headline_amount))
write_csv(usd_items, file.path(out_dir, "table_notable_usd.csv"))

# Chart 5: Kwacha notable amounts by ministry across the three narrative years.
# The single ZRA tax-arrears line (K85.78bn, 2021) is a stock figure that would
# dominate the scale, so it is excluded here and called out in the caption.
zmw_plot <- obs %>%
  filter(currency == "ZMW",
         !str_detect(observation, "tax arrears")) %>%
  group_by(ministry_std) %>%
  summarise(zmw_total = sum(headline_amount, na.rm = TRUE), .groups = "drop") %>%
  filter(zmw_total > 0) %>%
  slice_max(zmw_total, n = 12) %>%
  mutate(ministry_std = fct_reorder(ministry_std, zmw_total))

p5 <- ggplot(zmw_plot, aes(zmw_total/1e6, ministry_std)) +
  geom_col(fill = "#1b4965") +
  geom_text(aes(label = comma(zmw_total/1e6, accuracy = 1)), hjust = -0.1, size = 3) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Kwacha value of selected notable observations, by ministry",
       subtitle = "Executive-summary items, financial years 2021, 2024 and 2025 combined",
       x = "Kwacha (millions)", y = NULL,
       caption = wrapcap(paste(SRC,
         "Selected items only, not a comprehensive total. Excludes the ZRA tax-arrears stock figure (K85.78bn, 2021). US dollar items are shown separately."))) +
  theme_ag
ggsave(file.path(out_dir, "chart5_notable_by_ministry.png"), p5, width = 8.5, height = 5.5, dpi = 150)

cat("\n--- Notable observations: Kwacha and USD by ministry/year ---\n")
print(by_min_year, n = 60)
cat("\n--- Largest USD notable observations ---\n")
print(usd_items, n = 20)
cat("\nWritten to", out_dir, "\n")
