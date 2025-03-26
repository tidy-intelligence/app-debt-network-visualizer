#' creditors UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_creditors_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      full_screen = TRUE,
      layout_sidebar(
        sidebar = sidebar(
          selectizeInput(
            ns("creditors"),
            "Select creditors",
            selected = NULL,
            choices = NULL,
            multiple = TRUE
          ),
          selectInput(
            ns("yearCreditors"),
            "Pick a year",
            selected = NULL,
            choices = NULL
          ),
          actionButton(
            ns("creditorsButton"),
            "Update network"
          )
        ),
        withSpinner(
          visNetworkOutput(ns("creditorsNetwork")),
          color = "black"
        )
      )
    ),
    card(
      data_source()
    )
  )
}

#' creditors Server Functions
#'
#' @noRd
mod_creditors_server <- function(id, input_options) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    updateSelectizeInput(
      session,
      "creditors",
      server = TRUE,
      choices = input_options$available_creditors,
      selected = c("United States", "China")
    )

    updateSelectInput(
      session,
      "yearCreditors",
      choices = input_options$available_years,
      selected = max(input_options$available_years)
    )

    processed_data_creditors <- eventReactive(input$creditorsButton, {
      req(input$creditors, input$yearCreditors)
      load_processed_data(
        creditors = input$creditors,
        selected_year = input$yearCreditors
      )
    })

    output$creditorsNetwork <- renderVisNetwork({
      req(processed_data_creditors())
      visualize_network(processed_data_creditors())
    })

    delay(1000, click("creditorsButton"))
  })
}
