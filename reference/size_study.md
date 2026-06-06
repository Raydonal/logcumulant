# Empirical size (Type I error) study

Monte Carlo study of the empirical size of the three \\T^2\\ tests
(asymptotic and, optionally, bootstrap) and the AD/CvM tests under a
true null model, across several sample sizes.

## Usage

``` r
size_study(
  sample_sizes = c(30, 50, 100, 200),
  Nsim = 1000,
  eta = 0.05,
  use_bootstrap = FALSE,
  B = NULL,
  seed = 2025,
  verbose = TRUE
)
```

## Arguments

- sample_sizes:

  Integer vector of sample sizes.

- Nsim:

  Integer; number of Monte Carlo replications.

- eta:

  Numeric; nominal significance level.

- use_bootstrap:

  Logical; include bootstrap calibration.

- B:

  Integer; bootstrap replicates.

- seed:

  Integer random seed.

- verbose:

  Logical; print progress.

## Value

A `data.frame` of empirical rejection rates.

## Examples

``` r
# \donttest{
size_study(sample_sizes = c(30, 50), Nsim = 100)
#> n=30 done (valid=100): T2_23_chi=0.040 T2_123_chi=0.100 T2_full_chi=0.480
#> n=50 done (valid=100): T2_23_chi=0.170 T2_123_chi=0.130 T2_full_chi=0.450
#> $`30`
#> $`30`$size
#>   T2_23_chi  T2_123_chi T2_full_chi     T2_23_F    T2_123_F   T2_full_F 
#>        0.04        0.10        0.48        0.03        0.08        0.38 
#>          AD         CvM 
#>        0.00        0.00 
#> 
#> $`30`$valid
#> [1] 100
#> 
#> 
#> $`50`
#> $`50`$size
#>   T2_23_chi  T2_123_chi T2_full_chi     T2_23_F    T2_123_F   T2_full_F 
#>        0.17        0.13        0.45        0.17        0.12        0.44 
#>          AD         CvM 
#>        0.00        0.00 
#> 
#> $`50`$valid
#> [1] 100
#> 
#> 
# }
```
