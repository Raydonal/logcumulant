#' logcumulant: Goodness-of-Fit Tests and Diagrams Based on Mellin Log-Cumulants
#'
#' The \pkg{logcumulant} package implements a family of three complementary
#' goodness-of-fit tests based on an adaptation of Hotelling's \eqn{T^2}
#' statistic applied to vectors of sample log-cumulants (Mellin statistics) for
#' positive-support reliability data, together with three diagnostic diagrams.
#'
#' @section Main functions:
#' \describe{
#'   \item{Diagrams}{\code{\link{log_cumulant_diagram}},
#'     \code{\link{kurtosis_diagram}}, \code{\link{cv_diagram}},
#'     \code{\link{three_diagrams}}, \code{\link{multi_lc_diagram}},
#'     \code{\link{plot_lc}}}
#'   \item{Tests}{\code{\link{T2_all}}, \code{\link{T2_bootstrap}},
#'     \code{\link{gof_compare_all}}}
#'   \item{Simulation}{\code{\link{size_study}}, \code{\link{power_study}}}
#'   \item{Building blocks}{\code{\link{mle_fit}}, \code{\link{theoretical_lc}},
#'     \code{\link{jacobian_J}}, \code{\link{fisher_closed}}}
#' }
#'
#' @section Data:
#' Nine reliability datasets are bundled as \code{\link{reliability_datasets}}.
#'
#' @keywords internal
#' @useDynLib logcumulant, .registration = TRUE
#' @importFrom Rcpp evalCpp
#' @importFrom MASS ginv
#' @importFrom numDeriv hessian jacobian
#' @importFrom goftest pAD pCvM
#' @import ggplot2
#' @importFrom gridExtra grid.arrange arrangeGrob
#' @importFrom stats optim var sd median quantile pchisq pf cov complete.cases qchisq dweibull rweibull pweibull dgamma rgamma pgamma dlnorm rlnorm plnorm setNames rbinom qweibull qgamma cov2cor
"_PACKAGE"

# Quiet R CMD check NOTEs for ggplot2 non-standard evaluation (aes) variables.
utils::globalVariables(c(
  "k2", "k3", "cv", "skew", "exkurt", "kurt", "y",
  "Distribution", "Dataset"
))
