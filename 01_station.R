library(tidyverse)
library(sf)
library(jpgrid)

# station -----------------------------------------------------------------

grid80km <- grid_80km(5339)

# Source: https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N02-v2_3.html
# => Download by hand

unzip("station_2019/N02-19_GML.zip",
      exdir = "station_2019")

station_5339_2019 <- read_sf("station_2019/N02-19_Station.geojson") |>
  st_centroid() |>
  rename(railway_type = `鉄道区分`,
         line = `路線名`,
         company = `運営会社`,
         station = `駅名`) |>
  select(railway_type, line, company, station) |>

  # Regular railways only
  filter(railway_type %in% c("11", "12")) |>

  mutate(grid80km = geometry |>
           geometry_to_grid("80km")) |>
  filter(grid80km == .env$grid80km) |>
  select(!c(railway_type, grid80km))

write_sf(station_5339_2019, "station_5339_2019.gpkg")
