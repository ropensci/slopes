#' Calculate summary values for 'Z' elevation attributes
#'
#' The `slope_z*()` functions calculate summary values for the Z axis
#' in `sfc` objects with `XYZ` geometries.
#'
#' @param x An `sfc` object with \'XYZ\' coordinates
#' @return A vector of numeric values representing elevations associated with
#'   simple feature geometries that have elevations (XYZ coordinates).
#' @export
#' @examples
#' if (rlang::is_installed("sf")) {
#'   x = slopes::lisbon_route_3d
#'   x
#'   z_value(x)[1:5]
#'   xy = slopes::lisbon_route
#'   try(z_value(xy)) # error message
#'   z_start(x)
#'   z_end(x)
#'   z_direction(x)
#'   z_elevation_change_start_end(x)
#'   z_direction(x)
#'   z_cumulative_difference(x)
#' }
z_value = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster.")
  }
  coords[, "Z"]
}
#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the first Z coordinate.
z_start = function(x) {
  utils::head(z_value(x), 1)
}
#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the last Z coordinate.
z_end = function(x) {
  utils::tail(z_value(x), 1)
}
#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the mean of Z coordinates.
z_mean = function(x) {
  mean(z_value(x), na.rm = TRUE)
}
#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the maximum of Z coordinates.
z_max = function(x) {
  max(z_value(x), na.rm = TRUE)
}
#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the minimum of Z coordinates.
z_min = function(x) {
  min(z_value(x), na.rm = TRUE)
}
#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the difference between the last and first Z coordinates.
z_elevation_change_start_end = function(x) {
  z_end(x) - z_start(x)
}

#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the sign of the difference between the last and first Z coordinates.
z_direction = function(x) {
  sign(z_elevation_change_start_end(x))
}

#' @rdname z_value
#' @export
#' @return A numeric vector of length 1 representing the sum of absolute differences between consecutive Z coordinates.
z_cumulative_difference = function(x) {
  sum(abs(diff(z_value(x))))
}
