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

  e = elevation_extract(m, dem_lisbon())
  expect_identical(round(e[1:3], 2), c(92.31, 91.93, 91.60))
  e = elevation_extract(lisbon_road_segment, dem_lisbon())
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
  expect_identical(round(gxy, 3), c(0.05, 0., 0.2, -0.1, -0.02))

  gxy = slope_matrix_mean(m, lonlat = FALSE)
  expect_identical(round(gxy, 3), 0.074)
  gxy = slope_matrix_mean(m, lonlat = FALSE, directed = TRUE)
  expect_identical(round(gxy, 3), 0.0) # not sure if that's right

  gxy = slope_matrix_weighted(m, lonlat = FALSE)
  expect_identical(round(gxy, 3), 0.04)
  gxy = slope_matrix_weighted(m, lonlat = FALSE, directed = TRUE)
  expect_identical(round(gxy, 3), 0.0) # not sure if that's right

  gxy = slope_matrix_weighted(m, lonlat = FALSE)
  expect_identical(round(gxy, 3), 0.04)

  d = sequential_dist(m, lonlat = FALSE)
  expect_identical(round(d, 3), c(2, 1, 1, 1, 9.849))

  d = sequential_dist(m, lonlat = TRUE)
  expect_identical(round(d), c(221581, 110790, 110790, 110790, 1093977))

  expect_error(slope_raster(1))
  r = lisbon_road_network[1:3, ]
  e = dem_lisbon()
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

  expect_error(slopes:::stopifnotsf(1))
  expect_error(slopes:::stop_is_not_linestring(1))

})

test_that("elevation_add() works with POINT geometries", {
  dem <- dem_lisbon()
  pts <- sf::st_cast(sf::st_geometry(lisbon_road_network[204, ]), "POINT")
  pts <- sf::st_sf(id = seq_along(pts), geometry = pts)

  # Default: add_z = TRUE, no elevation column
  pts_z <- elevation_add(pts, dem)
  expect_s3_class(pts_z, "sf")
  expect_equal(as.character(sf::st_geometry_type(pts_z)[1]), "POINT")
  expect_true(!is.na(sf::st_z_range(pts_z)[1]))      # has Z coordinate
  expect_false("elevation" %in% names(pts_z))
  expect_equal(
    sf::st_z_range(pts_z),
    c(86, 92),
    ignore_attr = TRUE,
    tolerance = 10
  )

  # add_column = TRUE: Z in geometry AND elevation column
  pts_z_col <- elevation_add(pts, dem, add_column = TRUE)
  expect_true("elevation" %in% names(pts_z_col))
  expect_true(!is.na(sf::st_z_range(pts_z_col)[1]))  # still has Z
  expect_equal(
    round(pts_z_col$elevation[1:3], 2),
    c(92.31, 91.93, 91.60)
  )

  # add_z = FALSE, add_column = TRUE: XY geometry with elevation column
  pts_col <- elevation_add(pts, dem, add_z = FALSE, add_column = TRUE)
  expect_true("elevation" %in% names(pts_col))
  expect_true(is.null(sf::st_z_range(pts_col)))      # XY: no Z coordinate
  expect_equal(
    round(pts_col$elevation[1:3], 2),
    c(92.31, 91.93, 91.60)
  )
})
