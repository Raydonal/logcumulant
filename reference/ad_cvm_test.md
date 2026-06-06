# Anderson-Darling and Cramer-von Mises tests

Computes the Anderson-Darling (AD) and Cramer-von Mises (CvM) statistics
and their p-values for a fitted distribution, based on the probability
integral transform.

## Usage

``` r
ad_cvm_test(x, dist, theta)
```

## Arguments

- x:

  Numeric vector of positive observations.

- dist:

  Character; distribution name.

- theta:

  Numeric length-2 parameter vector (typically MLE).

## Value

A list with `AD`, `AD_p`, `CvM`, `CvM_p`.

## Examples

``` r
set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
ad_cvm_test(x, "Weibull", c(2, 1))
#> $AD
#> [1] 0.8548376
#> 
#> $AD_p
#> [1] 0.4431183
#> 
#> $CvM
#> [1] 0.1224319
#> 
#> $CvM_p
#> [1] 0.4856639
#> 
```
