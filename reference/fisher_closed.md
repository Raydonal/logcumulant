# Closed-form Fisher information matrix

Per-observation (unit) Fisher information matrix for the supported
families. Weibull and Frechet share the same diagonal entries but differ
in the SIGN of the off-diagonal (cross) term (log-inversion duality).
The Log-Logistic matrix is the corrected form; an earlier version used
the second log-cumulant Var(log X) = pi^2 / (3 a^2) for the (1,1) entry,
which is not the shape information. All forms match the numerical
observed information.

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

A 2 by 2 per-observation Fisher information matrix.

## Examples

``` r
fisher_closed("Weibull", c(2, 1))
#>            [,1]       [,2]
#> [1,]  0.4559202 -0.4227843
#> [2,] -0.4227843  4.0000000
fisher_closed("Frechet", c(2, 1))
#>           [,1]      [,2]
#> [1,] 0.4559202 0.4227843
#> [2,] 0.4227843 4.0000000
```
