test_that("slope_* functions work", {
  x = c(0, 2, 3, 4, 5, 9)
  e = c(1, 2, 2, 4, 3, 1) / 10
  expect_equal(slope_vector(x, e), c(0.05, 0, 0.2, -0.1, -0.05))
  # expect_equal(slope_distance(x, e), c(0.05, 0, 0.2, -0.1, -0.05))
})
