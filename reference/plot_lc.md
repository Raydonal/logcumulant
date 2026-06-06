# Quick log-cumulant plot

Convenience wrapper around
[`log_cumulant_diagram`](https://raydonal.github.io/logcumulant/reference/log_cumulant_diagram.md)
providing the compact `plot_lc(data = x, B = 100)` interface requested
for quick diagnostics. `plot.lc` is kept as an alias for backward
compatibility.

## Usage

``` r
plot_lc(data, B = 100, data_name = "Sample", seed = 42, ...)
```

## Arguments

- data:

  Numeric vector of positive observations.

- B:

  Integer; bootstrap replicates.

- data_name:

  Character; label used in the title.

- seed:

  Integer random seed.

- ...:

  Further arguments passed to
  [`log_cumulant_diagram`](https://raydonal.github.io/logcumulant/reference/log_cumulant_diagram.md).

## Value

A `ggplot` object.

## Examples

``` r
data(reliability_datasets)
plot_lc(reliability_datasets$BallBearing, B = 100)
```
