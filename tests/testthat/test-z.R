test_that("Functions on Z values work", {
  x = slopes::lisbon_route_3d
  expect_equal(class(slope_z_value(x)), "numeric")
  x = slopes::lisbon_route
  expect_error(slope_z_value(x))
  expect_error(slope_z_start(x))
  expect_error(slope_z_end(x))
  expect_error(slope_z_mean(x))
  expect_error(slope_z_max(x))
  expect_error(slope_z_min(x))
  # x_slope =
  # expect_is()
})
