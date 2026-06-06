# Kurtosis-skewness diagram

Draws the kurtosis-skewness diagnostic diagram on the original scale
(skewness \\\gamma_3\\ versus excess kurtosis \\\gamma_4\\), including
the feasible-region boundary \\\gamma_4 = \gamma_3^2 - 2\\, theoretical
loci, bootstrap cloud, and 95% concentration ellipse.

## Usage

``` r
kurtosis_diagram(
  data,
  data_name = "Dataset",
  B = NULL,
  seed = 42,
  level = 0.95,
  xlim = c(-1.5, 4),
  ylim = c(-3, 16)
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
kurtosis_diagram(reliability_datasets$Yarn, "Yarn", B = 200)
```
