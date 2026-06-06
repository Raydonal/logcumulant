# ============================================================================
# diagrams.R -- The three diagnostic diagrams (Santos et al.), faithful to
# the author's MellinGof_diagrams.R specification:
#   (1) Log-Cumulant Diagram       : x = kappa_3,            y = kappa_2
#   (2) Kurtosis-Skewness Diagram  : x = gamma_3 (skewness), y = gamma_4 (excess kurtosis)
#   (3) CV-Skewness Diagram        : x = gamma_2 (CV),       y = gamma_3 (skewness)
# Diagrams (2) and (3) are on the ORIGINAL scale, with theoretical loci from
# closed-form moment formulas (smooth, no Monte-Carlo noise).
# All include the bootstrap cloud + 95% concentration ellipse + sample point.
# ============================================================================

.DIST_COLORS <- c(
  "Weibull"      = "#E41A1C", "Frechet"     = "#4DAF4A",
  "Gamma"        = "#377EB8", "Inv-Gamma"   = "#984EA3",
  "Log-Normal"   = "#FF7F00", "Log-Logistic"= "#A65628")
.DIST_LINETYPES <- c(
  "Weibull"      = "solid",   "Frechet"     = "dashed",
  "Gamma"        = "dotdash", "Inv-Gamma"   = "longdash",
  "Log-Normal"   = "dotted",  "Log-Logistic"= "twodash")
.DIST_ORDER <- c("Weibull","Frechet","Gamma","Inv-Gamma","Log-Normal","Log-Logistic")

.diag_sample_lc <- function(x, kmax = 3L) {
  m <- cpp_log_moments(x, kmax); as.numeric(cpp_log_cumulants(m, kmax))
}
.diag_sample_moments <- function(x) {
  if (length(x) < 4) return(c(cv = NA, skew = NA, kurt = NA))
  m <- mean(x); s <- stats::sd(x)
  if (m == 0 || s == 0) return(c(cv = NA, skew = NA, kurt = NA))
  mc2 <- mean((x - m)^2); mc3 <- mean((x - m)^3); mc4 <- mean((x - m)^4)
  c(cv = s / m, skew = mc3 / mc2^(3/2), kurt = mc4 / mc2^2 - 3)
}

.concentration_ellipse <- function(pts, level = 0.95) {
  pts <- pts[stats::complete.cases(pts), , drop = FALSE]
  if (nrow(pts) < 10) return(NULL)
  mu <- colMeans(pts); S <- stats::cov(pts)
  r <- sqrt(stats::qchisq(level, df = 2))
  th <- seq(0, 2 * pi, length.out = 200); circle <- cbind(cos(th), sin(th))
  eg <- eigen(S, symmetric = TRUE); eg$values <- pmax(eg$values, 0)
  E <- t(mu + r * t(circle %*% diag(sqrt(eg$values)) %*% t(eg$vectors)))
  data.frame(x = E[, 1], y = E[, 2])
}

.adaptive_B <- function(n) if (n <= 50) 1999 else if (n <= 100) 999 else 499

.mom_weibull <- function(a) {
  g <- function(k) gamma(1 + k / a)
  mu <- g(1); v <- g(2) - g(1)^2; s <- sqrt(v)
  sk <- (g(3) - 3*g(1)*g(2) + 2*g(1)^3) / v^1.5
  ku <- (g(4) - 4*g(1)*g(3) + 6*g(1)^2*g(2) - 3*g(1)^4) / v^2 - 3
  c(cv = s/mu, skew = sk, exkurt = ku)
}
.mom_frechet <- function(a) {
  if (a <= 4) return(c(cv = NA, skew = NA, exkurt = NA))
  g <- function(k) gamma(1 - k / a)
  mu <- g(1); v <- g(2) - g(1)^2; s <- sqrt(v)
  sk <- (g(3) - 3*g(1)*g(2) + 2*g(1)^3) / v^1.5
  ku <- (g(4) - 4*g(1)*g(3) + 6*g(1)^2*g(2) - 3*g(1)^4) / v^2 - 3
  c(cv = s/mu, skew = sk, exkurt = ku)
}
.mom_gamma <- function(a) c(cv = 1/sqrt(a), skew = 2/sqrt(a), exkurt = 6/a)
.mom_invgamma <- function(a) {
  if (a <= 4) return(c(cv = NA, skew = NA, exkurt = NA))
  mk <- function(k) gamma(a - k) / gamma(a)
  mu <- mk(1); v <- mk(2) - mk(1)^2; s <- sqrt(v)
  sk <- (mk(3) - 3*mk(1)*mk(2) + 2*mk(1)^3) / v^1.5
  ku <- (mk(4) - 4*mk(1)*mk(3) + 6*mk(1)^2*mk(2) - 3*mk(1)^4) / v^2 - 3
  c(cv = s/mu, skew = sk, exkurt = ku)
}
.mom_lognormal <- function(sig) {
  w <- exp(sig^2)
  c(cv = sqrt(w - 1), skew = (w + 2) * sqrt(w - 1),
    exkurt = w^4 + 2*w^3 + 3*w^2 - 6)
}
.mom_loglogistic <- function(a) {
  if (a <= 4) return(c(cv = NA, skew = NA, exkurt = NA))
  mk <- function(k) { t <- pi * k / a; t / sin(t) }
  mu <- mk(1); v <- mk(2) - mk(1)^2; s <- sqrt(v)
  sk <- (mk(3) - 3*mk(1)*mk(2) + 2*mk(1)^3) / v^1.5
  ku <- (mk(4) - 4*mk(1)*mk(3) + 6*mk(1)^2*mk(2) - 3*mk(1)^4) / v^2 - 3
  c(cv = s/mu, skew = sk, exkurt = ku)
}

.moment_loci <- function() {
  out <- list()
  ag  <- exp(seq(log(0.15), log(200), length.out = 600))
  agk <- exp(seq(log(4.05), log(200), length.out = 600))
  add <- function(name, grid, fun) {
    M <- t(vapply(grid, fun, numeric(3)))
    df <- data.frame(cv = M[,1], skew = M[,2], exkurt = M[,3], Distribution = name)
    df[stats::complete.cases(df), ]
  }
  out$Weibull     <- add("Weibull",      ag,  .mom_weibull)
  out$Frechet     <- add("Frechet",      agk, .mom_frechet)
  out$Gamma       <- add("Gamma",        ag,  .mom_gamma)
  out$InvGamma    <- add("Inv-Gamma",    agk, .mom_invgamma)
  out$LogNormal   <- add("Log-Normal",   seq(0.01, 1.6, length.out = 600), .mom_lognormal)
  out$LogLogistic <- add("Log-Logistic", agk, .mom_loglogistic)
  res <- do.call(rbind, out)
  res$Distribution <- factor(res$Distribution, levels = .DIST_ORDER)
  res
}

.lc_curves <- function(alpha = seq(0.1, 150, by = 0.3)) {
  psi <- function(z, d) psigamma(z, d)
  res <- rbind(
    data.frame(k3 =  psi(1,2)/alpha^3, k2 = psi(1,1)/alpha^2, Distribution = "Weibull"),
    data.frame(k3 = -psi(1,2)/alpha^3, k2 = psi(1,1)/alpha^2, Distribution = "Frechet"),
    data.frame(k3 =  psi(alpha,2),     k2 = psi(alpha,1),     Distribution = "Gamma"),
    data.frame(k3 = -psi(alpha,2),     k2 = psi(alpha,1),     Distribution = "Inv-Gamma"),
    data.frame(k3 = rep(0,200),        k2 = seq(0.01,4,length.out=200), Distribution = "Log-Normal"),
    data.frame(k3 = rep(0,length(alpha)), k2 = pi^2/(3*alpha^2), Distribution = "Log-Logistic")
  )
  res <- res[is.finite(res$k2) & is.finite(res$k3) & res$k2 > 0 & res$k2 < 6, ]
  res$Distribution <- factor(res$Distribution, levels = .DIST_ORDER)
  res
}

.theme_mellin <- function(base = 16, legend_pos = c(0.99, 0.99),
                          legend_just = c(1, 1)) {
  ggplot2::theme_bw(base_size = base) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.title = ggplot2::element_text(size = base + 2),
      axis.text  = ggplot2::element_text(size = base),
      legend.position = legend_pos,
      legend.justification = legend_just,
      legend.background = ggplot2::element_rect(fill = ggplot2::alpha("white", 0.6),
                                                color = NA),
      legend.key = ggplot2::element_rect(fill = ggplot2::alpha("white", 0), color = NA),
      legend.title = ggplot2::element_text(size = base - 1, face = "bold"),
      legend.text  = ggplot2::element_text(size = base - 2),
      legend.key.size = ggplot2::unit(0.9, "lines"),
      legend.margin = ggplot2::margin(2, 4, 2, 4))
}

#' Log-cumulant diagram
#'
#' Draws the log-cumulant diagnostic diagram (\eqn{\kappa_3} versus
#' \eqn{\kappa_2}) with the theoretical loci of the six reference
#' distributions, a bootstrap cloud of the sample estimate, and a 95\%
#' concentration ellipse.
#'
#' @param data Numeric vector of positive observations.
#' @param data_name Character; label used in the title.
#' @param B Integer; bootstrap replicates (default chosen adaptively from \code{n}).
#' @param seed Integer random seed.
#' @param level Numeric; ellipse confidence level (default 0.95).
#' @param xlim,ylim Numeric length-2 axis limits.
#' @return A \code{ggplot} object.
#' @examples
#' data(reliability_datasets)
#' log_cumulant_diagram(reliability_datasets$Yarn, "Yarn", B = 200)
#' @export
log_cumulant_diagram <- function(data, data_name = "Dataset", B = NULL,
                                 seed = 42, level = 0.95,
                                 xlim = c(-2, 2), ylim = c(0, 2)) {
  x <- data[is.finite(data) & data > 0]; n <- length(x)
  if (is.null(B)) B <- .adaptive_B(n)
  set.seed(seed)
  BC <- t(vapply(seq_len(B), function(b) {
    xs <- sample(x, n, replace = TRUE); k <- .diag_sample_lc(xs, 3L); c(k[3], k[2])
  }, numeric(2)))
  colnames(BC) <- c("k3", "k2"); BC <- as.data.frame(BC)
  obs <- .diag_sample_lc(x, 3L)
  ell <- .concentration_ellipse(cbind(BC$k3, BC$k2), level)
  th <- .lc_curves()
  ggplot2::ggplot() +
    ggplot2::geom_path(data = th, ggplot2::aes(k3, k2, color = Distribution,
                       linetype = Distribution), linewidth = 0.9) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dotted", color = "grey50") +
    ggplot2::geom_point(data = BC, ggplot2::aes(k3, k2), color = "steelblue",
                        alpha = 0.30, size = 1.5) +
    { if (!is.null(ell)) ggplot2::geom_path(data = ell, ggplot2::aes(x, y),
        color = "grey20", linewidth = 1.0) } +
    ggplot2::geom_point(ggplot2::aes(obs[3], obs[2]), shape = 21, fill = "steelblue",
                        color = "black", size = 3.5, stroke = 1.1) +
    ggplot2::scale_color_manual(name = "Distribution", values = .DIST_COLORS) +
    ggplot2::scale_linetype_manual(name = "Distribution", values = .DIST_LINETYPES) +
    ggplot2::coord_cartesian(xlim = xlim, ylim = ylim) +
    ggplot2::labs(x = expression(kappa[3]), y = expression(kappa[2])) +
    .theme_mellin(legend_pos = c(0.015, 0.985), legend_just = c(0, 1)) +
    ggplot2::guides(color = ggplot2::guide_legend(ncol = 2, byrow = TRUE),
                    linetype = ggplot2::guide_legend(ncol = 2, byrow = TRUE))
}

#' Kurtosis-skewness diagram
#'
#' Draws the kurtosis-skewness diagnostic diagram on the original scale
#' (skewness \eqn{\gamma_3} versus excess kurtosis \eqn{\gamma_4}), including
#' the feasible-region boundary \eqn{\gamma_4 = \gamma_3^2 - 2}, theoretical
#' loci, bootstrap cloud, and 95\% concentration ellipse.
#'
#' @inheritParams log_cumulant_diagram
#' @return A \code{ggplot} object.
#' @examples
#' data(reliability_datasets)
#' kurtosis_diagram(reliability_datasets$Yarn, "Yarn", B = 200)
#' @export
kurtosis_diagram <- function(data, data_name = "Dataset", B = NULL,
                             seed = 42, level = 0.95,
                             xlim = c(-1.5, 4), ylim = c(-3, 16)) {
  x <- data[is.finite(data) & data > 0]; n <- length(x)
  if (is.null(B)) B <- .adaptive_B(n)
  set.seed(seed)
  BC <- t(vapply(seq_len(B), function(b) {
    m <- .diag_sample_moments(sample(x, n, replace = TRUE)); c(m["skew"], m["kurt"])
  }, numeric(2)))
  colnames(BC) <- c("skew", "kurt"); BC <- as.data.frame(BC)
  BC <- BC[stats::complete.cases(BC), ]
  om <- .diag_sample_moments(x); obs <- c(om["skew"], om["kurt"])
  ell <- .concentration_ellipse(cbind(BC$skew, BC$kurt), level)
  th <- .moment_loci()
  feas <- data.frame(x = seq(xlim[1], xlim[2], length.out = 200))
  feas$y <- feas$x^2 - 2
  ggplot2::ggplot() +
    ggplot2::geom_line(data = feas, ggplot2::aes(x, y), color = "grey55",
                       linetype = "dashed", linewidth = 0.7) +
    ggplot2::geom_path(data = th, ggplot2::aes(skew, exkurt, color = Distribution,
                       linetype = Distribution), linewidth = 0.9) +
    ggplot2::geom_point(data = BC, ggplot2::aes(skew, kurt), color = "steelblue",
                        alpha = 0.30, size = 1.5) +
    { if (!is.null(ell)) ggplot2::geom_path(data = ell, ggplot2::aes(x, y),
        color = "grey20", linewidth = 1.0) } +
    ggplot2::geom_point(ggplot2::aes(obs[1], obs[2]), shape = 21, fill = "steelblue",
                        color = "black", size = 3.5, stroke = 1.1) +
    ggplot2::scale_color_manual(name = "Distribution", values = .DIST_COLORS) +
    ggplot2::scale_linetype_manual(name = "Distribution", values = .DIST_LINETYPES) +
    ggplot2::coord_cartesian(xlim = xlim, ylim = ylim) +
    ggplot2::labs(x = expression("Skewness" ~ (gamma[3])),
                  y = expression("Excess Kurtosis" ~ (gamma[4]))) +
    .theme_mellin(legend_pos = c(0.99, 0.01), legend_just = c(1, 0))
}

#' Coefficient-of-variation diagram
#'
#' Draws the coefficient-of-variation diagnostic diagram on the original scale
#' (CV \eqn{\gamma_2} versus skewness \eqn{\gamma_3}) with theoretical loci,
#' bootstrap cloud, and 95\% concentration ellipse.
#'
#' @inheritParams log_cumulant_diagram
#' @return A \code{ggplot} object.
#' @examples
#' data(reliability_datasets)
#' cv_diagram(reliability_datasets$Yarn, "Yarn", B = 200)
#' @export
cv_diagram <- function(data, data_name = "Dataset", B = NULL, seed = 42,
                       level = 0.95, xlim = c(0, 2.2), ylim = c(-0.2, 5)) {
  x <- data[is.finite(data) & data > 0]; n <- length(x)
  if (is.null(B)) B <- .adaptive_B(n)
  set.seed(seed)
  BC <- t(vapply(seq_len(B), function(b) {
    m <- .diag_sample_moments(sample(x, n, replace = TRUE)); c(m["cv"], m["skew"])
  }, numeric(2)))
  colnames(BC) <- c("cv", "skew"); BC <- as.data.frame(BC)
  BC <- BC[stats::complete.cases(BC), ]
  om <- .diag_sample_moments(x); obs <- c(om["cv"], om["skew"])
  ell <- .concentration_ellipse(cbind(BC$cv, BC$skew), level)
  th <- .moment_loci()
  ggplot2::ggplot() +
    ggplot2::geom_path(data = th, ggplot2::aes(cv, skew, color = Distribution,
                       linetype = Distribution), linewidth = 0.9) +
    ggplot2::geom_point(data = BC, ggplot2::aes(cv, skew), color = "steelblue",
                        alpha = 0.30, size = 1.5) +
    { if (!is.null(ell)) ggplot2::geom_path(data = ell, ggplot2::aes(x, y),
        color = "grey20", linewidth = 1.0) } +
    ggplot2::geom_point(ggplot2::aes(obs[1], obs[2]), shape = 21, fill = "steelblue",
                        color = "black", size = 3.5, stroke = 1.1) +
    ggplot2::scale_color_manual(name = "Distribution", values = .DIST_COLORS) +
    ggplot2::scale_linetype_manual(name = "Distribution", values = .DIST_LINETYPES) +
    ggplot2::coord_cartesian(xlim = xlim, ylim = ylim) +
    ggplot2::labs(x = expression("Coefficient of Variation" ~ (gamma[2])),
                  y = expression("Skewness" ~ (gamma[3]))) +
    .theme_mellin(legend_pos = c(0.99, 0.01), legend_just = c(1, 0))
}

#' Combined three-panel diagnostic figure
#'
#' Arranges the log-cumulant, kurtosis-skewness, and coefficient-of-variation
#' diagrams side by side for a single dataset.
#'
#' @inheritParams log_cumulant_diagram
#' @return A \code{gtable} drawn via \code{gridExtra::grid.arrange}.
#' @examples
#' data(reliability_datasets)
#' three_diagrams(reliability_datasets$Yarn, "Yarn", B = 200)
#' @export
three_diagrams <- function(data, data_name = "Dataset", B = NULL, seed = 42) {
  p1 <- log_cumulant_diagram(data, data_name, B = B, seed = seed)
  p2 <- kurtosis_diagram(data, data_name, B = B, seed = seed)
  p3 <- cv_diagram(data, data_name, B = B, seed = seed)
  gridExtra::grid.arrange(p1, p2, p3, ncol = 3)
}

#' Quick log-cumulant plot
#'
#' Convenience wrapper around \code{\link{log_cumulant_diagram}} providing the
#' compact \code{plot_lc(data = x, B = 100)} interface requested for quick
#' diagnostics. \code{plot.lc} is kept as an alias for backward compatibility.
#'
#' @param data Numeric vector of positive observations.
#' @param B Integer; bootstrap replicates.
#' @param data_name Character; label used in the title.
#' @param seed Integer random seed.
#' @param ... Further arguments passed to \code{\link{log_cumulant_diagram}}.
#' @return A \code{ggplot} object.
#' @examples
#' data(reliability_datasets)
#' plot_lc(reliability_datasets$BallBearing, B = 100)
#' @export
plot_lc <- function(data, B = 100, data_name = "Sample", seed = 42, ...) {
  log_cumulant_diagram(data, data_name = data_name, B = B, seed = seed, ...)
}


# ============================================================================
# Multi-dataset log-cumulant diagram (Figure 1b style): theoretical curves
# colored by distribution (legend "Theoretical curve") plus bootstrap clouds
# for several datasets distinguished by fill+shape (legend "Empirical data").
# ============================================================================
#' Multi-dataset log-cumulant diagram
#'
#' Overlays bootstrap clouds for several datasets on the log-cumulant diagram,
#' distinguishing datasets by colour and plotting symbol (the \dQuote{empirical
#' data} legend) while the theoretical loci keep the \dQuote{theoretical curve}
#' legend.
#'
#' @param datasets_list Named list of numeric vectors.
#' @param dataset_names Optional character vector of names to use.
#' @param B Integer; bootstrap replicates per dataset.
#' @param seed Integer random seed.
#' @param xlim,ylim Numeric length-2 axis limits.
#' @param alpha_points Numeric; point transparency.
#' @param point_size Numeric; point size.
#' @return A \code{ggplot} object.
#' @examples
#' data(reliability_datasets)
#' multi_lc_diagram(reliability_datasets[c("Airplane","BallBearing","Yarn")], B = 300)
#' @export
multi_lc_diagram <- function(datasets_list, dataset_names = NULL, B = 1000,
                             seed = 42, xlim = c(-2, 2), ylim = c(0, 2),
                             alpha_points = 0.35, point_size = 2.6) {
  set.seed(seed)
  if (is.null(dataset_names)) dataset_names <- names(datasets_list)
  th <- .lc_curves()
  # bootstrap clouds
  clouds <- do.call(rbind, lapply(dataset_names, function(nm) {
    x <- datasets_list[[nm]]; n <- length(x)
    m <- t(vapply(seq_len(B), function(b) {
      k <- .diag_sample_lc(sample(x, n, replace = TRUE), 3L); c(k[3], k[2])
    }, numeric(2)))
    data.frame(k3 = m[, 1], k2 = m[, 2], Dataset = nm)
  }))
  clouds$Dataset <- factor(clouds$Dataset, levels = dataset_names)
  # default fill/shape palette (cycles if more than 5 datasets)
  fillpal  <- c("blue", "red", "darkgreen", "orange", "purple")
  shapepal <- c(24, 21, 22, 23, 25)
  k <- length(dataset_names)
  dcol <- stats::setNames(rep(fillpal, length.out = k), dataset_names)
  dshp <- stats::setNames(rep(shapepal, length.out = k), dataset_names)

  ggplot2::ggplot() +
    ggplot2::geom_path(data = th, ggplot2::aes(k3, k2, color = Distribution,
                       linetype = Distribution), linewidth = 1, alpha = 0.9) +
    ggplot2::geom_vline(xintercept = 0, color = "black", linewidth = 0.8,
                        linetype = "dotted") +
    ggplot2::geom_point(data = clouds, ggplot2::aes(k3, k2, fill = Dataset,
                        shape = Dataset), color = "black", alpha = alpha_points,
                        size = point_size, stroke = 0.4) +
    ggplot2::scale_color_manual(name = "Theoretical curve", values = .DIST_COLORS) +
    ggplot2::scale_linetype_manual(name = "Theoretical curve", values = .DIST_LINETYPES) +
    ggplot2::scale_fill_manual(name = "Empirical data", values = dcol) +
    ggplot2::scale_shape_manual(name = "Empirical data", values = dshp) +
    ggplot2::coord_cartesian(xlim = xlim, ylim = ylim) +
    ggplot2::labs(x = expression(kappa[3]), y = expression(kappa[2])) +
    ggplot2::theme_bw(base_size = 15) +
    ggplot2::theme(panel.grid = ggplot2::element_blank(),
                   legend.background = ggplot2::element_rect(fill = ggplot2::alpha("white", 0), color = NA),
                   legend.key = ggplot2::element_rect(fill = ggplot2::alpha("white", 0), color = NA)) +
    ggplot2::guides(color = ggplot2::guide_legend(order = 1, override.aes = list(linewidth = 1.2)),
                    linetype = ggplot2::guide_legend(order = 1),
                    fill = ggplot2::guide_legend(order = 2, override.aes = list(alpha = 0.9, size = 3.2)),
                    shape = ggplot2::guide_legend(order = 2))
}
