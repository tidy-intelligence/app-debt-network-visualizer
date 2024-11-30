# Grammar
library(dplyr)
library(dbplyr)
library(tidyr)
library(stringr)

# Data fetching & storing
library(wbids)
library(duckdb)

# Shiny
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyjs)

# Visualization
library(visNetwork)

# Helper functions
source("R/helpers.R")

# Load data --------------------------------------------------------------

con <- dbConnect(duckdb(), "data/debt-network-visualizer.duckdb")

external_debt <- tbl(con, "external_debt") |> 
  collect() 

dbDisconnect(con)

available_debtors <- distinct(external_debt, from) |> 
  arrange(from) |> 
  pull()
available_creditors <- distinct(external_debt, to) |> 
  arrange(to) |> 
  pull()
available_years <- distinct(external_debt, year) |>
  arrange(desc(year)) |> 
  pull()

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
      shinycssloaders::withSpinner(
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
      shinycssloaders::withSpinner(
        visNetworkOutput("creditorsNetwork"),
        color = "black"
      )
    )
  )
)

# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  updateSelectizeInput(
    session,
    "debtors",
    server = TRUE,
    choices = available_debtors,
    selected = c("Nigeria", "Cameroon")
  )

  updateSelectizeInput(
    session,
    "creditors",
    server = TRUE,
    choices = available_creditors,
    selected = c("Austria", "Switzerland")
  )
  
  updateSelectInput(
    session,
    "yearDebtors",
    choices = available_years,
    selected = max(available_years)
  )
  
  updateSelectInput(
    session,
    "yearCreditors",
    choices = available_years,
    selected = max(available_years)
  )
  
  processed_data_debtors <- eventReactive(input$debtorsButton, {
    req(input$debtors, input$yearDebtors)  # Ensure inputs are valid
    load_processed_data(
      external_debt, debtors = input$debtors, selected_year = input$yearDebtors
    )
  })

  output$debtorsNetwork <- renderVisNetwork({
    req(processed_data_debtors())
    visualize_network(processed_data_debtors())
  })

  processed_data_creditors <- eventReactive(input$creditorsButton, {
    req(input$creditors, input$yearCreditors)
    load_processed_data(
      external_debt, creditors = input$creditors, selected_year = input$yearCreditors
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
