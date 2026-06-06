# logcumulant <img src="man/figures/logo.png" align="right" height="120" alt="logcumulant logo" />

<!-- badges: start -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![R-CMD-check](https://github.com/raydonal/logcumulant/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/raydonal/logcumulant/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`logcumulant` provides goodness-of-fit tests and diagnostic diagrams for
positive-support reliability data, built on **Mellin log-cumulants**. It
implements a family of three complementary Hotelling-type \eqn{T^2} statistics
together with three moment-ratio-style diagrams, all calibrated by a parametric
bootstrap for reliable finite-sample inference.

The package is built around a few design choices:

- **Three nested tests.** `T2_(2,3)` targets log-scale shape (dispersion and
  skewness); `T2_(1,2,3)` adds the entropy-related first log-cumulant; and
  `T2_(1,...,6)` exploits higher-order log-cumulants for tail discrimination.
- **Bootstrap-first inference.** The discrepancy covariance is typically
  ill-conditioned, so the asymptotic chi-squared reference is unreliable in
  finite samples; the parametric bootstrap restores correct size.
- **Diagnostic diagrams.** Log-cumulant, kurtosis-skewness, and
  coefficient-of-variation diagrams, each overlaying the theoretical loci of
  six reliability families with a bootstrap cloud and a 95% concentration
  ellipse.
- **Six reliability families.** Weibull, Frechet, Gamma, Inverse-Gamma,
  Log-Normal, and Log-Logistic, all fitted by maximum likelihood with a fast
  C++ core.

## Installation

The package depends on a small set of CRAN packages. Install them first if
needed:

```r
install.packages(c("Rcpp", "RcppArmadillo", "MASS", "VGAM", "actuar",
                   "numDeriv", "goftest", "ggplot2", "gridExtra"))
```

Then install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("raydonal/logcumulant")
```

`remotes` (or `devtools`) installs the required dependencies automatically.

## A 30-second tour

```r
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
| --- | --- |
| Quick log-cumulant diagram | `plot_lc()` |
| Log-cumulant diagram (full control) | `log_cumulant_diagram()` |
| Kurtosis-skewness diagram | `kurtosis_diagram()` |
| Coefficient-of-variation diagram | `cv_diagram()` |
| All three diagrams together | `three_diagrams()` |
| Several datasets on one diagram | `multi_lc_diagram()` |
| The three T-squared statistics | `T2_all()` |
| Bootstrap p-values | `T2_bootstrap()` |
| Full model comparison | `gof_compare_all()` |
| Size / power simulation | `size_study()`, `power_study()` |

## Citation

If you use `logcumulant` in academic work, please cite:

> Santos, C. C. F., Ospina, R., Espinheira, P., & Oliveira, M. (2025).
> *Goodness-of-Fit Tests Based on Mellin Statistics for Reliability Data*.

## License

GPL-3.
