library(testthat)
library(slopes)

test_that("slopes_palette returns correct vector", {
  pal <- slopes_palette()
  expect_type(pal, "character")
  expect_length(pal, 6)
})

# optional: test plot functions don't error
test_that("plot_slope and plot_dz accept NULL palette", {
  expect_error(plot_slope(route_xyz = lisbon_route_3d, pal = NULL), NA)
})
