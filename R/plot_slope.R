#' Plot slope data for a 3d linestring with base R graphics
#'
#' @param route_xyz An sf linestring with x, y and z coordinates,
#'   representing a route or other linear object.
#' @param fill Should the profile be filled? `TRUE` by default
#' @param horiz Should the legend be horizontal (`FALSE` by default)
#' @param pal Color palette to use, `colorspace::diverging_hcl` by default.
#' @param legend_position The legend position. One of "bottomright", "bottom",
#'   "bottomleft", "left", "topleft", "top" (the default), "topright", "right"
#'   and "center".
#' @param col Line colour, black by default
#' @param cex Legend size, 0.9 by default
#' @param bg Legend background colour, `grDevices::rgb(1, 1, 1, 0.8)` by default.
#' @param title Title of the legend, `NULL` by default.
#' @param brks Breaks in colour palette to show.
#'   `c(1, 3, 6, 10, 20, 40, 100)` by default.
#' @param seq_brks Sequence of breaks to show in legend.
#'   Includes negative numbers and omits zero by default
#' @param ncol Number of columns in legend, 4 by default.
#' @param ... Additional parameters to pass to legend
#' @inheritParams slope_raster
#' @inheritParams sequential_dist
#'
#' @export
#' @examples
#' plot_slope(lisbon_route_3d)
#' route_xyz = lisbon_road_segment_3d
#' plot_slope(route_xyz)
#' plot_slope(route_xyz, brks = c(1, 2, 4, 8, 16, 30))
#' plot_slope(route_xyz, s = 5:8)
plot_slope = function(
  route_xyz,
  lonlat = sf::st_is_longlat(route_xyz),
  fill = TRUE,
  horiz = FALSE,
  pal =colorspace::diverging_hcl,
  legend_position = "top",
  col = "black",
  cex = 0.9,
  bg = grDevices::rgb(1, 1, 1, 0.8),
  title = "Slope colors (percentage gradient)",
  brks = c(3, 6, 10, 20, 40, 100),
  seq_brks = seq(from = 3, to = length(brks) * 2 - 2),
  ncol = 4,
  ...
  ) {
  dz = distance_z(route_xyz, lonlat = lonlat)
  plot_dz(dz$d, dz$z, seq_brks = seq_brks, brks = brks, ...)
}
#' Plot a digital elevation profile based on xyz data
#'
#' @param d Cumulative distance
#' @param z Elevations at points across a linestring
#' @inherit plot_slope
#' @examples
#' route_xyz = lisbon_road_segment_3d
#' m = sf::st_coordinates(route_xyz)
#' d = cumsum(sequential_dist(m, lonlat = FALSE))
#' d = c(0, d)
#' z = m[, 3]
#' slopes:::plot_dz(d, z, brks = c(3, 6, 10, 20, 40, 100))
plot_dz = function(
  d,
  z,
  fill = TRUE,
  horiz = FALSE,
  pal = colorspace::diverging_hcl,
  ...,
  legend_position = "top",
  col = "black",
  cex = 0.9,
  bg = grDevices::rgb(1, 1, 1, 0.8),
  title = "Slope colors (percentage gradient)",
  brks = NULL,
  seq_brks = NULL,
  ncol = 4
  ) {
  graphics::plot(d, z, type = "l", col = "brown", lwd = 2)
  if (fill) {
    b = make_breaks(brks)
    pal = make_pal(pal, b)
    g = slope_vector(x = d, elevations = z)
    colz = make_colz(g, b, pal)
    lapply(seq(d)[-(length(d))], function(i) {
      graphics::polygon(
        x = c(d[i:(i + 1)], d[(i + 1):i]),
        y = c(z[i], z[i + 1], 0, 0),
        col = colz[i],
        border = NA
      )
    })
    graphics::lines(d, z, col = col, lwd = 2)
    if(is.null(seq_brks)) seq_brks = seq(from = 3, to = length(b) - 2)
    s = c(seq_brks[-(length(seq_brks) / 2) -1], max(seq_brks) + 1)
    graphics::legend(x = legend_position, legend = b[s] * 100, fill = pal[s],
                     ..., bg = bg, title = title, horiz = horiz,
                     ncol = ncol, cex = cex)
  }
}

distance_z = function(route_xyz, lonlat) {
  m = sf::st_coordinates(route_xyz)
  d = cumsum(sequential_dist(m, lonlat = lonlat))
  d = c(0, d)
  z = m[, 3]
  list(d = d, z = z)
}

make_breaks = function(brks) {
  n = brks
  n = c(-rev(n), 0, (n))
  b = n / 100
  b
}

make_colz = function(g, b, pal) {
  colz = cut(
    x = g,
    breaks = b,
    labels = pal
    )
  as.character(colz)
}

make_pal = function(pal, b) {
  if (identical(pal, colorspace::diverging_hcl)) {
    pal = pal(n = length(b) - 1, palette = "Green-Brown")
  } else {
    pal = pal(n = length(b) - 1)
  }
  pal
}
