#' @keywords internal
#' @noRd
load_processed_data <- function(
  debtors = NULL,
  creditors = NULL,
  selected_year = 2022
) {
  external_debt <- system.file(
    "external_debt.parquet",
    package = "debtnetworkvisualizer"
  ) |>
    read_parquet()

  if (!is.null(debtors)) {
    processed_data <- external_debt |>
      filter(.data$from %in% debtors & .data$year == selected_year)
  }
  if (!is.null(creditors)) {
    processed_data <- external_debt |>
      filter(.data$to %in% creditors & .data$year == selected_year)
  }

  processed_data
}

#' @keywords internal
#' @noRd
load_input_options <- function() {
  available_debtors <- system.file(
    "available_debtors.parquet",
    package = "debtnetworkvisualizer"
  ) |>
    read_parquet() |>
    pull()

  available_creditors <- system.file(
    "available_creditors.parquet",
    package = "debtnetworkvisualizer"
  ) |>
    read_parquet() |>
    pull()

  available_years <- system.file(
    "available_years.parquet",
    package = "debtnetworkvisualizer"
  ) |>
    read_parquet() |>
    pull()

  list(
    "available_debtors" = available_debtors,
    "available_creditors" = available_creditors,
    "available_years" = available_years
  )
}
