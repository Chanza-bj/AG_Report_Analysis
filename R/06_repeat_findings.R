# =============================================================================
# 06_repeat_findings.R  -  Which finding categories recur every comparable year,
# and in which direction. Comparable category values exist for 2021-2023 only.
# Output: data_clean/repeat_findings.csv
# =============================================================================
suppressMessages({library(readr);library(dplyr);library(tidyr);library(stringr)})

c <- read_csv("data_clean/findings_by_category_tidy.csv", show_col_types = FALSE)
pick <- tibble(financial_year = c(2021L,2022L,2023L), report_year = c(2022L,2023L,2023L))
s <- c |> inner_join(pick, by = c("financial_year","report_year"))

wide <- s |>
  mutate(cat = str_squish(str_to_title(category_std))) |>
  group_by(cat) |>
  summarise(y2021 = sum(amount_kwacha[financial_year==2021], na.rm=TRUE),
            y2022 = sum(amount_kwacha[financial_year==2022], na.rm=TRUE),
            y2023 = sum(amount_kwacha[financial_year==2023], na.rm=TRUE),
            years_present = n_distinct(financial_year[!is.na(amount_kwacha)]),
            .groups = "drop") |>
  mutate(direction = case_when(
            years_present < 3 ~ "not every year",
            y2023 > y2022 & y2022 > y2021 ~ "rose every year",
            y2023 < y2022 & y2022 < y2021 ~ "fell every year",
            TRUE ~ "mixed")) |>
  arrange(desc(years_present), desc(y2023))

write_csv(wide, "data_clean/repeat_findings.csv")
cat("categories recurring in all 3 comparable years:", sum(wide$years_present==3), "of", nrow(wide), "\n")
cat("of those, rose every year:", sum(wide$direction=="rose every year"), "\n\n")
print(wide |> filter(years_present==3) |> select(cat, y2021, y2022, y2023, direction) |> head(14), n=14)
