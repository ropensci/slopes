#' Plot slope data for a 3d linestring with base R graphics
#'
#' @param r A linestring with xyz dimensions
#' @inheritParams plot_dz
#'
#' @export
#' @examples
#' r = lisbon_road_segment_3d
#' plot_slope(r)
plot_slope = function(r, fill = TRUE) {
  m = sf::st_coordinates(r)
  d = cumsum(sequential_dist(m, lonlat = FALSE))
  d = c(0, d)
  z = m[, 3]
  plot_dz(d, z, fill = fill)
}
#' Plot a digital elevation profile based on xyz data
#'
#' @param d Cumulative distance
#' @param z Elevations at points across a linestring
#' @param p Color palette to use
#' @param fill Should the profile be filled? `TRUE` by default.
#' @export
#' @examples
#' r = lisbon_road_segment_3d
#' m = sf::st_coordinates(r)
#' d = cumsum(sequential_dist(m, lonlat = FALSE))
#' d = c(0, d)
#' z = m[, 3]
#' plot_dz(d, z)
plot_dz = function(d, z, fill = TRUE, p = ifelse(
  test = require(colorspace),
  colorspace::diverging_hcl,
  grDevices::terrain.colors
  )) {
  graphics::plot(d, z, type = "l", col = "brown", lwd = 2)
  if(fill) {
    n = c(0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 100)
    n = c(-rev(n), (n[-1]))
    b = n / 100
    if(identical(p, colorspace::diverging_hcl)) {
      pal = p(n = length(b) - 1, palette = "Green-Brown")
    } else {
      pal = p(n = length(b) - 1)
    }
    g = slope_vector(x = d, e = z)
    colz = cut(x = g, breaks = b, labels = pal)
    colz = as.character(colz)
    lapply(seq(d)[-(length(d))], function(i) {
      graphics::polygon(
        x = c(d[i:(i+1)], d[(i+1):i]),
        y = c(z[i], z[i+1], 0, 0),
        col = colz[i],
        border = NA
        )
    })
    graphics::lines(d, z, col = "black", lwd = 2)
    s = seq(from = 3, to = length(n) - 1, by = 2)
    graphics::legend(x = "topright", legend = paste(n[s], "%"), fill = pal[s],
                   cex = 0.9, title = "Slope")
  }
}
# g = slope_matrix(m)
# abline(h = 0, lty = 2)
# points(x[-length(x)], gx, col = "red")
# points(x[-length(x)], gxy, col = "blue")
# title("Distance (in x coordinates) elevation profile",
#       sub = "Points show calculated gradients of subsequent lines")
