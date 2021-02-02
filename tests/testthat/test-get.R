test_that("slope_* functions work", {
  r = cyclestreets_route
  e = elevations_get(r)
  skip_if(nchar(Sys.getenv("MAPBOX") < 8))
  expect_equal(class(e)[1], "RasterLayer")
})
