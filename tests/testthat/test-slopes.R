test_that("slope_* functions work", {
  x = c(0, 2, 3, 4, 5, 9)
  e = c(1, 2, 2, 4, 3, 1) / 10
  expect_equal(slope_vector(x, e), c(0.05, 0, 0.2, -0.1, -0.05))
  # expect_equal(slope_distance(x, e), c(0.05, 0, 0.2, -0.1, -0.05))

  m = sf::st_coordinates(lisbon_road_segment)
  d = sequential_dist(m, lonlat = FALSE)

  # test lengths to nearest mm
  sequential_right = round(sum(d), 2) ==
    round(as.numeric(sf::st_length(lisbon_road_segment)), 2)
  expect_true(sequential_right)

  e = elevation_extract(m, dem_lisbon_raster)
  expect_identical(round(e[1:3], 2), c(92.31, 91.93, 91.60))
  s = slope_distance(d, e)
  expect_identical(round(s[1:3], 3), c(-0.047, -0.041, -0.025))

  s = slope_distance_mean(d, e)
  expect_identical(round(s, 3), 0.093)

  s = slope_distance_weighted(d, e)
  expect_identical(round(s, 3), 0.095)

  x = c(0, 2, 3, 4, 5, 9)
  y = c(0, 0, 0, 0, 0, 9)
  z = c(1, 2, 2, 4, 3, 1) / 10
  m = cbind(x, y, z)
  gxy = slope_matrix(m, lonlat = FALSE)
  # dput(round(gxy, 3))
  expect_identical(round(gxy, 3), c(0.05, 0., 0.2, -0.1, -0.02))

})
