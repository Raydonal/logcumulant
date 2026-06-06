# Closed-form Fisher information matrix

Per-sample (unit) Fisher information matrix for the supported families.
The Weibull/Frechet matrix uses the corrected positive-definite form
derived in the methodology.

## Usage

``` r
fisher_closed(dist, theta)
```

## Arguments

- dist:

  Character; distribution name.

- theta:

  Numeric length-2 parameter vector.

## Value

A 2 by 2 Fisher information matrix.

## Examples

``` r
fisher_closed("Weibull", c(2, 1))
#>            [,1]       [,2]
#> [1,]  0.4559202 -0.4227843
#> [2,] -0.4227843  4.0000000
```
