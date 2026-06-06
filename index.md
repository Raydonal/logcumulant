# logcumulant

`logcumulant` provides goodness-of-fit tests and diagnostic diagrams for
positive-support reliability data, built on **Mellin log-cumulants**. It
implements a family of three complementary Hotelling-type statistics
together with three moment-ratio-style diagrams, all calibrated by a
parametric bootstrap for reliable finite-sample inference.

The package is built around a few design choices:

- **Three nested tests.** `T2_(2,3)` targets log-scale shape (dispersion
  and skewness); `T2_(1,2,3)` adds the entropy-related first
  log-cumulant; and `T2_(1,...,6)` exploits higher-order log-cumulants
  for tail discrimination.
- **Bootstrap-first inference.** The discrepancy covariance is typically
  ill-conditioned, so the asymptotic chi-squared reference is unreliable
  in finite samples; the parametric bootstrap restores correct size.
- **Diagnostic diagrams.** Log-cumulant, kurtosis-skewness, and
  coefficient-of-variation diagrams, each overlaying the theoretical
  loci of six reliability families with a bootstrap cloud and a 95%
  concentration ellipse.
- **Six reliability families.** Weibull, Frechet, Gamma, Inverse-Gamma,
  Log-Normal, and Log-Logistic, all fitted by maximum likelihood with a
  fast C++ core.

## Installation

The package depends on a small set of CRAN packages. Install them first
if needed:

``` r

install.packages(c("Rcpp", "RcppArmadillo", "MASS", "VGAM", "actuar",
                   "numDeriv", "goftest", "ggplot2", "gridExtra"))
```

Then install the development version from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("raydonal/logcumulant")
```

`remotes` (or `devtools`) installs the required dependencies
automatically.

## A 30-second tour

``` r

library(logcumulant)
data(reliability_datasets)

bb <- reliability_datasets$BallBearing

# Quick log-cumulant diagram with bootstrap cloud
plot_lc(bb, B = 100)

# The three diagnostic diagrams
three_diagrams(bb, "Ball Bearing")

# Compare all six families (T2, AD, CvM, AIC with bootstrap p-values)
gof_compare_all(bb, use_bootstrap = TRUE)
```

## When to use which tool

| Goal | Function |
|----|----|
| Quick log-cumulant diagram | [`plot_lc()`](https://raydonal.github.io/logcumulant/reference/plot_lc.md) |
| Log-cumulant diagram (full control) | [`log_cumulant_diagram()`](https://raydonal.github.io/logcumulant/reference/log_cumulant_diagram.md) |
| Kurtosis-skewness diagram | [`kurtosis_diagram()`](https://raydonal.github.io/logcumulant/reference/kurtosis_diagram.md) |
| Coefficient-of-variation diagram | [`cv_diagram()`](https://raydonal.github.io/logcumulant/reference/cv_diagram.md) |
| All three diagrams together | [`three_diagrams()`](https://raydonal.github.io/logcumulant/reference/three_diagrams.md) |
| Several datasets on one diagram | [`multi_lc_diagram()`](https://raydonal.github.io/logcumulant/reference/multi_lc_diagram.md) |
| The three T-squared statistics | [`T2_all()`](https://raydonal.github.io/logcumulant/reference/T2_all.md) |
| Bootstrap p-values | [`T2_bootstrap()`](https://raydonal.github.io/logcumulant/reference/T2_bootstrap.md) |
| Full model comparison | [`gof_compare_all()`](https://raydonal.github.io/logcumulant/reference/gof_compare_all.md) |
| Size / power simulation | [`size_study()`](https://raydonal.github.io/logcumulant/reference/size_study.md), [`power_study()`](https://raydonal.github.io/logcumulant/reference/power_study.md) |

## Citation

If you use `logcumulant` in academic work, please cite:

> Santos, C. C. F., Ospina, R., Espinheira, P., & Oliveira, M. (2025).
> *Goodness-of-Fit Tests Based on Mellin Statistics for Reliability
> Data*.

## License

GPL-3.
