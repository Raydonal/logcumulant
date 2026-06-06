# Log-cumulant diagram

Draws the log-cumulant diagnostic diagram (\\\kappa_3\\ versus
\\\kappa_2\\) with the theoretical loci of the six reference
distributions, a bootstrap cloud of the sample estimate, and a 95%
concentration ellipse.

## Usage

``` r
log_cumulant_diagram(
  data,
  data_name = "Dataset",
  B = NULL,
  seed = 42,
  level = 0.95,
  xlim = c(-2, 2),
  ylim = c(0, 2)
)
```

## Arguments

- data:

  Numeric vector of positive observations.

- data_name:

  Character; label used in the title.

- B:

  Integer; bootstrap replicates (default chosen adaptively from `n`).

- seed:

  Integer random seed.

- level:

  Numeric; ellipse confidence level (default 0.95).

- xlim, ylim:

  Numeric length-2 axis limits.

## Value

A `ggplot` object.

## Examples

``` r
data(reliability_datasets)
log_cumulant_diagram(reliability_datasets$Yarn, "Yarn", B = 200)
```
