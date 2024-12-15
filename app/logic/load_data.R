box::use(
  dplyr[...],
  dbplyr[...],
  DBI[dbConnect, dbGetQuery, dbDisconnect],
  duckdb[duckdb],
)

#' @export
load_processed_data <- function(
  debtors = NULL, creditors = NULL, selected_year = 2022
) {

  con <- dbConnect(duckdb(), "data/debt-network-visualizer.duckdb")
  external_debt <- tbl(con, "external_debt")

  if (!is.null(debtors)) {
    processed_data <- external_debt |>
      filter(from %in% debtors & 
               year == selected_year) |> 
      collect()
  }
  if (!is.null(creditors)) {
    processed_data <- external_debt |>
      filter(to %in% creditors & 
               year == selected_year) |> 
      collect()
  }
  dbDisconnect(con)

  processed_data
}

#' @export
load_input_options <- function() {
  con <- dbConnect(duckdb(), "data/debt-network-visualizer.duckdb")
  external_debt <- tbl(con, "external_debt")

  available_debtors <- distinct(external_debt, from) |> 
    arrange(from) |> 
    pull()

  available_creditors <- distinct(external_debt, to) |> 
    arrange(to) |> 
    pull()

  available_years <- distinct(external_debt, year) |>
    arrange(desc(year)) |> 
    pull()
    
  dbDisconnect(con)

  list(
    "available_debtors" = available_debtors,
    "available_creditors" = available_creditors,
    "available_years" = available_years
  )
}