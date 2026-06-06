# Combined three-panel diagnostic figure

Arranges the log-cumulant, kurtosis-skewness, and
coefficient-of-variation diagrams side by side for a single dataset.

## Usage

``` r
three_diagrams(data, data_name = "Dataset", B = NULL, seed = 42)
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

## Value

A `gtable` drawn via
[`gridExtra::grid.arrange`](https://rdrr.io/pkg/gridExtra/man/arrangeGrob.html).

## Examples

``` r
data(reliability_datasets)
three_diagrams(reliability_datasets$Yarn, "Yarn", B = 200)
```
