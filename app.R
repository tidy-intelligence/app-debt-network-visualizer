box::use(
  shiny[fluidPage, shinyApp],
  htmltools[tags],
  shinyjs[useShinyjs]
)

box::use(
  app/logic/load_data[load_input_options],
  app/view/title[...],
  app/view/debtor[...],
  app/view/creditor[...]
)

# UI ---------------------------------------------------------------------

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  title_ui(),
  debtor_ui("debtor"),
  creditor_ui("creditor")
)

# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  input_options <- load_input_options()
  title_server()
  debtor_server("debtor", input_options)
  creditor_server("creditor", input_options)
}

# Run app -----------------------------------------------------------------

shinyApp(ui, server)
