# logcumulant: Goodness-of-Fit Tests and Diagrams Based on Mellin Log-Cumulants

The logcumulant package implements a family of three complementary
goodness-of-fit tests based on an adaptation of Hotelling's \\T^2\\
statistic applied to vectors of sample log-cumulants (Mellin statistics)
for positive-support reliability data, together with three diagnostic
diagrams.

## Main functions

- Diagrams:

  [`log_cumulant_diagram`](https://raydonal.github.io/logcumulant/reference/log_cumulant_diagram.md),
  [`kurtosis_diagram`](https://raydonal.github.io/logcumulant/reference/kurtosis_diagram.md),
  [`cv_diagram`](https://raydonal.github.io/logcumulant/reference/cv_diagram.md),
  [`three_diagrams`](https://raydonal.github.io/logcumulant/reference/three_diagrams.md),
  [`multi_lc_diagram`](https://raydonal.github.io/logcumulant/reference/multi_lc_diagram.md),
  [`plot_lc`](https://raydonal.github.io/logcumulant/reference/plot_lc.md)

- Tests:

  [`T2_all`](https://raydonal.github.io/logcumulant/reference/T2_all.md),
  [`T2_bootstrap`](https://raydonal.github.io/logcumulant/reference/T2_bootstrap.md),
  [`gof_compare_all`](https://raydonal.github.io/logcumulant/reference/gof_compare_all.md)

- Simulation:

  [`size_study`](https://raydonal.github.io/logcumulant/reference/size_study.md),
  [`power_study`](https://raydonal.github.io/logcumulant/reference/power_study.md)

- Building blocks:

  [`mle_fit`](https://raydonal.github.io/logcumulant/reference/mle_fit.md),
  [`theoretical_lc`](https://raydonal.github.io/logcumulant/reference/theoretical_lc.md),
  [`jacobian_J`](https://raydonal.github.io/logcumulant/reference/jacobian_J.md),
  [`fisher_closed`](https://raydonal.github.io/logcumulant/reference/fisher_closed.md)

## Data

Nine reliability datasets are bundled as
[`reliability_datasets`](https://raydonal.github.io/logcumulant/reference/reliability_datasets.md).

## See also

Useful links:

- <https://github.com/raydonal/logcumulant>

- <https://raydonal.github.io/logcumulant/>

- Report bugs at <https://github.com/raydonal/logcumulant/issues>

## Author

**Maintainer**: Raydonal Ospina <raydonal@de.ufpe.br>
([ORCID](https://orcid.org/0000-0002-9884-9090))

Authors:

- Raydonal Ospina <raydonal@de.ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-9884-9090))
