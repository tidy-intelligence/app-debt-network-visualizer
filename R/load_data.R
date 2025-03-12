#' @keywords internal
#' @noRd
load_processed_data <- function(
  debtors = NULL,
  creditors = NULL,
  selected_year = 2022
) {
  duckdb_path <- system.file(
    "debt-network-visualizer.duckdb",
    package = "debtnetworkvisualizer"
  )

  con <- dbConnect(duckdb(), duckdb_path)
  external_debt <- tbl(con, "external_debt")

  if (!is.null(debtors)) {
    processed_data <- external_debt |>
      filter(.data$from %in% debtors & .data$year == selected_year) |>
      collect()
  }
  if (!is.null(creditors)) {
    processed_data <- external_debt |>
      filter(.data$to %in% creditors & .data$year == selected_year) |>
      collect()
  }
  dbDisconnect(con)

  processed_data
}

#' @keywords internal
#' @noRd
load_input_options <- function() {
  duckdb_path <- system.file(
    "debt-network-visualizer.duckdb",
    package = "debtnetworkvisualizer"
  )

  con <- dbConnect(duckdb(), duckdb_path)
  external_debt <- tbl(con, "external_debt")

  available_debtors <- external_debt |>
    distinct(.data$from) |>
    arrange(.data$from) |>
    pull()

  available_creditors <- external_debt |>
    distinct(.data$to) |>
    arrange(.data$to) |>
    pull()

  available_years <- external_debt |>
    distinct(.data$year) |>
    arrange(desc(.data$year)) |>
    pull()

  dbDisconnect(con)

  list(
    "available_debtors" = available_debtors,
    "available_creditors" = available_creditors,
    "available_years" = available_years
  )
}
