box::use(
  shiny[
    fluidPage, fluidRow, column, selectInput, selectizeInput, actionButton,
    updateSelectizeInput, updateSelectInput, eventReactive, req, shinyApp
  ],
  shinydashboard[box],
  htmltools[tags, h1, p, a]
)

#' @export
title_ui <- function() {
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
  )
}

#' @export
title_server <- function() {}
