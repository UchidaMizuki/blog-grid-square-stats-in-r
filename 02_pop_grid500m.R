library(tidyverse)
library(fs)
library(arrow)

# 01_pop_grid500m ---------------------------------------------------------

# Source: https://www.e-stat.go.jp/gis/statmap-search?page=5&type=1&toukeiCode=00200521&toukeiYear=2015&aggregateUnit=H&serveyId=H002005112015&statsId=T000847
# grid80km: 5339
download.file("https://www.e-stat.go.jp/gis/statmap-search/data?statsId=T000847&code=5339&downloadType=2",
              "pop_grid500m_5339_2015.zip",
              mode = "wb",
              quiet = TRUE)

unzip("pop_grid500m_5339_2015.zip",
      exdir = "pop_grid500m_5339_2015")

pop_grid500m_5339_2015 <- dir_ls("pop_grid500m_5339_2015/",
                                 regexp = "txt$") |>
  read_csv(locale = locale(encoding = "shift-jis"),
           skip = 1,
           col_types = cols(.default = "c")) |>
  rename_with(~ c("KEY_CODE", "HTKSYORI", "HTKSAKI", "GASSAN"),
              1:4) |>
  rename_with(~ .x |>
                str_remove_all("\\s")) |>
  mutate(across(-(1:4),
                purrr::partial(parse_number,
                               na = "*"))) |>
  rename(grid500m = KEY_CODE,
         pop = `人口総数`) |>
  select(grid500m, pop)

write_parquet(pop_grid500m_5339_2015, "pop_grid500m_5339_2015.parquet")
