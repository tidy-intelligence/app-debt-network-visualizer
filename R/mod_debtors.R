#' debtors UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_debtors_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      full_screen = TRUE,
      layout_sidebar(
        sidebar = sidebar(
          selectizeInput(
            ns("debtors"),
            "Select debtors",
            selected = NULL,
            choices = NULL,
            multiple = TRUE
          ),
          selectInput(
            ns("yearDebtors"),
            "Pick a year",
            selected = NULL,
            choices = NULL
          ),
          actionButton(
            ns("debtorsButton"),
            "Update network",
            class = "btn-primary"
          )
        ),
        withSpinner(
          visNetworkOutput(ns("debtorsNetwork"))
        )
      )
    ),
    card(
      data_source()
    )
  )
}

#' debtors Server Functions
#'
#' @noRd
mod_debtors_server <- function(id, input_options) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    updateSelectizeInput(
      session,
      "debtors",
      server = TRUE,
      choices = input_options$available_debtors,
      selected = c("Nigeria", "Cameroon")
    )

    updateSelectInput(
      session,
      "yearDebtors",
      choices = input_options$available_years,
      selected = max(input_options$available_years)
    )

    processed_data_debtors <- eventReactive(input$debtorsButton, {
      req(input$debtors, input$yearDebtors)
      load_processed_data(
        debtors = input$debtors,
        selected_year = input$yearDebtors
      )
    })

    output$debtorsNetwork <- renderVisNetwork({
      req(processed_data_debtors())
      visualize_network(processed_data_debtors())
    })

    delay(1000, click("debtorsButton"))
  })
}
