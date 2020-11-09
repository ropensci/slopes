test_that("multiplication works", {
  x = slopes::lisbon_route_3d
  expect_equal(class(slope_z_value(x)), "numeric")
  x = slopes::lisbon_route
  expect_error(slope_z_value(x))
})
