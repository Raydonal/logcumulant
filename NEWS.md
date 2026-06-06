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
