# Akaike information criterion for a fitted family

Akaike information criterion for a fitted family

## Usage

``` r
aic_value(x, dist, fit)
```

## Arguments

- x:

  Numeric vector of positive observations.

- dist:

  Character; distribution name.

- fit:

  A
  [`mle_fit`](https://raydonal.github.io/logcumulant/reference/mle_fit.md)
  object for `dist`.

## Value

Numeric AIC value.

## Examples

``` r
set.seed(1); x <- rdist(100, "Gamma", c(3, 0.5))
aic_value(x, "Gamma", mle_fit(x, "Gamma"))
#> [1] 211.661
```
