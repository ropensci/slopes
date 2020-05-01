#' Calculate the gradient of line segments from distance and elevation vectors
#'
#' @param x Vector of locations
#' @param e Elevations in same units as x (assumed to be metres)
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' e = c(1, 2, 2, 4, 3, 1) / 10
#' slope_vector(x, e)
slope_vector = function(x, e) {
  d = diff(x)
  e_change = diff(e)
  e_change / d
}

#' Calculate the gradient of line segments from a matrix of coordinates
#'
#' @param m Matrix containing coordinates and elevations
#' @inheritParams slope_vector
#' @inheritParams sequential_dist
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' y = c(0, 0, 0, 0, 0, 9)
#' z = c(1, 2, 2, 4, 3, 1) / 10
#' m = cbind(x, y, z)
#' plot(x, z, ylim = c(-0.5, 0.5), type = "l")
#' (gx = slope_vector(x, z))
#' (gxy = slope_matrix(m, lonlat = FALSE))
#' abline(h = 0, lty = 2)
#' points(x[-length(x)], gx, col = "red")
#' points(x[-length(x)], gxy, col = "blue")
#' title("Distance (in x coordinates) elevation profile",
#'   sub = "Points show calculated gradients of subsequent lines")
slope_matrix = function(m, e = m[, 3], lonlat = TRUE) {
  d = sequential_dist(m, lonlat = lonlat)
  e_change = diff(e)
  g = e_change / d
  g
}

#' Calculate the sequential distances between sequential coordinate pairs
#'
#' @param lonlat Are the coordinates in lon/lat order? `TRUE` by default
#' @inheritParams slope_matrix
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' y = c(0, 0, 0, 0, 0, 1)
#' m = cbind(x, y)
#' sequential_dist(m)
sequential_dist = function(m, lonlat = TRUE) {
  if(lonlat) {
    if(requireNamespace("geodist")) {
      geodist::geodist(m[, 1:2], sequential = TRUE) # lon lat
    } else {
      message("Install geodist")
    }
  } else {
    sqrt(diff(m[, 1])^2 + diff(m[, 2])^2)
  }
}


rg3d = function(x, elevation = NULL) {
  m = sf::st_coordinates(x)
  x_sfc = sf::st_sfc(x)
  if(!is.null(elevation)) {
    e = slope_extract_elevation_from_raster()
  } else {
    e = x[, 3]
  }
  g1 = slope_matrix(m, e = e, lonlat = FALSE)
  d = sequential_dist(m = m, lonlat = FALSE)
  stats::weighted.mean(abs(g1), d, na.rm = TRUE)
}

slope_raster = function(r, e = NULL) {
  res_list =
    if (requireNamespace("pbapply", quietly = TRUE)) {
      pbapply::pblapply(sf::st_geometry(r), rg3d, e = e)
    } else {
      lapply(sf::st_geometry(r), rg3d, e = e)
    }
  unlist(res_list)
}

# m = sf::st_coordinates(lisbon_road_segments[1, ])
# e = dem_lisbon_raster
# slope_extract_elevation_from_raster(m, e)
slope_extract_elevation_from_raster = function(m, e, method = "bilinear") {
  raster::extract(e, m[, 1:2], method = method)
}
