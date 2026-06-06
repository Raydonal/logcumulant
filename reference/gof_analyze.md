# Full goodness-of-fit analysis for one distribution

Fits a single family and returns the three \\T^2\\ statistics (with
asymptotic and, optionally, bootstrap p-values), the AD and CvM tests,
and the AIC, in a single row.

## Usage

``` r
gof_analyze(x, dist, use_bootstrap = FALSE, B = NULL, seed = NULL)
```

## Arguments

- x:

  Numeric vector of positive observations.

- dist:

  Character; distribution name.

- use_bootstrap:

  Logical; compute bootstrap p-values.

- B:

  Integer; bootstrap replicates.

- seed:

  Optional integer random seed.

## Value

A one-row `data.frame` of statistics and p-values.

## Examples

``` r
set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
gof_analyze(x, "Weibull")
#> $dist
#> [1] "Weibull"
#> 
#> $theta
#> [1] 2.2534731 0.9586402
#> 
#> $conv
#> [1] TRUE
#> 
#> $T2_23
#>      stat        df         p 
#> 1.9590333 1.0000000 0.1616167 
#> 
#> $T2_123
#>      stat        df         p 
#> 1.8658000 2.0000000 0.3934112 
#> 
#> $T2_full
#>      stat        df         p 
#> 5.0009573 5.0000000 0.4157634 
#> 
#> $AD
#>      stat         p 
#> 0.2521823 0.9692301 
#> 
#> $CvM
#>      stat         p 
#> 0.0395887 0.9352583 
#> 
#> $AIC
#> [1] 95.54654
#> 
```
