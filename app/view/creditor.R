box::use(
  shiny[
    NS, fluidPage, fluidRow, column, selectInput, selectizeInput, actionButton,
    updateSelectizeInput, updateSelectInput, eventReactive, req, shinyApp,
    moduleServer
  ],
  shinydashboard[box],
  shinycssloaders[withSpinner],
  htmltools[tags, h1, p, a],
  shinyjs[useShinyjs, delay, click],
  visNetwork[
    visNetworkOutput, renderVisNetwork
  ]
)

box::use(
  ../logic/load_data[load_processed_data],
  ../logic/visualize_network[...]
)

#' @export
creditor_ui <- function(id) {
  ns <- NS(id)
  fluidRow(
    box(
      width = 12,
      title = "Creditor-Centric View",
      p("Pick counterparts to visualize their relationships to their debtors."),
      fluidRow(
        column(6, selectizeInput(ns("creditors"), "Select creditors", selected = NULL, choices = NULL, multiple = TRUE)),
        column(6,  selectInput(ns("yearCreditors"), "Pick a year", selected = NULL, choices = NULL))
      ),
      actionButton(ns("creditorsButton"), "Update creditor network"),
      withSpinner(
        visNetworkOutput(ns("creditorsNetwork")),
        color = "black"
      )
    )
  )
}

#' @export
creditor_server <- function(
  id, input_options
) {
  moduleServer(id, function(input, output, session) {
    updateSelectizeInput(
      session,
      "creditors",
      server = TRUE,
      choices = input_options$available_creditors,
      selected = c("Austria", "Switzerland")
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
        creditors = input$creditors, selected_year = input$yearCreditors
      )
    })
  
    output$creditorsNetwork <- renderVisNetwork({
      req(processed_data_creditors())
      visualize_network(processed_data_creditors())
    })
    
    delay(1000, click("creditorsButton"))
  })
}