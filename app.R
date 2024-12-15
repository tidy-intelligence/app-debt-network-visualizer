box::use(
  shiny[
    fluidPage, fluidRow, column, selectInput, selectizeInput, actionButton,
    updateSelectizeInput, updateSelectInput, eventReactive, req, shinyApp
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
  app/logic/load_data[load_processed_data, load_input_options],
  app/logic/visualize_network[...]
)

# UI ---------------------------------------------------------------------

ui <- fluidPage(
  
  useShinyjs(),
  
  # Custom styling
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  # App title
  fluidRow(
    box(
      width = 12, 
      h1("Visualize Global Debt Networks"),
      p("The following network visualizations are based on the World Bank International Debt Statistics (IDS) as provided through the ", 
        a("'wbids'", href = "https://teal-insights.github.io/r-wbids/"), 
        "R package. The data includes all low- and middle-income countries that report public and publicly guaranteed external debt to the World Bank’s Debtor Reporting System (DRS). For technical details on this app, see the corresponding blog post on ", 
        a("tidy-intelligence.com", href = "https://blog.tidy-intelligence.com/posts/international-external-debt-network/"), "."
      )
    )
  ),
  
  # Debtor-Centric View
  fluidRow(
    box(
      width = 12,
      title = "Debtor-Centric View",
      p("Pick countries to visualize their relationships to their creditors."),
      fluidRow(
        column(6, selectizeInput("debtors", "Select debtors", selected = NULL, choices = NULL, multiple = TRUE)),
        column(6,  selectInput("yearDebtors", "Pick a year", selected = NULL, choices = NULL))
      ),
      actionButton("debtorsButton", "Update debtor network"),
      withSpinner(
        visNetworkOutput("debtorsNetwork"),
        color = "black"
      )
    )
  ),
  # Creditor-Centric View
  fluidRow(
    box(
      width = 12,
      title = "Creditor-Centric View",
      p("Pick counterparts to visualize their relationships to their debtors."),
      fluidRow(
        column(6, selectizeInput("creditors", "Select creditors", selected = NULL, choices = NULL, multiple = TRUE)),
        column(6,  selectInput("yearCreditors", "Pick a year", selected = NULL, choices = NULL))
      ),
      actionButton("creditorsButton", "Update creditor network"),
      withSpinner(
        visNetworkOutput("creditorsNetwork"),
        color = "black"
      )
    )
  )
)

# Server ------------------------------------------------------------------

server <- function(input, output, session) {

  input_options <- load_input_options()
  
  updateSelectizeInput(
    session,
    "debtors",
    server = TRUE,
    choices = input_options$available_debtors,
    selected = c("Nigeria", "Cameroon")
  )

  updateSelectizeInput(
    session,
    "creditors",
    server = TRUE,
    choices = input_options$available_creditors,
    selected = c("Austria", "Switzerland")
  )
  
  updateSelectInput(
    session,
    "yearDebtors",
    choices = input_options$available_years,
    selected = max(input_options$available_years)
  )
  
  updateSelectInput(
    session,
    "yearCreditors",
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
  
  delay(1000, click("debtorsButton"))
  delay(1000, click("creditorsButton"))
}

# Run app -----------------------------------------------------------------

shinyApp(ui, server)
