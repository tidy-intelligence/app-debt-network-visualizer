#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  input_options <- load_input_options()

  mod_debtors_server("debtors_1", input_options)

  mod_creditors_server("creditors_1", input_options)
}
