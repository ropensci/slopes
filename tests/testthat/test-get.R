test_that("functions to get elevations from sf objects work", {
  if(nchar(Sys.getenv("MAPBOX_API_KEY")) < 8)
    skip(message = "Skipping test, MAPBOX token in .Renviron needed")
  r = cyclestreets_route
  e = elevation_get(r)
  expect_equal(class(e)[1], "RasterLayer")
})

