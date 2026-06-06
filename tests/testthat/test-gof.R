# T2 goodness-of-fit statistics run on the Ball Bearing data (n = 23) for every
# supported family and return finite statistics, valid p-values and df.

test_that("T2_all runs on Ball Bearing data for all families", {
  ball <- c(17.88, 28.92, 33.00, 41.52, 42.12, 45.60, 48.48, 51.84,
            51.96, 54.12, 55.56, 67.80, 68.64, 68.64, 68.88, 84.12,
            93.12, 98.64, 105.12, 105.84, 127.92, 128.04, 173.40)

  dists <- c("Weibull", "Frechet", "Gamma", "InvGamma", "LogNormal", "LogLogistic")

  for (dist in dists) {
    res <- T2_all(ball, dist)

    expect_type(res, "list")
    for (component in c("T2_23", "T2_123", "T2_123456")) {
      expect_true(component %in% names(res),
                  info = paste(dist, "missing", component))
      r <- res[[component]]
      expect_true(is.finite(r$T2), info = paste(dist, component, "T2"))
      expect_gte(r$T2, 0)
      expect_gte(r$p_chisq, 0)
      expect_lte(r$p_chisq, 1)
      expect_gte(r$df, 1)
    }
  }
})
