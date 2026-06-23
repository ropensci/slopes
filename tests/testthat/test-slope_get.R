test_that("slope_matrix_to_raster works", {
  m <- matrix(1:9, nrow = 3)
  
  # Matrix input
  r1 <- slope_matrix_to_raster(m)
  expect_true(methods::is(r1, "SpatRaster"))
  
  # SpatRaster input
  r2 <- slope_matrix_to_raster(r1)
  expect_true(methods::is(r2, "SpatRaster"))
  
  # Invalid input
  expect_error(slope_matrix_to_raster("not a matrix"))
  
})

test_that("slope_xyz_simple works", {
  m <- matrix(1:9, nrow = 3)
  
  # Matrix input
  df1 <- slope_xyz_simple(m)
  expect_equal(names(df1), c("y", "x", "z"))
  expect_equal(nrow(df1), 9)
  
  # SpatRaster input
  r <- terra::rast(m)
  df2 <- slope_xyz_simple(r)
  expect_equal(names(df2), c("x", "y", "z"))
  expect_equal(nrow(df2), 9)
  
  # Invalid input
  expect_error(slope_xyz_simple("not a matrix"))
  
})
