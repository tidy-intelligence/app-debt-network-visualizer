#' @keywords internal
#' @noRd
format_debt <- function(x, decimals = 2) {
  formatted <- sapply(x, function(value) {
    if (is.na(value)) {
      return(NA_character_)
    }
    if (abs(value) < 1e7) {
      formatted_value <- sprintf(paste0("%.", decimals, "f"), value / 1e6)
      return(paste0(formatted_value, "M"))
    } else {
      formatted_value <- sprintf(paste0("%.", decimals, "f"), value / 1e9)
      return(paste0(formatted_value, "B"))
    }
  })
  formatted
}

#' @keywords internal
#' @noRd
format_title <- function(id, value_from, value_to) {
  title <- case_when(
    value_from > 0 & value_to > 0 ~
      str_c(
        id,
        "<br>Received: ",
        format_debt(value_from),
        "<br>Provided: ",
        format_debt(value_to)
      ),
    value_from > 0 ~
      str_c(
        id,
        "<br>Received: ",
        format_debt(value_from)
      ),
    value_to > 0 ~
      str_c(
        id,
        "<br>Provided: ",
        format_debt(value_to)
      ),
    TRUE ~ NA_character_
  )
  title
}

#' @keywords internal
#' @noRd
format_label <- function(id) {
  label <- str_wrap(id, width = 20)
  label
}

#' @keywords internal
#' @noRd
create_nodes <- function(external_debt_sub) {
  total_debt <- sum(external_debt_sub$value)

  nodes <- external_debt_sub |>
    group_by(id = .data$from, color = "Country") |>
    summarize(value_from = sum(.data$value), .groups = "drop") |>
    bind_rows(
      external_debt_sub |>
        group_by(id = .data$to, color = .data$counterpart_type) |>
        summarize(value_to = sum(.data$value), .groups = "drop")
    ) |>
    group_by(.data$id, .data$color) |>
    summarize(
      across(c("value_from", "value_to"), \(x) sum(x, na.rm = TRUE)),
      .groups = "drop"
    ) |>
    mutate(
      title = format_title(.data$id, .data$value_from, .data$value_to),
      label = format_label(.data$id),
      value = coalesce(.data$value_from, 0) + coalesce(.data$value_to, 0),
      size = .data$value / total_debt,
      color = case_when(
        .data$color == "Other" ~ "#FBC9B7",
        .data$color == "Country" ~ "#333333",
        .data$color == "Global MDBs" ~ "#C9B7FB",
        .data$color == "Bondholders" ~ "#B7FBC9"
      )
    )
  nodes
}

#' @keywords internal
#' @noRd
create_edges <- function(external_debt_sub) {
  edges <- external_debt_sub |>
    select("from", "to") |>
    mutate(
      shadow = TRUE,
      color = "grey",
      smooth = TRUE
    )
  edges
}

#' @keywords internal
#' @noRd
visualize_network <- function(external_debt_sub) {
  nodes <- create_nodes(external_debt_sub)
  edges <- create_edges(external_debt_sub)

  visNetwork(
    nodes,
    edges,
    width = "100%",
    height = "100%"
  ) |>
    visNodes(shape = "dot") |>
    visLayout(randomSeed = 42)
}
