
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{debtnetworkvisualizer}`

Visualize global debt networks based on World Bank International Debt
Statistics (IDS). You can find a deployed version of the app at
[app-debt-network-visualizer.tidy-intelligence.com](https://app-debt-network-visualizer.tidy-intelligence.com/)

## Installation

You can install the development version of `{debtnetworkvisualizer}`
like so:

``` r
pak::pak("tidy-intelligence/app-debt-network-visualizer")
```

## Run

You can launch the application by running:

``` r
debtnetworkvisualizer::run_app()
```

## About

You are reading the doc about version : 0.1.0

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-03-12 18:40:36 CET"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading debtnetworkvisualizer
#> ── R CMD check results ──────────────────────── debtnetworkvisualizer 0.1.0 ────
#> Duration: 12.4s
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> 0 errors ✔ | 0 warnings ✔ | 1 note ✖
```
