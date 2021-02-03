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
  g = c(-0.05, -0.04, -0.03, -0.06, -0.02, 0.01, 0.02)
  pal = c("#004B40", "#007D6F", "#00AB9C", "#6CCFC3", "#BAEAE4", "#F6F6F6",
          "#F3DEC6", "#DBB98C", "#B98E45")
  colz = make_colz(g = g, b = b, pal = pal)
  expect_equal(
    colz,
    c("#6CCFC3", "#6CCFC3", "#6CCFC3", "#00AB9C", "#BAEAE4", "#BAEAE4",
      "#BAEAE4")
    )
})
