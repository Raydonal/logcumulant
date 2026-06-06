# Hotelling-type \\T^2\\ statistic for one cumulant set

Computes the log-cumulant \\T^2\\ goodness-of-fit statistic for a single
choice of cumulant orders `V`, with the asymptotic chi-squared reference
using the corrected (full-rank) degrees of freedom.

## Usage

``` r
T2_one(x, dist, V, fit = NULL)
```

## Arguments

- x:

  Numeric vector of positive observations.

- dist:

  Character; null distribution name.

- V:

  Integer vector of cumulant orders (e.g. `c(2,3)`).

- fit:

  Optional precomputed
  [`mle_fit`](https://raydonal.github.io/logcumulant/reference/mle_fit.md)
  object.

## Value

A list with the statistic `T2`, degrees of freedom `df`, and asymptotic
p-value `p_asym`.

## Examples

``` r
set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
T2_one(x, "Weibull", V = c(2, 3))
#> $T2
#> [1] 1.959033
#> 
#> $df
#> [1] 1
#> 
#> $p_chisq
#> [1] 0.1616167
#> 
#> $p_F
#> [1] 0.1647425
#> 
#> $theta
#> [1] 2.2534731 0.9586402
#> 
#> $d
#> [1] -0.03627176  0.08444942
#> 
#> $Kd
#>             [,1]        [,2]
#> [1,]  0.02121533 -0.09598141
#> [2,] -0.09598141  0.39585293
#> 
#> $eigmin
#> [1] -0.001943338
#> 
#> $conv
#> [1] TRUE
#> 
```
