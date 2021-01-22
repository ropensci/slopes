test_that("Functions on Z values work", {
  x = slopes::lisbon_route_3d
  expect_equal(class(slope_z_value(x)), "numeric")
  x = slopes::lisbon_route
  expect_error(slope_z_value(x))
  # x_slope =
  # expect_is()
})
