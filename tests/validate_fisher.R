# ============================================================================
# Regression test: closed-form Fisher information vs numerical observed
# information for all six families. Guards against the 0.1.0 Frechet cross-term
# and Log-Logistic diagonal errors corrected in 0.1.1.
# ============================================================================
suppressMessages({
  library(logcumulant)
  library(numDeriv)
})

# Per-observation observed information from a large simulated sample.
obs_info <- function(dist, theta, n = 4e5, seed = 1) {
  set.seed(seed)
  x <- rdist(n, dist, theta)
  nll <- function(th) {
    if (any(th <= 0) && dist != "LogNormal") return(1e10)
    v <- ldist(x, dist, th, log = TRUE)
    if (any(!is.finite(v))) return(1e10)
    -sum(v)
  }
  numDeriv::hessian(nll, theta) / n
}

cases <- list(
  Weibull     = c(2, 1.5),
  Frechet     = c(3, 1.0),
  Gamma       = c(4, 0.5),
  InvGamma    = c(5, 4.0),
  LogNormal   = c(0, 0.7),
  LogLogistic = c(4, 1.0)
)

tol <- 5e-2   # Monte Carlo tolerance (per-observation scale)
fail <- FALSE
for (dist in names(cases)) {
  th <- cases[[dist]]
  Icf <- fisher_closed(dist, th)
  Iob <- obs_info(dist, th)
  err <- max(abs(Icf - Iob))
  status <- if (err < tol) "OK" else "FAIL"
  if (err >= tol) fail <- TRUE
  cat(sprintf("  %-12s max|closed - observed| = %.4f  [%s]\n", dist, err, status))
}

# Explicit guard on the two corrected forms.
a <- 3
stopifnot(abs(fisher_closed("Frechet", c(a, 1))[1, 2] - (1 - (-psigamma(1, 0))) / 1) < 1e-10)  # cross term positive
stopifnot(abs(fisher_closed("LogLogistic", c(a, 1))[1, 1] - (pi^2 + 3) / (9 * a^2)) < 1e-10)
stopifnot(abs(fisher_closed("LogLogistic", c(a, 1))[2, 2] - a^2 / 3) < 1e-10)

if (fail) stop("Closed-form Fisher information does not match observed information.")
cat("All Fisher information checks passed.\n")
