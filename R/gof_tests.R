# ============================================================================
# gof_tests.R -- High-level goodness-of-fit wrapper integrating
#   T^2 (3 versions) + Anderson-Darling + Cramer-von Mises + AIC.
# ============================================================================

# Anderson-Darling (A^2) and Cramer-von Mises (W^2) statistics computed
# directly from the probability integral transform.  Raw statistics are
# returned for size-corrected power; goftest p-values (asymptotic, known-
# parameter null) are also provided for reference.
#' Anderson-Darling and Cramer-von Mises tests
#'
#' Computes the Anderson-Darling (AD) and Cramer-von Mises (CvM) statistics and
#' their p-values for a fitted distribution, based on the probability integral
#' transform.
#'
#' @param x Numeric vector of positive observations.
#' @param dist Character; distribution name.
#' @param theta Numeric length-2 parameter vector (typically MLE).
#' @return A list with \code{AD}, \code{AD_p}, \code{CvM}, \code{CvM_p}.
#' @examples
#' set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
#' ad_cvm_test(x, "Weibull", c(2, 1))
#' @export
ad_cvm_test <- function(x, dist, theta) {
  n <- length(x)
  u <- sort(pdist(x, dist, theta))
  u <- pmin(pmax(u, 1e-12), 1 - 1e-12)   # guard against 0/1
  i <- seq_len(n)
  # Anderson-Darling A^2
  A2 <- -n - (1 / n) * sum((2 * i - 1) * (log(u) + log(1 - rev(u))))
  # Cramer-von Mises W^2
  W2 <- sum((u - (2 * i - 1) / (2 * n))^2) + 1 / (12 * n)
  # Reference asymptotic p-values (known-parameter null distribution)
  AD_p  <- tryCatch(goftest::pAD(A2, lower.tail = FALSE),  error = function(e) NA)
  CvM_p <- tryCatch(goftest::pCvM(W2, lower.tail = FALSE), error = function(e) NA)
  list(AD = A2, AD_p = AD_p, CvM = W2, CvM_p = CvM_p)
}

#' Akaike information criterion for a fitted family
#'
#' @param x Numeric vector of positive observations.
#' @param dist Character; distribution name.
#' @param fit A \code{\link{mle_fit}} object for \code{dist}.
#' @return Numeric AIC value.
#' @examples
#' set.seed(1); x <- rdist(100, "Gamma", c(3, 0.5))
#' aic_value(x, "Gamma", mle_fit(x, "Gamma"))
#' @export
aic_value <- function(x, dist, fit) {
  if (!isTRUE(fit$conv) || is.na(fit$loglik)) return(NA)
  k <- 2  # all families have 2 parameters
  -2 * fit$loglik + 2 * k
}

# ----------------------------------------------------------------------------
# Full GoF analysis of a dataset under one candidate distribution.
#   use_bootstrap : if TRUE, adds bootstrap p-values (slower)
#   B : bootstrap replicates (adaptive if NULL)
# ----------------------------------------------------------------------------
#' Full goodness-of-fit analysis for one distribution
#'
#' Fits a single family and returns the three \eqn{T^2} statistics (with
#' asymptotic and, optionally, bootstrap p-values), the AD and CvM tests, and
#' the AIC, in a single row.
#'
#' @param x Numeric vector of positive observations.
#' @param dist Character; distribution name.
#' @param use_bootstrap Logical; compute bootstrap p-values.
#' @param B Integer; bootstrap replicates.
#' @param seed Optional integer random seed.
#' @return A one-row \code{data.frame} of statistics and p-values.
#' @examples
#' set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
#' gof_analyze(x, "Weibull")
#' @export
gof_analyze <- function(x, dist, use_bootstrap = FALSE, B = NULL, seed = NULL) {
  fit <- mle_fit(x, dist)
  if (!isTRUE(fit$conv)) {
    return(list(dist = dist, conv = FALSE))
  }
  t2 <- T2_all(x, dist, fit)
  adcvm <- ad_cvm_test(x, dist, fit$theta)
  aic <- aic_value(x, dist, fit)

  out <- list(
    dist = dist, theta = fit$theta, conv = TRUE,
    T2_23  = c(stat = t2$T2_23$T2,  df = t2$T2_23$df,  p = t2$T2_23$p_chisq),
    T2_123 = c(stat = t2$T2_123$T2, df = t2$T2_123$df, p = t2$T2_123$p_chisq),
    T2_full= c(stat = t2$T2_123456$T2, df = t2$T2_123456$df, p = t2$T2_123456$p_chisq),
    AD = c(stat = adcvm$AD, p = adcvm$AD_p),
    CvM = c(stat = adcvm$CvM, p = adcvm$CvM_p),
    AIC = aic
  )
  if (use_bootstrap) {
    bs <- T2_bootstrap(x, dist, B = B, fit = fit, seed = seed)
    out$p_boot <- bs$p_boot
    out$B <- bs$B
  }
  out
}

# ----------------------------------------------------------------------------
# Compare all six distributions for a dataset; returns a data.frame.
# ----------------------------------------------------------------------------
#' Compare all candidate distributions
#'
#' Runs \code{\link{gof_analyze}} across all six (or a chosen subset of)
#' families and returns a comparison table, the natural entry point for model
#' selection.
#'
#' @param x Numeric vector of positive observations.
#' @param dists Character vector of distribution names to compare.
#' @param use_bootstrap Logical; compute bootstrap p-values.
#' @param B Integer; bootstrap replicates.
#' @param seed Optional integer random seed.
#' @return A \code{data.frame} with one row per distribution.
#' @examples
#' set.seed(1); x <- rdist(100, "Weibull", c(2, 1))
#' gof_compare_all(x)
#' @export
gof_compare_all <- function(x, dists = .LC_DISTS, use_bootstrap = FALSE,
                            B = NULL, seed = NULL) {
  rows <- lapply(dists, function(d) {
    r <- tryCatch(gof_analyze(x, d, use_bootstrap, B, seed), error = function(e) NULL)
    if (is.null(r) || !isTRUE(r$conv)) return(NULL)
    df <- data.frame(
      Dist = d,
      T2_23 = r$T2_23["stat"], p_23 = r$T2_23["p"],
      T2_123 = r$T2_123["stat"], p_123 = r$T2_123["p"],
      T2_full = r$T2_full["stat"], p_full = r$T2_full["p"],
      AD = r$AD["stat"], AD_p = r$AD["p"],
      CvM = r$CvM["stat"], CvM_p = r$CvM["p"],
      AIC = r$AIC,
      stringsAsFactors = FALSE
    )
    if (use_bootstrap && !is.null(r$p_boot)) {
      df$pb_23 <- r$p_boot["T2_23"]
      df$pb_123 <- r$p_boot["T2_123"]
      df$pb_full <- r$p_boot["T2_123456"]
    }
    df
  })
  do.call(rbind, rows[!sapply(rows, is.null)])
}
