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
  s = slope_distance_mean(d, e, directed = TRUE)
  expect_identical(round(s, 3), -0.093)

  s = slope_distance_weighted(d, e)
  expect_identical(round(s, 3), 0.095)
  s = slope_distance_weighted(d, e, directed = TRUE)
  expect_identical(round(s, 3), -0.095)

  x = c(0, 2, 3, 4, 5, 9)
  y = c(0, 0, 0, 0, 0, 9)
  z = c(1, 2, 2, 4, 3, 1) / 10
  m = cbind(x, y, z)
  gxy = slope_matrix(m, lonlat = FALSE)
  # dput(round(gxy, 3))
  expect_identical(round(gxy, 3), c(0.05, 0., 0.2, -0.1, -0.02))

  gxy = slope_matrix_weighted(m, lonlat = FALSE)
  expect_identical(round(gxy, 3), 0.04)

  d = sequential_dist(m, lonlat = FALSE)
  expect_identical(round(d, 3), c(2, 1, 1, 1, 9.849))

  d = sequential_dist(m, lonlat = TRUE)
  expect_identical(round(d), c(221581, 110790, 110790, 110790, 1093977))

  expect_error(slope_raster(1))
  r = lisbon_road_network[1:3, ]
  e = dem_lisbon_raster
  s = slope_raster(r, e)
  expect_true(cor(r$Avg_Slope, s) > 0.9975)

  r_xyz = lisbon_road_segment_3d
  expect_equal(slope_xyz(r_xyz), 0.0950132312274622, ignore_attr = TRUE)

  r = lisbon_road_network[204, ]
  r3d = elevation_add(r, e)
  expect_equal(
    sf::st_z_range(r3d$geom),
    c(86, 92),
    ignore_attr = TRUE,
    tolerance = 10
    )
  if(nchar(Sys.getenv("MAPBOX_API_KEY")) < 8)
    skip(message = "Skipping test, MAPBOX token in .Renviron needed")
  r3d2 = elevation_add(r)
  expect_equal(
    sf::st_z_range(r3d2$geom),
    c(86, 92),
    ignore_attr = TRUE,
    tolerance = 10
    )

})
