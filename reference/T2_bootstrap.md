# Parametric bootstrap p-values for the \\T^2\\ statistics

Computes parametric-bootstrap p-values for the three nested \\T^2\\
statistics. The bootstrap calibrates the ill-conditioned reference
distribution and is the recommended mode of inference in finite samples.

## Usage

``` r
T2_bootstrap(x, dist, B = NULL, fit = NULL, seed = NULL)
```

## Arguments

- x:

  Numeric vector of positive observations.

- dist:

  Character; null distribution name.

- B:

  Integer; number of bootstrap replicates (default chosen adaptively).

- fit:

  Optional precomputed
  [`mle_fit`](https://raydonal.github.io/logcumulant/reference/mle_fit.md)
  object.

- seed:

  Optional integer random seed for reproducibility.

## Value

A list with the observed statistics and the bootstrap p-values `p_boot`
for the three versions.

## Examples

``` r
set.seed(1); x <- rdist(80, "Weibull", c(2, 1))
T2_bootstrap(x, "Weibull", B = 199, seed = 1)
#> $p_boot
#>     T2_23    T2_123 T2_123456 
#> 0.2663317 0.4924623 0.9095477 
#> 
#> $T2_obs
#>     T2_23    T2_123 T2_123456 
#>  3.463943  1.436895  4.549316 
#> 
#> $B
#> [1] 199
#> 
#> $valid
#> [1] 199 199 199
#> 
#> $obs
#> $obs$T2_23
#> $obs$T2_23$T2
#> [1] 3.463943
#> 
#> $obs$T2_23$df
#> [1] 2
#> 
#> $obs$T2_23$p_chisq
#> [1] 0.1769352
#> 
#> $obs$T2_23$p_F
#> [1] 0.1875672
#> 
#> $obs$T2_23$theta
#> [1] 2.1822646 0.9466456
#> 
#> $obs$T2_23$d
#> [1] -0.03491823  0.08416583
#> 
#> $obs$T2_23$Kd
#>             [,1]        [,2]
#> [1,]  0.03180058 -0.09836024
#> [2,] -0.09836024  0.41884421
#> 
#> $obs$T2_23$eigmin
#> [1] 0.008238473
#> 
#> $obs$T2_23$conv
#> [1] TRUE
#> 
#> 
#> $obs$T2_123
#> $obs$T2_123$T2
#> [1] 1.436895
#> 
#> $obs$T2_123$df
#> [1] 2
#> 
#> $obs$T2_123$p_chisq
#> [1] 0.4875085
#> 
#> $obs$T2_123$p_F
#> [1] 0.495108
#> 
#> $obs$T2_123$theta
#> [1] 2.1822646 0.9466456
#> 
#> $obs$T2_123$d
#> [1]  0.006791661 -0.034918233  0.084165834
#> 
#> $obs$T2_123$Kd
#>             [,1]        [,2]        [,3]
#> [1,] -0.02706361  0.04234727 -0.06986446
#> [2,]  0.04234727  0.03180058 -0.09836024
#> [3,] -0.06986446 -0.09836024  0.41884421
#> 
#> $obs$T2_123$eigmin
#> [1] -0.05000833
#> 
#> $obs$T2_123$conv
#> [1] TRUE
#> 
#> 
#> $obs$T2_123456
#> $obs$T2_123456$T2
#> [1] 4.549316
#> 
#> $obs$T2_123456$df
#> [1] 5
#> 
#> $obs$T2_123456$p_chisq
#> [1] 0.4733124
#> 
#> $obs$T2_123456$p_F
#> [1] 0.5095497
#> 
#> $obs$T2_123456$theta
#> [1] 2.1822646 0.9466456
#> 
#> $obs$T2_123456$d
#> [1]  0.006791661 -0.034918233  0.084165834 -0.165819787  0.395811401
#> [6] -1.138654780
#> 
#> $obs$T2_123456$Kd
#>             [,1]        [,2]        [,3]        [,4]       [,5]       [,6]
#> [1,] -0.02706361  0.04234727 -0.06986446  0.20718340 -0.6980358   2.365976
#> [2,]  0.04234727  0.03180058 -0.09836024 -0.04578578  0.8430599  -3.834249
#> [3,] -0.06986446 -0.09836024  0.41884421 -0.46718244 -0.4236734   4.458325
#> [4,]  0.20718340 -0.04578578 -0.46718244  0.66010112  0.5343117  -6.580394
#> [5,] -0.69803582  0.84305989 -0.42367343  0.53431174 -2.4669832  10.940290
#> [6,]  2.36597600 -3.83424924  4.45832456 -6.58039433 10.9402896 -22.459217
#> 
#> $obs$T2_123456$eigmin
#> [1] -29.85051
#> 
#> $obs$T2_123456$conv
#> [1] TRUE
#> 
#> 
#> $obs$fit
#> $obs$fit$theta
#> [1] 2.1822646 0.9466456
#> 
#> $obs$fit$Sigma
#>           [,1]      [,2]
#> [1,] 2.8093552 0.2443764
#> [2,] 0.2443764 0.2094311
#> 
#> $obs$fit$loglik
#> [1] -37.55932
#> 
#> $obs$fit$conv
#> [1] TRUE
#> 
#> 
#> 
```
