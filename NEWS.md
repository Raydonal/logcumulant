# logcumulant 0.1.1

* Corrected the closed-form Fisher information matrices returned by
  `fisher_closed()` for two families, to match the numerical observed
  information used by default in `mle_fit()`:
    - Frechet now uses the correct off-diagonal (cross) term `+(1 - gamma)/b`.
      Weibull and Frechet share the same diagonal entries but differ in the
      sign of the cross term (log-inversion duality); the previous version
      returned the Weibull cross term for both.
    - Log-Logistic now returns `diag((pi^2 + 3)/(9 a^2), a^2/(3 b^2))`. The
      previous version used `diag(pi^2/(3 a^2), 1/b^2)`, whose (1,1) entry is
      the second log-cumulant `Var(log X)` rather than the shape information,
      and whose (2,2) entry omitted the factor `a^2/3`.
* Added a regression test (`tests/validate_fisher.R`) comparing `fisher_closed()`
  against the Monte Carlo observed information for all six families.
* Note: default inference (`T2_bootstrap`, `size_study`, `power_study`) is
  unaffected, since the covariance is estimated from the observed information
  (`mle_fit()`), not from these closed forms; `fisher_closed()` is only used as
  a fallback when the numerical Hessian is not invertible.

# logcumulant 0.1.0

* Initial release.
* Three nested Hotelling-type T-squared goodness-of-fit statistics
  (`T2_all`, `T2_bootstrap`) with parametric-bootstrap calibration.
* Three diagnostic diagrams (`log_cumulant_diagram`, `kurtosis_diagram`,
  `cv_diagram`), a combined panel (`three_diagrams`), a multi-dataset overlay
  (`multi_lc_diagram`), and the quick `plot_lc` interface.
* Maximum-likelihood fitting for six reliability families with a C++ core.
* Anderson--Darling and Cramer--von Mises tests and AIC via
  `gof_compare_all`.
* Size and power simulation utilities (`size_study`, `power_study`).
* Nine bundled reliability datasets (`reliability_datasets`).
