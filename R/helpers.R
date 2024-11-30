load_processed_data <- function(
  external_debt, debtors = NULL, creditors = NULL, selected_year = 2022
) {
  if (!is.null(debtors)) {
    processed_data <- external_debt |>
      filter(from %in% debtors & 
               year == selected_year) 
  }
  if (!is.null(creditors)) {
    processed_data <- external_debt |>
      filter(to %in% creditors & 
               year == selected_year) 
  }
  processed_data
}

format_debt <- function(x, decimals = 2) {
  formatted <- sapply(x, function(value) {
    if (abs(value) < 1e7) {
      formatted_value <- sprintf(paste0("%.", decimals, "f"), value / 1e6)
      paste0(formatted_value, "M")
    } else {
      formatted_value <- sprintf(paste0("%.", decimals, "f"), value / 1e9)
      paste0(formatted_value, "B")
    }
  })
  formatted
}

format_title <- function(id, value, type) {
  prefix <- if_else(
    type == "debtor", "<br>Received: ", "<br>Provided: "
  )

  debt <- format_debt(value)

  title <- str_c(
    id, prefix, debt, " USD"
  )
  title
}

format_label <- function(id) {
  label <- str_wrap(id, width = 20)
  label
}

create_nodes <- function(external_debt_sub) {
  
  total_debt <- sum(external_debt_sub$value)
  
  nodes <- external_debt_sub |> 
    group_by(id = from, type = "debtor", color = "Country") |> 
    summarize(value = sum(value),
              .groups = "drop") |> 
    bind_rows(
      external_debt_sub |> 
        group_by(id = to, type = "creditor", color = counterpart_type) |> 
        summarize(value = sum(value),
                  .groups = "drop")
    ) |> 
    mutate(
      title = format_title(id, value, type),
      label = format_label(id),
      size = value / total_debt,
      color = case_when(
        color == "Other" ~ "#C46231",
        color == "Country" ~ "#3193C4",
        color == "Global MDBs" ~ "#AB31C4",
        color == "Bondholders" ~ "#4AC431"
      )
    )
  nodes
}

create_edges <- function(external_debt_sub) {
  edges <- external_debt_sub |> 
    select(from, to) |> 
    mutate(
      shadow = TRUE, 
      color = "grey",
      smooth = TRUE
    )
  edges
}

visualize_network <- function(external_debt_sub) {
  nodes <- create_nodes(external_debt_sub)
  edges <- create_edges(external_debt_sub)
  
  visNetwork(
    nodes, edges, width = "100%", height = "600px"
  ) |> 
    visNodes(shape = "dot") |> 
    visLayout(randomSeed = 42)
}