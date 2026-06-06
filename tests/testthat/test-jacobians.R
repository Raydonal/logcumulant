# Analytic Jacobian J_V vs numerical differentiation, across all families.
# Ported from the original development validation script.

test_that("analytic Jacobian J_V matches numerical differentiation", {
  skip_if_not_installed("numDeriv")

  dists <- c("Weibull", "Frechet", "Gamma", "InvGamma", "LogNormal", "LogLogistic")
  theta_test <- list(
    Weibull     = c(2, 1.5),
    Frechet     = c(3, 1),
    Gamma       = c(4, 0.5),
    InvGamma    = c(5, 4),
    LogNormal   = c(0, 0.7),
    LogLogistic = c(4, 1)
  )

  for (dist in dists) {
    th <- theta_test[[dist]]
    for (V in list(c(2, 3), c(1, 2, 3), 1:6)) {
      Jana <- jacobian_J(dist, th, V)
      Jnum <- numDeriv::jacobian(function(t) theoretical_lc(dist, t, 6)[V], th)
      expect_equal(
        unname(as.matrix(Jana)),
        unname(as.matrix(Jnum)),
        tolerance = 1e-5,
        info = paste0("dist = ", dist, ", V = ", paste(V, collapse = ""))
      )
    }
  }
})
