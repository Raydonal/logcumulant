# Analytic Jacobian of log-cumulants with respect to parameters

Returns the analytic Jacobian \\\mathbf{J}\_{\mathcal{V}} = \partial
\kappa\_{\mathcal{V}} / \partial \theta\\ for the selected set of
cumulant orders, used in the construction of the \\T^2\\ statistics.

## Usage

``` r
jacobian_J(dist, theta, V)
```

## Arguments

- dist:

  Character; distribution name.

- theta:

  Numeric length-2 parameter vector.

- V:

  Integer vector of cumulant orders (e.g. `c(2,3)`).

## Value

A `length(V)` by 2 numeric matrix.

## Examples

``` r
jacobian_J("Weibull", c(2, 1), V = c(2, 3))
#>            [,1] [,2]
#> [1,] -0.4112335    0
#> [2,]  0.4507713    0
```
