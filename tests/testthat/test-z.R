test_that("Functions on Z values work", {
  x = slopes::lisbon_route_3d
  expect_equal(class(z_value(x)), "numeric")
  x = slopes::lisbon_route
  expect_error(z_value(x))
  expect_error(z_start(x))
  expect_error(z_end(x))
  expect_error(z_mean(x))
  expect_error(z_min(x))
  expect_error(z_max(x))
  expect_error(z_elevation_change_start_end(x))
  expect_error(z_direction(x))
  expect_error(z_cumulative_difference(x))
  # x_slope =
  # expect_is()
})
