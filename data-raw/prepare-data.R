library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(wbids)
library(duckdb)

geographies <- ids_list_geographies() |> 
  filter(geography_type != "Region")

external_debt_raw <- geographies$geography_id |> 
  map_df(
    \(x) ids_get(x, "DT.DOD.DPPG.CD", "all", 2019, 2023),
    .progress = TRUE
  )

counterparts <- ids_list_counterparts()

external_debt <- external_debt_raw |> 
  filter(value > 0) |> 
  left_join(geographies, join_by(geography_id)) |> 
  left_join(counterparts, join_by(counterpart_id)) |> 
  filter(!counterpart_name %in% c("World", "Region")) |> 
  select(from = geography_name, to = counterpart_name, value, counterpart_type, year) |> 
  mutate(to = str_squish(to))

con <- dbConnect(duckdb(), "data/debt-network-visualizer.duckdb")

dbWriteTable(con, "external_debt", external_debt, overwrite = TRUE)

dbDisconnect(con)
