test_that("plotting functions work", {
  r = lisbon_road_segment_3d
  expect_equal(class(distance_z(r, lonlat = FALSE)), "list")
  expect_equal(round(distance_z(r, lonlat = FALSE)$d)[1:5], c(0, 8, 16, 24, 32))
  expect_equal(round(distance_z(r, lonlat = FALSE)$z)[1:5], c(92, 92, 92, 91, 91))
  brks = c(3, 6, 10, 20, 40)
  b = make_breaks(brks)
  expect_equal(
    b,
    c(-0.4, -0.2, -0.1, -0.06, -0.03, 0.03, 0.06, 0.1, 0.2, 0.4)
    )
})
