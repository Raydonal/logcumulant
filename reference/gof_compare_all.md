# Compare all candidate distributions

Runs
[`gof_analyze`](https://raydonal.github.io/logcumulant/reference/gof_analyze.md)
across all six (or a chosen subset of) families and returns a comparison
table, the natural entry point for model selection.

## Usage

``` r
gof_compare_all(
  x,
  dists = .LC_DISTS,
  use_bootstrap = FALSE,
  B = NULL,
  seed = NULL
)
```

## Arguments

- x:

  Numeric vector of positive observations.

- dists:

  Character vector of distribution names to compare.

- use_bootstrap:

  Logical; compute bootstrap p-values.

- B:

  Integer; bootstrap replicates.

- seed:

  Optional integer random seed.

## Value

A `data.frame` with one row per distribution.

## Examples

``` r
set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
gof_compare_all(x)
#>              Dist     T2_23       p_23     T2_123       p_123     T2_full
#> stat      Weibull 1.9590333 0.16161675  1.8658000 0.393411162    5.000957
#> stat1     Frechet 5.2359017 0.02212534  4.4883471 0.034126659 4113.214050
#> stat2       Gamma 0.3934405 0.53049646  0.7876504 0.674471959    4.730608
#> stat3    InvGamma 3.6298746 0.05675109  3.2014231 0.073574221  120.898217
#> stat4   LogNormal 1.6022557 0.20558384 11.9586816 0.002530494   33.662751
#> stat5 LogLogistic 1.5658338 0.21081308  2.6950815 0.259878581   44.216213
#>             p_full        AD        AD_p        CvM      CvM_p       AIC
#> stat  4.157634e-01 0.2521823 0.969230114 0.03958870 0.93525830  95.54654
#> stat1 0.000000e+00 4.1051498 0.007747193 0.62275242 0.01966918 149.14571
#> stat2 3.160719e-01 0.2871135 0.947512539 0.05763947 0.82884540  96.05410
#> stat3 3.434008e-25 2.1314915 0.077858274 0.36098370 0.09182039 127.17324
#> stat4 8.737987e-07 0.7742083 0.500018348 0.13612076 0.43478243 104.88754
#> stat5 5.785431e-09 0.6966964 0.561599126 0.10631019 0.55481587 103.45802
```
