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

#' @export
debtor_ui <- function(id) {
  ns <- NS(id)
  fluidRow(
    box(
      width = 12,
      title = "Debtor-Centric View",
      p("Pick countries to visualize their relationships to their creditors."),
      fluidRow(
        column(6, selectizeInput(ns("debtors"), "Select debtors", selected = NULL, choices = NULL, multiple = TRUE)),
        column(6,  selectInput(ns("yearDebtors"), "Pick a year", selected = NULL, choices = NULL))
      ),
      actionButton(ns("debtorsButton"), "Update debtor network"),
      withSpinner(
        visNetworkOutput(ns("debtorsNetwork")),
        color = "black"
      )
    )
  )
}

box::use(
  ../logic/load_data[load_processed_data],
  ../logic/visualize_network[...]
)

#' @export
debtor_server <- function(
  id, input_options
) {
  moduleServer(id, function(input, output, session) {

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
        debtors = input$debtors, selected_year = input$yearDebtors
      )
    })

    output$debtorsNetwork <- renderVisNetwork({
      req(processed_data_debtors())
      visualize_network(processed_data_debtors())
    })

    delay(1000, click("debtorsButton"))
  })
}