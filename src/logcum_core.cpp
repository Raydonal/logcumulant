// ============================================================================
// logcum_core.cpp  --  Performance-critical core for the logcumulant package
// Implements the rigorous T^2 theory of Santos et al. (RAY-New.tex):
//   Kd = Xi - K,  Xi = M V M^T,  K = J Sigma J^T
//   T2 = n d' Kd^+ d,   T2 ~ chi^2_rank(Kd)
// ============================================================================
// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
using namespace Rcpp;
using namespace arma;

// ----------------------------------------------------------------------------
// Sample log-moments  m_nu = (1/n) sum (log x)^nu,  nu = 1..pmax
// ----------------------------------------------------------------------------
// [[Rcpp::export]]
arma::vec cpp_log_moments(const arma::vec& x, int pmax) {
  int n = x.n_elem;
  arma::vec m(pmax, fill::zeros);
  for (int t = 0; t < n; ++t) {
    double lx = std::log(x[t]);
    double pw = 1.0;
    for (int nu = 0; nu < pmax; ++nu) {
      pw *= lx;            // lx^(nu+1)
      m[nu] += pw;
    }
  }
  m /= (double)n;
  return m;
}

// ----------------------------------------------------------------------------
// Binomial coefficients (small, cached on the fly)
// ----------------------------------------------------------------------------
static double binom_coef(int n, int k) {
  if (k < 0 || k > n) return 0.0;
  if (k == 0 || k == n) return 1.0;
  double r = 1.0;
  for (int i = 1; i <= k; ++i) r = r * (n - k + i) / i;
  return r;
}

// ----------------------------------------------------------------------------
// Log-cumulants from log-moments via the recursion (Eq. E:LC_recursive)
//   kappa_1 = m_1
//   kappa_nu = m_nu - sum_{r=1}^{nu-1} C(nu-1, r-1) kappa_r m_{nu-r}
// Input m has length >= pmax (1-indexed conceptually; here 0-indexed)
// ----------------------------------------------------------------------------
// [[Rcpp::export]]
arma::vec cpp_log_cumulants(const arma::vec& m, int pmax) {
  arma::vec k(pmax, fill::zeros);
  for (int nu = 1; nu <= pmax; ++nu) {
    double val = m[nu-1];
    for (int r = 1; r <= nu-1; ++r) {
      val -= binom_coef(nu-1, r-1) * k[r-1] * m[nu-r-1];
    }
    k[nu-1] = val;
  }
  return k;
}

// ----------------------------------------------------------------------------
// Jacobian M_V = d kappa / d m   (pmax x pmax lower-triangular)
//   d kappa_nu / d m_j =
//     [j==nu] - sum_{r=1}^{nu-1} C(nu-1,r-1) ( dkappa_r/dm_j * m_{nu-r}
//                                              + kappa_r * [j==nu-r] )
// Returns the full pmax x pmax matrix; caller selects rows in V.
// ----------------------------------------------------------------------------
// [[Rcpp::export]]
arma::mat cpp_M_jacobian(const arma::vec& m, int pmax) {
  arma::vec k = cpp_log_cumulants(m, pmax);
  arma::mat M(pmax, pmax, fill::zeros);   // M(nu-1, j-1) = dkappa_nu/dm_j
  for (int nu = 1; nu <= pmax; ++nu) {
    for (int j = 1; j <= pmax; ++j) {
      double val = (j == nu) ? 1.0 : 0.0;
      for (int r = 1; r <= nu-1; ++r) {
        double c = binom_coef(nu-1, r-1);
        val -= c * ( M(r-1, j-1) * m[nu-r-1]
                     + k[r-1] * ((j == nu-r) ? 1.0 : 0.0) );
      }
      M(nu-1, j-1) = val;
    }
  }
  return M;
}

// ----------------------------------------------------------------------------
// Covariance of log-moments:  V_ij = m_{i+j} - m_i m_j,  i,j = 1..pmax
// Requires m up to order 2*pmax.
// ----------------------------------------------------------------------------
// [[Rcpp::export]]
arma::mat cpp_V_matrix(const arma::vec& m2p, int pmax) {
  arma::mat V(pmax, pmax, fill::zeros);
  for (int i = 1; i <= pmax; ++i)
    for (int j = 1; j <= pmax; ++j)
      V(i-1, j-1) = m2p[i+j-1] - m2p[i-1] * m2p[j-1];
  return V;
}

// ----------------------------------------------------------------------------
// PSD projection + Moore-Penrose pseudoinverse + numerical rank.
// Returns list(Kd_plus, rank, eigmin).
// ----------------------------------------------------------------------------
// [[Rcpp::export]]
Rcpp::List cpp_psd_pinv(const arma::mat& Kd) {
  int p = Kd.n_rows;
  arma::mat Ks = 0.5 * (Kd + Kd.t());   // symmetrize
  arma::vec eval;
  arma::mat evec;
  bool ok = arma::eig_sym(eval, evec, Ks);
  if (!ok) {
    return Rcpp::List::create(_["Kd_plus"] = arma::mat(p, p, fill::zeros),
                              _["rank"] = 0,
                              _["eigmin"] = NA_REAL);
  }
  double lam_max = eval.max();
  if (lam_max <= 0) lam_max = arma::abs(eval).max();
  double eps = std::sqrt(2.220446e-16) * std::max(p, 1);
  double tol = eps * (lam_max > 0 ? lam_max : 1.0);

  arma::mat Kplus(p, p, fill::zeros);
  int rk = 0;
  for (int j = 0; j < p; ++j) {
    if (eval[j] > tol) {
      Kplus += (1.0 / eval[j]) * (evec.col(j) * evec.col(j).t());
      ++rk;
    }
  }
  return Rcpp::List::create(_["Kd_plus"] = Kplus,
                            _["rank"] = rk,
                            _["eigmin"] = eval.min());
}

// ----------------------------------------------------------------------------
// Full T^2 assembly given the building blocks.
//   d       : discrepancy vector (p)
//   Mv      : M_V selected rows (p x pmax)
//   V       : log-moment covariance (pmax x pmax)
//   Jv      : J_V (p x r)
//   Sigma   : MLE asymptotic covariance, per-observation (r x r)
//   n       : sample size
// Returns list(T2, rank, Kd, eigmin).
// ----------------------------------------------------------------------------
// [[Rcpp::export]]
Rcpp::List cpp_T2_assemble(const arma::vec& d,
                           const arma::mat& Mv,
                           const arma::mat& V,
                           const arma::mat& Jv,
                           const arma::mat& Sigma,
                           int n) {
  arma::mat Xi = Mv * V * Mv.t();
  arma::mat K  = Jv * Sigma * Jv.t();
  arma::mat Kd = Xi - K;
  Rcpp::List pp = cpp_psd_pinv(Kd);
  arma::mat Kplus = pp["Kd_plus"];
  int rk = pp["rank"];
  double T2 = (double)n * arma::as_scalar(d.t() * Kplus * d);
  return Rcpp::List::create(_["T2"] = T2,
                            _["rank"] = rk,
                            _["Kd"] = Kd,
                            _["Xi"] = Xi,
                            _["K"] = K,
                            _["eigmin"] = pp["eigmin"]);
}
