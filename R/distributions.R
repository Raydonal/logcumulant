# ============================================================================
# distributions.R -- Distribution layer for the logcumulant package
# Six reliability distributions: Weibull, Frechet, Gamma, InvGamma,
# LogNormal, LogLogistic. Parametrizations verified empirically.
# Theory: Santos et al. (RAY-New.tex), Table of log-cumulants + Appendix A/B.
# ============================================================================

# Supported distributions
.LC_DISTS <- c("Weibull", "Frechet", "Gamma", "InvGamma", "LogNormal", "LogLogistic")

# ----------------------------------------------------------------------------
# Density (log), RNG, and CDF dispatchers.  theta = c(par1, par2).
#   Weibull/Frechet/Gamma/InvGamma/LogLogistic: (alpha, lambda)
#   LogNormal: (mu, sigma)
# ----------------------------------------------------------------------------
#' Distribution dispatchers for the six reliability families
#'
#' Unified density, random-number, and distribution-function interfaces for the
#' six positive-support families supported by the package: Weibull, Frechet,
#' Gamma, Inverse-Gamma, Log-Normal, and Log-Logistic. The two-parameter vector
#' \code{theta = c(par1, par2)} is interpreted as \code{(shape, scale)} for all
#' families except Log-Normal, where it is \code{(meanlog, sdlog)}.
#'
#' @param x,q Numeric vector of quantiles (positive support).
#' @param n Integer; number of random values to draw.
#' @param dist Character; one of \code{"Weibull"}, \code{"Frechet"},
#'   \code{"Gamma"}, \code{"InvGamma"}, \code{"LogNormal"}, \code{"LogLogistic"}.
#' @param theta Numeric length-2 parameter vector (see Details).
#' @param log Logical; if \code{TRUE} (default) \code{ldist} returns log-density.
#'
#' @return \code{ldist} returns the (log-)density, \code{rdist} a random sample
#'   of length \code{n}, and \code{pdist} the cumulative distribution function,
#'   each evaluated at the supplied points.
#'
#' @examples
#' set.seed(1)
#' x <- rdist(100, "Weibull", c(2, 1))
#' head(ldist(x, "Weibull", c(2, 1)))
#' pdist(1, "Gamma", c(3, 0.5))
#'
#' @name distribution_dispatchers
#' @export
ldist <- function(x, dist, theta, log = TRUE) {
  a <- theta[1]; b <- theta[2]
  switch(dist,
         Weibull     = dweibull(x, shape = a, scale = b, log = log),
         Frechet     = VGAM::dfrechet(x, shape = a, scale = b, log = log),
         Gamma       = dgamma(x, shape = a, scale = b, log = log),
         InvGamma    = actuar::dinvgamma(x, shape = a, scale = b, log = log),
         LogNormal   = dlnorm(x, meanlog = a, sdlog = b, log = log),
         LogLogistic = actuar::dllogis(x, shape = a, scale = b, log = log),
         stop("Unknown distribution: ", dist)
  )
}

#' @rdname distribution_dispatchers
#' @export
rdist <- function(n, dist, theta) {
  a <- theta[1]; b <- theta[2]
  switch(dist,
         Weibull     = rweibull(n, shape = a, scale = b),
         Frechet     = VGAM::rfrechet(n, shape = a, scale = b),
         Gamma       = rgamma(n, shape = a, scale = b),
         InvGamma    = actuar::rinvgamma(n, shape = a, scale = b),
         LogNormal   = rlnorm(n, meanlog = a, sdlog = b),
         LogLogistic = actuar::rllogis(n, shape = a, scale = b),
         stop("Unknown distribution: ", dist)
  )
}

#' @rdname distribution_dispatchers
#' @export
pdist <- function(q, dist, theta) {
  a <- theta[1]; b <- theta[2]
  switch(dist,
         Weibull     = pweibull(q, shape = a, scale = b),
         Frechet     = VGAM::pfrechet(q, shape = a, scale = b),
         Gamma       = pgamma(q, shape = a, scale = b),
         InvGamma    = actuar::pinvgamma(q, shape = a, scale = b),
         LogNormal   = plnorm(q, meanlog = a, sdlog = b),
         LogLogistic = actuar::pllogis(q, shape = a, scale = b),
         stop("Unknown distribution: ", dist)
  )
}

# ----------------------------------------------------------------------------
# Theoretical log-cumulants kappa_1..kappa_order  (Table tab:lc_extended)
# ----------------------------------------------------------------------------
#' Theoretical log-cumulants
#'
#' Closed-form theoretical log-cumulants \eqn{\kappa_1,\ldots,\kappa_{order}}
#' (Mellin cumulants of the second kind) for a given family and parameter
#' vector, as tabulated in the methodology.
#'
#' @param dist Character; distribution name (see \code{\link{distribution_dispatchers}}).
#' @param theta Numeric length-2 parameter vector.
#' @param order Integer; highest cumulant order to return (default 6).
#' @return Numeric vector of length \code{order} with the log-cumulants.
#' @examples
#' theoretical_lc("Weibull", c(2, 1))
#' theoretical_lc("Gamma", c(3, 0.5), order = 4)
#' @export
theoretical_lc <- function(dist, theta, order = 6) {
  a <- theta[1]; b <- theta[2]
  psi <- function(z, d) psigamma(z, d)
  k <- numeric(order)
  if (dist == "Weibull") {
    k[1] <- log(b) + psi(1, 0) / a
    for (nu in 2:order) k[nu] <- psi(1, nu - 1) / a^nu
  } else if (dist == "Frechet") {
    k[1] <- log(b) - psi(1, 0) / a
    for (nu in 2:order) k[nu] <- (-1)^nu * psi(1, nu - 1) / a^nu
  } else if (dist == "Gamma") {
    k[1] <- log(b) + psi(a, 0)
    for (nu in 2:order) k[nu] <- psi(a, nu - 1)
  } else if (dist == "InvGamma") {
    k[1] <- log(b) - psi(a, 0)
    for (nu in 2:order) k[nu] <- (-1)^nu * psi(a, nu - 1)
  } else if (dist == "LogNormal") {
    k[1] <- a
    if (order >= 2) k[2] <- b^2
    # k[nu] = 0 for nu >= 3
  } else if (dist == "LogLogistic") {
    k[1] <- log(b)
    for (nu in 2:order) {
      if (nu %% 2 == 1) k[nu] <- 0
      else k[nu] <- 2 * psi(1, nu - 1) / a^nu   # = e.g. 2*psi^(1)(1)/a^2 = pi^2/(3a^2)
    }
  } else stop("Unknown distribution: ", dist)
  k
}

# ----------------------------------------------------------------------------
# Jacobian J_V = d kappa_V / d theta  (p x 2), V = index set (e.g. c(2,3))
# Rows ordered as in V.  (Appendix A.)
# ----------------------------------------------------------------------------
#' Analytic Jacobian of log-cumulants with respect to parameters
#'
#' Returns the analytic Jacobian \eqn{\mathbf{J}_{\mathcal{V}} =
#' \partial \kappa_{\mathcal{V}} / \partial \theta} for the selected set of
#' cumulant orders, used in the construction of the \eqn{T^2} statistics.
#'
#' @param dist Character; distribution name.
#' @param theta Numeric length-2 parameter vector.
#' @param V Integer vector of cumulant orders (e.g. \code{c(2,3)}).
#' @return A \code{length(V)} by 2 numeric matrix.
#' @examples
#' jacobian_J("Weibull", c(2, 1), V = c(2, 3))
#' @export
jacobian_J <- function(dist, theta, V) {
  a <- theta[1]; b <- theta[2]
  psi <- function(z, d) psigamma(z, d)
  p <- length(V)
  J <- matrix(0, nrow = p, ncol = 2)
  for (i in seq_along(V)) {
    nu <- V[i]
    if (dist == "Weibull") {
      if (nu == 1) { J[i, 1] <- -psi(1, 0) / a^2; J[i, 2] <- 1 / b }
      else         { J[i, 1] <- -nu * psi(1, nu - 1) / a^(nu + 1); J[i, 2] <- 0 }
    } else if (dist == "Frechet") {
      if (nu == 1) { J[i, 1] <-  psi(1, 0) / a^2; J[i, 2] <- 1 / b }
      else         { J[i, 1] <- (-1)^nu * (-nu) * psi(1, nu - 1) / a^(nu + 1); J[i, 2] <- 0 }
    } else if (dist == "Gamma") {
      if (nu == 1) { J[i, 1] <- psi(a, 1); J[i, 2] <- 1 / b }
      else         { J[i, 1] <- psi(a, nu); J[i, 2] <- 0 }
    } else if (dist == "InvGamma") {
      if (nu == 1) { J[i, 1] <- -psi(a, 1); J[i, 2] <- 1 / b }
      else         { J[i, 1] <- (-1)^nu * psi(a, nu); J[i, 2] <- 0 }
    } else if (dist == "LogNormal") {
      # theta = (mu, sigma); k1=mu, k2=sigma^2, rest 0
      if (nu == 1) { J[i, 1] <- 1;        J[i, 2] <- 0 }
      else if (nu == 2) { J[i, 1] <- 0;   J[i, 2] <- 2 * b }
      else { J[i, 1] <- 0; J[i, 2] <- 0 }
    } else if (dist == "LogLogistic") {
      # k1=log lambda; even nu: k_nu = 2 psi^(nu-1)(1)/a^nu; odd nu>=3: 0
      if (nu == 1) { J[i, 1] <- 0; J[i, 2] <- 1 / b }
      else if (nu %% 2 == 0) { J[i, 1] <- -nu * 2 * psi(1, nu - 1) / a^(nu + 1); J[i, 2] <- 0 }
      else { J[i, 1] <- 0; J[i, 2] <- 0 }
    } else stop("Unknown distribution: ", dist)
  }
  J
}

# ----------------------------------------------------------------------------
# Closed-form Fisher information (per Appendix B), per-observation (n = 1).
# Used optionally; default estimation uses observed information.
# ----------------------------------------------------------------------------
#' Closed-form Fisher information matrix
#'
#' Per-observation (unit) Fisher information matrix for the supported families.
#' Weibull and Frechet share the same diagonal entries but differ in the SIGN
#' of the off-diagonal (cross) term (log-inversion duality). The Log-Logistic
#' matrix is the corrected form; an earlier version used the second log-cumulant
#' Var(log X) = pi^2 / (3 a^2) for the (1,1) entry, which is not the shape
#' information. All forms match the numerical observed information.
#'
#' @param dist Character; distribution name.
#' @param theta Numeric length-2 parameter vector.
#' @return A 2 by 2 per-observation Fisher information matrix.
#' @examples
#' fisher_closed("Weibull", c(2, 1))
#' fisher_closed("Frechet", c(2, 1))
#' @export
fisher_closed <- function(dist, theta) {
  a <- theta[1]; b <- theta[2]
  psi1 <- function(z) psigamma(z, 1)
  gam <- -psigamma(1, 0)   # Euler-Mascheroni constant ~ 0.5772
  if (dist == "Weibull") {
    # Diagonal shared with Frechet; cross term -(1 - gam)/b.
    matrix(c(a^-2 * (psi1(1) + (1 - gam)^2), -(1 - gam) / b,
             -(1 - gam) / b,                  a^2 / b^2), 2, 2, byrow = TRUE)
  } else if (dist == "Frechet") {
    # Same diagonal as Weibull; cross term flips sign to +(1 - gam)/b.
    matrix(c(a^-2 * (psi1(1) + (1 - gam)^2), +(1 - gam) / b,
             +(1 - gam) / b,                  a^2 / b^2), 2, 2, byrow = TRUE)
  } else if (dist == "Gamma") {
    matrix(c(psi1(a), 1 / b,
             1 / b,   a / b^2), 2, 2, byrow = TRUE)
  } else if (dist == "InvGamma") {
    matrix(c(psi1(a), -1 / b,
             -1 / b,   a / b^2), 2, 2, byrow = TRUE)
  } else if (dist == "LogNormal") {
    matrix(c(b^-2, 0, 0, 2 * b^-2), 2, 2)
  } else if (dist == "LogLogistic") {
    # Corrected: (1,1) = (pi^2 + 3)/(9 a^2); (2,2) = a^2/(3 b^2).
    matrix(c((pi^2 + 3) / (9 * a^2), 0,
             0,                       a^2 / (3 * b^2)), 2, 2, byrow = TRUE)
  } else stop("Unknown distribution: ", dist)
}

# ----------------------------------------------------------------------------
# MLE estimation.  Returns list(theta, Sigma, loglik, conv).
#   Sigma = n * solve(observed information) = per-observation asymptotic cov.
# Optimization on transformed (unconstrained) scale for stability.
# ----------------------------------------------------------------------------
#' Maximum-likelihood fit of a reliability distribution
#'
#' Fits one of the six supported families by maximum likelihood, optimizing on
#' the log-scale of the parameters for numerical stability, and returns the
#' estimates together with the observed-information-based covariance.
#'
#' @param x Numeric vector of positive observations.
#' @param dist Character; distribution name.
#' @param init Optional numeric length-2 vector of starting values.
#' @return A list with elements \code{theta} (estimates), \code{Sigma}
#'   (covariance of \eqn{\sqrt{n}(\hat\theta-\theta)}), \code{loglik},
#'   and \code{conv} (convergence flag).
#' @examples
#' set.seed(1)
#' x <- rdist(200, "Gamma", c(3, 0.5))
#' fit <- mle_fit(x, "Gamma")
#' fit$theta
#' @export
mle_fit <- function(x, dist, init = NULL) {
  n <- length(x)
  
  if (dist == "LogNormal") {
    lx <- log(x); mu <- mean(lx); sg <- sqrt(mean((lx - mu)^2))
    # Observed information for (mu, sigma): I = n*diag(1/sg^2, 2/sg^2)
    Sigma <- diag(c(sg^2, sg^2 / 2))
    ll <- sum(dlnorm(x, mu, sg, log = TRUE))
    return(list(theta = c(mu, sg), Sigma = Sigma, loglik = ll, conv = TRUE))
  }
  
  # For (alpha, lambda) families: optimize on log-scale (both positive)
  nll <- function(eta) {
    th <- exp(eta)
    v <- ldist(x, dist, th, log = TRUE)
    if (any(!is.finite(v))) return(1e10)
    -sum(v)
  }
  
  if (is.null(init)) {
    m <- mean(x); v <- var(x)
    init <- switch(dist,
                   Weibull     = c((m / sqrt(v))^1.086, m / gamma(1 + sqrt(v) / m)),
                   Frechet     = c(2.5, stats::median(x)),
                   Gamma       = c(m^2 / v, v / m),
                   InvGamma    = c(m^2 / v + 2, m * (m^2 / v + 1)),
                   LogLogistic = c(2, stats::median(x))
    )
    init[init <= 0 | !is.finite(init)] <- 1
  }
  
  opt <- tryCatch(
    optim(log(init), nll, method = "Nelder-Mead",
          control = list(maxit = 1000, reltol = 1e-10)),
    error = function(e) NULL)
  if (is.null(opt) || opt$convergence != 0) {
    opt2 <- tryCatch(optim(log(init), nll, method = "BFGS",
                           control = list(maxit = 500)), error = function(e) NULL)
    if (!is.null(opt2)) opt <- opt2
  }
  if (is.null(opt)) return(list(theta = c(NA, NA), Sigma = NULL,
                                loglik = NA, conv = FALSE))
  
  theta <- exp(opt$par)
  # Observed information on the natural scale via numerical Hessian of nll(theta)
  nll_nat <- function(th) {
    if (any(th <= 0)) return(1e10)
    v <- ldist(x, dist, th, log = TRUE)
    if (any(!is.finite(v))) return(1e10)
    -sum(v)
  }
  H <- tryCatch(numDeriv::hessian(nll_nat, theta), error = function(e) NULL)
  Sigma <- NULL
  if (!is.null(H)) {
    Si <- tryCatch(solve(H), error = function(e) tryCatch(MASS::ginv(H), error = function(e2) NULL))
    if (!is.null(Si)) Sigma <- n * Si      # per-observation asymptotic covariance
  }
  if (is.null(Sigma)) {
    Sigma <- tryCatch(solve(fisher_closed(dist, theta)), error = function(e) diag(2))
  }
  list(theta = theta, Sigma = Sigma, loglik = -opt$value, conv = TRUE)
}