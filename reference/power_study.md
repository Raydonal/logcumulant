# Empirical power study

Monte Carlo study of the power of the three \\T^2\\ tests and the AD/CvM
tests against a set of alternative distributions, with optional
size-correction.

## Usage

``` r
power_study(
  n = 100,
  Nsim = 1000,
  eta = 0.05,
  alternatives = names(.ALT_CONFIGS),
  use_bootstrap = FALSE,
  B = NULL,
  seed = 2025,
  verbose = TRUE
)
```

## Arguments

- n:

  Integer; sample size.

- Nsim:

  Integer; number of Monte Carlo replications.

- eta:

  Numeric; nominal significance level.

- alternatives:

  Character vector of alternative names to evaluate.

- use_bootstrap:

  Logical; use bootstrap calibration.

- B:

  Integer; bootstrap replicates.

- seed:

  Integer random seed.

- verbose:

  Logical; print progress.

## Value

A `data.frame` of empirical power by test and alternative.

## Examples

``` r
# \donttest{
power_study(n = 100, Nsim = 100)
#> Frechet      done (valid=100): T2_23=0.520 T2_123=0.160 T2_full=1.000 AD=0.960 CvM=0.900
#> Gamma        done (valid=100): T2_23=0.770 T2_123=0.700 T2_full=0.810 AD=0.000 CvM=0.000
#> InvGamma     done (valid=100): T2_23=0.810 T2_123=0.400 T2_full=1.000 AD=0.590 CvM=0.390
#> LogNormal    done (valid=100): T2_23=1.000 T2_123=0.990 T2_full=0.990 AD=0.130 CvM=0.060
#> LogLogistic  done (valid=100): T2_23=0.330 T2_123=0.440 T2_full=0.960 AD=0.370 CvM=0.300
#> $Frechet
#> $Frechet$power
#>   T2_23_chi  T2_123_chi T2_full_chi     T2_23_F    T2_123_F   T2_full_F 
#>        0.52        0.16        1.00        0.50        0.16        1.00 
#>          AD         CvM 
#>        0.96        0.90 
#> 
#> $Frechet$valid
#> [1] 100
#> 
#> 
#> $Gamma
#> $Gamma$power
#>   T2_23_chi  T2_123_chi T2_full_chi     T2_23_F    T2_123_F   T2_full_F 
#>        0.77        0.70        0.81        0.77        0.70        0.76 
#>          AD         CvM 
#>        0.00        0.00 
#> 
#> $Gamma$valid
#> [1] 100
#> 
#> 
#> $InvGamma
#> $InvGamma$power
#>   T2_23_chi  T2_123_chi T2_full_chi     T2_23_F    T2_123_F   T2_full_F 
#>        0.81        0.40        1.00        0.81        0.38        1.00 
#>          AD         CvM 
#>        0.59        0.39 
#> 
#> $InvGamma$valid
#> [1] 100
#> 
#> 
#> $LogNormal
#> $LogNormal$power
#>   T2_23_chi  T2_123_chi T2_full_chi     T2_23_F    T2_123_F   T2_full_F 
#>        1.00        0.99        0.99        1.00        0.99        0.99 
#>          AD         CvM 
#>        0.13        0.06 
#> 
#> $LogNormal$valid
#> [1] 100
#> 
#> 
#> $LogLogistic
#> $LogLogistic$power
#>   T2_23_chi  T2_123_chi T2_full_chi     T2_23_F    T2_123_F   T2_full_F 
#>        0.33        0.44        0.96        0.32        0.44        0.96 
#>          AD         CvM 
#>        0.37        0.30 
#> 
#> $LogLogistic$valid
#> [1] 100
#> 
#> 
# }
```
