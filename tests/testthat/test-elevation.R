test_that("functions to get elevations from sf objects work", {
  if(nchar(Sys.getenv("MAPBOX_API_KEY")) < 8)
    skip(message = "Skipping test, MAPBOX token in .Renviron needed")
  r = cyclestreets_route
  e = elevation_get(r)
  expect_true(methods::is(e, "SpatRaster"))
})

test_that("elevation_extract() works", {
  m = sf::st_coordinates(lisbon_road_segment)
  e = elevation_extract(m, dem_lisbon())
  expect_identical(round(e[1:3], 2), c(92.31, 91.93, 91.60))
  e = elevation_extract(lisbon_road_segment, dem_lisbon())
  expect_identical(round(e[1:3], 2), c(92.31, 91.93, 91.60))
})

test_that("elevation_add() works with LINESTRING geometries", {
  e = dem_lisbon()
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
})
