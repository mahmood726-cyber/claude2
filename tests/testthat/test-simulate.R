# Minimal smoke test for the simulation data generator.
# Exercises only base-R code paths (no metafor required) so the test
# remains runnable in a minimal R install.

test_that("simulate_ma_dataset returns a well-formed data frame", {
  set.seed(1)
  k <- 20L
  p <- 2L
  d <- simulate_ma_dataset(k = k, p = p, true_R2 = 0.5)

  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), k)
  # yi, vi plus p moderator columns
  expect_equal(ncol(d), p + 2L)
  expect_true(all(c("yi", "vi") %in% names(d)))

  # Sampling variances must be strictly positive (used as CV weights).
  expect_true(all(d$vi > 0))
  expect_false(any(is.na(d$yi)))
})

test_that("simulate_ma_dataset honours the requested number of moderators", {
  set.seed(2)
  d1 <- simulate_ma_dataset(k = 15L, p = 1L, true_R2 = 0)
  expect_equal(ncol(d1), 3L)
})
