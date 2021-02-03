#' Plot slope data for a 3d linestring with base R graphics
#'
#' @param r A linestring with xyz dimensions
#' @inheritParams plot_dz
#' @inheritParams sequential_dist
#'
#' @export
#' @examples
#' plot_slope(lisbon_route_3d)
#' r = lisbon_road_segment_3d
#' plot_slope(r)
#' r = lisbon_road_segment_3d
plot_slope = function(r,
                      lonlat = sf::st_is_longlat(r),
                      fill = TRUE,
                      horiz = FALSE,
                      p = ifelse(
                        test = requireNamespace("colorspace", quietly = TRUE),
                        colorspace::diverging_hcl,
                        grDevices::terrain.colors
                      ),
                      ...,
                      x = "top",
                      col = "black",
                      cex = 0.9,
                      bg = grDevices::rgb(1, 1, 1, 0.8),
                      title = "Slope colors (percentage gradient)",
                      s = 3:18,
                      ncol = 4) {
  dz = distance_z(r, lonlat = lonlat)
  plot_dz(dz$d, dz$z, fill = fill)
}
#' Plot a digital elevation profile based on xyz data
#'
#' @param d Cumulative distance
#' @param z Elevations at points across a linestring
#' @param p Color palette to use
#' @param fill Should the profile be filled? `TRUE` by default
#' @param x Keyword, one of "bottomright", "bottom",
#' "bottomleft", "left", "topleft", "top", "topright", "right" and "center"
#' @param col Line colour
#' @param cex Legend size
#' @param bg Legend background colour
#' @param title Title of the legend
#' @param brks Breaks in colour palette to show.
#'   `c(1, 3, 6, 10, 20, 40, 100)` by default.
#' @param s Sequence of numbers to show in legend
#' @param ncol Number of columns in legend
#' @param horiz Should the legend be horizontal (`FALSE` by default)
#' @param ... Additional parameters to pass to legend
#' @export
#' @examples
#' r = lisbon_road_segment_3d
#' m = sf::st_coordinates(r)
#' d = cumsum(sequential_dist(m, lonlat = FALSE))
#' d = c(0, d)
#' z = m[, 3]
#' plot_dz(d, z)
plot_dz = function(d,
                   z,
                   fill = TRUE,
                   horiz = FALSE,
                   p = ifelse(
                     test = requireNamespace("colorspace", quietly = TRUE),
                     colorspace::diverging_hcl,
                     grDevices::terrain.colors
                   ),
                   ...,
                   x = "top",
                   col = "black",
                   cex = 0.9,
                   bg = grDevices::rgb(1, 1, 1, 0.8),
                   title = "Slope colors (percentage gradient)",
                   brks = c(3, 6, 10, 20, 40, 100),
                   s = NULL,
                   ncol = 4) {
  graphics::plot(d, z, type = "l", col = "brown", lwd = 2)
  if (fill) {
    b = make_breaks(brks)
    pal = make_pal(p, b)
    g = slope_vector(x = d, e = z)
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
    if(is.null(s)) s = seq(from = 3, to = length(b) - 2)
    graphics::legend(x = x, legend = b[s] * 100, fill = pal[s],
                     ..., bg = bg, title = title, horiz = horiz,
                     ncol = ncol, cex = cex)
  }
}
# g = slope_matrix(m)
# abline(h = 0, lty = 2)
# points(x[-length(x)], gx, col = "red")
# points(x[-length(x)], gxy, col = "blue")
# title("Distance (in x coordinates) elevation profile",
#       sub = "Points show calculated gradients of subsequent lines")

distance_z = function(r, lonlat) {
  m = sf::st_coordinates(r)
  d = cumsum(sequential_dist(m, lonlat = lonlat))
  d = c(0, d)
  z = m[, 3]
  list(d = d, z = z)
}

make_breaks = function(brks) {
  n = brks
  n = c(-rev(n), (n))
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

make_pal = function(p, b) {
  if (identical(p, colorspace::diverging_hcl)) {
    pal = p(n = length(b) - 1, palette = "Green-Brown")
  } else {
    pal = p(n = length(b) - 1)
  }
  pal
}
