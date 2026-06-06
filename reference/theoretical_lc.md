# Theoretical log-cumulants

Closed-form theoretical log-cumulants
\\\kappa_1,\ldots,\kappa\_{order}\\ (Mellin cumulants of the second
kind) for a given family and parameter vector, as tabulated in the
methodology.

## Usage

``` r
theoretical_lc(dist, theta, order = 6)
```

## Arguments

- dist:

  Character; distribution name (see
  [`distribution_dispatchers`](https://raydonal.github.io/logcumulant/reference/distribution_dispatchers.md)).

- theta:

  Numeric length-2 parameter vector.

- order:

  Integer; highest cumulant order to return (default 6).

## Value

Numeric vector of length `order` with the log-cumulants.

## Examples

``` r
theoretical_lc("Weibull", c(2, 1))
#> [1] -0.2886078  0.4112335 -0.3005142  0.4058712 -0.7776958  1.9075182
theoretical_lc("Gamma", c(3, 0.5), order = 4)
#> [1]  0.2296372  0.3949341 -0.1541138  0.1189394
```
