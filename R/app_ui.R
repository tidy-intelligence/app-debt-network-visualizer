#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    bslib::page_fluid(
      title = "Debt Network Visualizer",
      navset_pill(
        nav_panel(
          title = "Debtor-Centric View",
          value = "debtors",
          mod_debtors_ui("debtors_1")
        ),
        nav_panel(
          title = "Creditor-Centric View",
          value = "creditors",
          mod_creditors_ui("creditors_1")
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Debt Network Visualizer"
    ),
    shinyjs::useShinyjs()
  )
}
