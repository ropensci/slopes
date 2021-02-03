test_that("plotting functions work", {
  r = lisbon_road_segment_3d
  expect_equal(class(distance_z(r, lonlat = FALSE)), "list")
  expect_equal(round(distance_z(r, lonlat = FALSE)$d)[1:5], c(0, 8, 16, 24, 32))
  expect_equal(round(distance_z(r, lonlat = FALSE)$z)[1:5], c(92, 92, 92, 91, 91))
})
