# ============================================================================
# T2_statistics.R -- Core T^2 goodness-of-fit statistics (Santos et al.)
#   d   = kappa_tilde_V - kappa_hat_V
#   Xi  = M_V V M_V^T   (sampling cov of sample log-cumulants, delta method)
#   K   = J_V Sigma J_V^T  (cov induced by MLE projection)
#   Kd  = Xi - K   (PSD-projected),  T2 = n d' Kd^+ d,  T2 ~ chi^2_rank(Kd)
# ============================================================================

# V index sets for the three test versions
.V_SETS <- list("23"    = c(2, 3),
                "123"   = c(1, 2, 3),
                "123456"= 1:6)

# ----------------------------------------------------------------------------
# Compute one T^2 statistic for a given index set V.
#   x      : data
#   dist   : null distribution
#   V      : integer index vector (subset of 1:6)
#   fit    : optional pre-computed mle_fit() result (for bootstrap speed)
# Returns list(T2, df, p_chisq, p_F, ...).
# ----------------------------------------------------------------------------
#' Hotelling-type \eqn{T^2} statistic for one cumulant set
#'
#' Computes the log-cumulant \eqn{T^2} goodness-of-fit statistic for a single
#' choice of cumulant orders \code{V}, with the asymptotic chi-squared
#' reference using the corrected (full-rank) degrees of freedom.
#'
#' @param x Numeric vector of positive observations.
#' @param dist Character; null distribution name.
#' @param V Integer vector of cumulant orders (e.g. \code{c(2,3)}).
#' @param fit Optional precomputed \code{\link{mle_fit}} object.
#' @return A list with the statistic \code{T2}, degrees of freedom \code{df},
#'   and asymptotic p-value \code{p_asym}.
#' @examples
#' set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
#' T2_one(x, "Weibull", V = c(2, 3))
#' @export
T2_one <- function(x, dist, V, fit = NULL) {
  n <- length(x)
  pmax <- max(V)
  p <- length(V)

  if (is.null(fit)) fit <- mle_fit(x, dist)
  if (!isTRUE(fit$conv) || any(is.na(fit$theta)))
    return(list(T2 = NA, df = NA, p_chisq = NA, p_F = NA,
                theta = fit$theta, conv = FALSE))

  theta <- fit$theta
  Sigma <- fit$Sigma

  # Sample log-moments up to 2*pmax (needed for V matrix), and log-cumulants
  m2p <- cpp_log_moments(x, 2 * pmax)
  m   <- m2p[1:pmax]
  ktil <- cpp_log_cumulants(m2p, pmax)          # sample log-cumulants (1..pmax)
  khat <- theoretical_lc(dist, theta, pmax)     # theoretical (1..pmax)

  d <- (ktil[V] - khat[V])

  # Building blocks
  Mfull <- cpp_M_jacobian(m2p[1:pmax], pmax)    # pmax x pmax
  Mv <- Mfull[V, , drop = FALSE]                # p x pmax
  V_m <- cpp_V_matrix(m2p, pmax)                # pmax x pmax
  Jv <- jacobian_J(dist, theta, V)              # p x 2

  asm <- cpp_T2_assemble(as.numeric(d), Mv, V_m, Jv, Sigma, n)
  T2 <- asm$T2
  q  <- asm$rank
  if (!is.finite(T2) || T2 < 0) T2 <- NA

  # p-values
  p_chisq <- if (is.na(T2) || q < 1) NA else pchisq(T2, df = q, lower.tail = FALSE)
  p_F <- NA
  if (!is.na(T2) && q >= 1 && n > q) {
    Fstat <- ((n - q) / (q * (n - 1))) * T2
    p_F <- pf(Fstat, df1 = q, df2 = n - q, lower.tail = FALSE)
  }

  list(T2 = T2, df = q, p_chisq = p_chisq, p_F = p_F,
       theta = theta, d = d, Kd = asm$Kd, eigmin = asm$eigmin, conv = TRUE)
}

# ----------------------------------------------------------------------------
# Compute all three T^2 versions at once (shares the MLE fit).
# ----------------------------------------------------------------------------
#' All three nested \eqn{T^2} statistics
#'
#' Convenience wrapper returning the three nested versions
#' \eqn{T^2_{(2,3)}}, \eqn{T^2_{(1,2,3)}}, and \eqn{T^2_{(1,\ldots,6)}}
#' for a single fitted model.
#'
#' @param x Numeric vector of positive observations.
#' @param dist Character; null distribution name.
#' @param fit Optional precomputed \code{\link{mle_fit}} object.
#' @return A named list with components \code{T2_23}, \code{T2_123},
#'   \code{T2_123456}, each as returned by \code{\link{T2_one}}.
#' @examples
#' set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
#' T2_all(x, "Weibull")
#' @export
T2_all <- function(x, dist, fit = NULL) {
  if (is.null(fit)) fit <- mle_fit(x, dist)
  list(
    "T2_23"     = T2_one(x, dist, c(2, 3),  fit),
    "T2_123"    = T2_one(x, dist, c(1,2,3), fit),
    "T2_123456" = T2_one(x, dist, 1:6,      fit),
    fit = fit
  )
}

# ----------------------------------------------------------------------------
# Parametric bootstrap p-values for the three versions.
#   B : number of replicates (adaptive default by n)
# Returns named vector of bootstrap p-values + observed T2s.
# ----------------------------------------------------------------------------
#' Parametric bootstrap p-values for the \eqn{T^2} statistics
#'
#' Computes parametric-bootstrap p-values for the three nested \eqn{T^2}
#' statistics. The bootstrap calibrates the ill-conditioned reference
#' distribution and is the recommended mode of inference in finite samples.
#'
#' @param x Numeric vector of positive observations.
#' @param dist Character; null distribution name.
#' @param B Integer; number of bootstrap replicates (default chosen adaptively).
#' @param fit Optional precomputed \code{\link{mle_fit}} object.
#' @param seed Optional integer random seed for reproducibility.
#' @return A list with the observed statistics and the bootstrap p-values
#'   \code{p_boot} for the three versions.
#' @examples
#' set.seed(1); x <- rdist(80, "Weibull", c(2, 1))
#' T2_bootstrap(x, "Weibull", B = 199, seed = 1)
#' @export
T2_bootstrap <- function(x, dist, B = NULL, fit = NULL, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  n <- length(x)
  if (is.null(B)) B <- if (n <= 50) 1999 else if (n <= 100) 999 else 499
  if (is.null(fit)) fit <- mle_fit(x, dist)

  obs <- T2_all(x, dist, fit)
  T2_obs <- c(obs$T2_23$T2, obs$T2_123$T2, obs$T2_123456$T2)
  theta_hat <- fit$theta

  cnt <- c(0, 0, 0); valid <- c(0, 0, 0)
  for (b in seq_len(B)) {
    xb <- rdist(n, dist, theta_hat)
    fb <- tryCatch(mle_fit(xb, dist), error = function(e) NULL)
    if (is.null(fb) || !isTRUE(fb$conv)) next
    rb <- tryCatch({
      c(T2_one(xb, dist, c(2,3),  fb)$T2,
        T2_one(xb, dist, c(1,2,3),fb)$T2,
        T2_one(xb, dist, 1:6,     fb)$T2)
    }, error = function(e) rep(NA, 3))
    for (j in 1:3) {
      if (!is.na(rb[j])) {
        valid[j] <- valid[j] + 1
        if (rb[j] >= T2_obs[j]) cnt[j] <- cnt[j] + 1
      }
    }
  }
  p_boot <- ifelse(valid > 0, cnt / valid, NA)
  names(p_boot) <- c("T2_23", "T2_123", "T2_123456")
  list(p_boot = p_boot, T2_obs = setNames(T2_obs, names(p_boot)),
       B = B, valid = valid, obs = obs)
}
