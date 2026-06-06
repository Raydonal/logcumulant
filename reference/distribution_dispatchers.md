# Distribution dispatchers for the six reliability families

Unified density, random-number, and distribution-function interfaces for
the six positive-support families supported by the package: Weibull,
Frechet, Gamma, Inverse-Gamma, Log-Normal, and Log-Logistic. The
two-parameter vector `theta = c(par1, par2)` is interpreted as
`(shape, scale)` for all families except Log-Normal, where it is
`(meanlog, sdlog)`.

## Usage

``` r
ldist(x, dist, theta, log = TRUE)

rdist(n, dist, theta)

pdist(q, dist, theta)
```

## Arguments

- x, q:

  Numeric vector of quantiles (positive support).

- dist:

  Character; one of `"Weibull"`, `"Frechet"`, `"Gamma"`, `"InvGamma"`,
  `"LogNormal"`, `"LogLogistic"`.

- theta:

  Numeric length-2 parameter vector (see Details).

- log:

  Logical; if `TRUE` (default) `ldist` returns log-density.

- n:

  Integer; number of random values to draw.

## Value

`ldist` returns the (log-)density, `rdist` a random sample of length
`n`, and `pdist` the cumulative distribution function, each evaluated at
the supplied points.

## Examples

``` r
set.seed(1)
x <- rdist(100, "Weibull", c(2, 1))
head(ldist(x, "Weibull", c(2, 1)))
#> [1] -0.4918365 -0.3011502 -0.1564607 -0.5733714 -0.6725822 -0.5307606
pdist(1, "Gamma", c(3, 0.5))
#> [1] 0.3233236
```
