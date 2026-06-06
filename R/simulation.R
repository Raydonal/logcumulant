# ============================================================================
# simulation.R -- Size and power simulation studies (Santos et al.)
#   H0: Weibull(2,1) (= Rayleigh).  Alternatives median-matched.
# ============================================================================

# Median-matched alternative configurations (Table tab:alt_power).
# Shapes from the article; scales solved so median = median[Weibull(2,1)] = 0.8326,
# isolating shape differences from location. (The article's raw table parameters
# are NOT median-matched; these corrected scales implement the stated design.)
.ALT_CONFIGS <- list(
  Frechet     = list(dist = "Frechet",     theta = c(3, 0.7368)),
  Gamma       = list(dist = "Gamma",       theta = c(4, 0.2267)),
  InvGamma    = list(dist = "InvGamma",    theta = c(5, 3.8888)),
  LogNormal   = list(dist = "LogNormal",   theta = c(-0.1833, 0.7)),
  LogLogistic = list(dist = "LogLogistic", theta = c(4, 0.8326))
)

# ----------------------------------------------------------------------------
# One Monte Carlo cell: generate from `gen` config, test under H0 dist `h0`.
# Returns rejection indicators for the 3 T^2 (asymptotic) + AD + CvM,
# and optionally bootstrap.
# ----------------------------------------------------------------------------
.sim_one <- function(n, gen, h0 = "Weibull", eta = 0.05,
                     use_bootstrap = FALSE, B = NULL) {
  x <- rdist(n, gen$dist, gen$theta)
  fit <- tryCatch(mle_fit(x, h0), error = function(e) NULL)
  if (is.null(fit) || !isTRUE(fit$conv)) return(NULL)

  t2 <- tryCatch(T2_all(x, h0, fit), error = function(e) NULL)
  if (is.null(t2)) return(NULL)
  adcvm <- ad_cvm_test(x, h0, fit$theta)

  p_asym <- c(t2$T2_23$p_chisq, t2$T2_123$p_chisq, t2$T2_123456$p_chisq)
  p_F    <- c(t2$T2_23$p_F, t2$T2_123$p_F, t2$T2_123456$p_F)
  rej <- c(
    T2_23_chi = as.numeric(p_asym[1] < eta),
    T2_123_chi = as.numeric(p_asym[2] < eta),
    T2_full_chi = as.numeric(p_asym[3] < eta),
    T2_23_F = as.numeric(p_F[1] < eta),
    T2_123_F = as.numeric(p_F[2] < eta),
    T2_full_F = as.numeric(p_F[3] < eta),
    AD = as.numeric(adcvm$AD_p < eta),
    CvM = as.numeric(adcvm$CvM_p < eta)
  )
  if (use_bootstrap) {
    bs <- tryCatch(T2_bootstrap(x, h0, B = B, fit = fit), error = function(e) NULL)
    if (!is.null(bs)) {
      rej <- c(rej,
               T2_23_boot = as.numeric(bs$p_boot["T2_23"] < eta),
               T2_123_boot = as.numeric(bs$p_boot["T2_123"] < eta),
               T2_full_boot = as.numeric(bs$p_boot["T2_123456"] < eta))
    }
  }
  rej
}

# ----------------------------------------------------------------------------
# Empirical size study: H0 true, vary n.
# ----------------------------------------------------------------------------
#' Empirical size (Type I error) study
#'
#' Monte Carlo study of the empirical size of the three \eqn{T^2} tests
#' (asymptotic and, optionally, bootstrap) and the AD/CvM tests under a true
#' null model, across several sample sizes.
#'
#' @param sample_sizes Integer vector of sample sizes.
#' @param Nsim Integer; number of Monte Carlo replications.
#' @param eta Numeric; nominal significance level.
#' @param use_bootstrap Logical; include bootstrap calibration.
#' @param B Integer; bootstrap replicates.
#' @param seed Integer random seed.
#' @param verbose Logical; print progress.
#' @return A \code{data.frame} of empirical rejection rates.
#' @examples
#' \donttest{
#' size_study(sample_sizes = c(30, 50), Nsim = 100)
#' }
#' @export
size_study <- function(sample_sizes = c(30, 50, 100, 200), Nsim = 1000,
                       eta = 0.05, use_bootstrap = FALSE, B = NULL,
                       seed = 2025, verbose = TRUE) {
  set.seed(seed)
  gen <- list(dist = "Weibull", theta = c(2, 1))
  res <- list()
  for (n in sample_sizes) {
    acc <- NULL; nv <- 0
    for (i in seq_len(Nsim)) {
      r <- .sim_one(n, gen, "Weibull", eta, use_bootstrap, B)
      if (is.null(r)) next
      if (is.null(acc)) acc <- r else acc <- acc + r
      nv <- nv + 1
    }
    res[[as.character(n)]] <- list(size = acc / nv, valid = nv)
    if (verbose) cat(sprintf("n=%d done (valid=%d): T2_23_chi=%.3f T2_123_chi=%.3f T2_full_chi=%.3f\n",
                             n, nv, (acc/nv)["T2_23_chi"], (acc/nv)["T2_123_chi"], (acc/nv)["T2_full_chi"]))
  }
  res
}

# ----------------------------------------------------------------------------
# Empirical power study: vary alternative, fixed n.
# ----------------------------------------------------------------------------
#' Empirical power study
#'
#' Monte Carlo study of the power of the three \eqn{T^2} tests and the AD/CvM
#' tests against a set of alternative distributions, with optional
#' size-correction.
#'
#' @param n Integer; sample size.
#' @param Nsim Integer; number of Monte Carlo replications.
#' @param eta Numeric; nominal significance level.
#' @param alternatives Character vector of alternative names to evaluate.
#' @param use_bootstrap Logical; use bootstrap calibration.
#' @param B Integer; bootstrap replicates.
#' @param seed Integer random seed.
#' @param verbose Logical; print progress.
#' @return A \code{data.frame} of empirical power by test and alternative.
#' @examples
#' \donttest{
#' power_study(n = 100, Nsim = 100)
#' }
#' @export
power_study <- function(n = 100, Nsim = 1000, eta = 0.05,
                        alternatives = names(.ALT_CONFIGS),
                        use_bootstrap = FALSE, B = NULL, seed = 2025,
                        verbose = TRUE) {
  set.seed(seed)
  res <- list()
  for (alt in alternatives) {
    gen <- .ALT_CONFIGS[[alt]]
    acc <- NULL; nv <- 0
    for (i in seq_len(Nsim)) {
      r <- .sim_one(n, gen, "Weibull", eta, use_bootstrap, B)
      if (is.null(r)) next
      if (is.null(acc)) acc <- r else acc <- acc + r
      nv <- nv + 1
    }
    res[[alt]] <- list(power = acc / nv, valid = nv)
    if (verbose) cat(sprintf("%-12s done (valid=%d): T2_23=%.3f T2_123=%.3f T2_full=%.3f AD=%.3f CvM=%.3f\n",
                             alt, nv, (acc/nv)["T2_23_chi"], (acc/nv)["T2_123_chi"],
                             (acc/nv)["T2_full_chi"], (acc/nv)["AD"], (acc/nv)["CvM"]))
  }
  res
}
