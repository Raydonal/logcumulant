## Submission summary

This is a patch update (0.1.0 -> 0.1.1). It corrects the closed-form Fisher
information matrices returned by `fisher_closed()` for the Frechet and
Log-Logistic families so that they agree with the numerical observed
information already used by default in `mle_fit()`. The correction was prompted
by a referee report on the companion manuscript. Default inference in the
package is unchanged, because the bootstrap and simulation routines estimate the
covariance from the observed information rather than from these closed forms;
`fisher_closed()` is only a fallback for the rare non-invertible-Hessian case.

I am aware of the guidance to space updates by one to two months. This is a
correctness fix to an exported function rather than a feature change, which is
why it is submitted sooner.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Test environments

* local: Ubuntu 24.04, R 4.6.0
* win-builder: R-devel (x86_64-w64-mingw32)
* GitHub Actions: ubuntu-latest, R release

## Notes

* New submission.
* The package contains compiled C++ code (Rcpp/RcppArmadillo) for the
  log-cumulant recursion and the quadratic-form assembly.
* The "possibly misspelled words" flagged in the DESCRIPTION are proper
  names (Espinheira, Oliveira, Ospina, Mellin, Frechet, Hotelling) and
  standard statistical terms (cumulant, cumulants).
