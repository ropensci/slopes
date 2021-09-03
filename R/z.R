#' Calculate summary values for 'Z' elevation attributes
#'
#' The `slope_z*()` functions calculate summary values for the Z axis
#' in `sfc` objects with `XYZ` geometries.
#'
#' @param x An `sfc` object with 'XYZ' coordinates
#' @return A vector of values representing elevations associated with
#'   simple feature geometries that have elevations (XYZ coordinates).
#' @export
#' @examples
#' x = slopes::lisbon_route_3d
#' x
#' z_value(x)[1:5]
#' xy = slopes::lisbon_route
#' try(z_value(xy)) # error message
#' z_start(x)
#' z_end(x)
#' z_direction(x)
#' z_elevation_change_start_end(x)
#' z_direction(x)
#' z_cumulative_difference(x)
z_value = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster.")
  }
  coords[, "Z"]
}
#' @rdname z_value
#' @export
z_start = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster.")
  }
  coords[, "Z"][1]
}
#' @rdname z_value
#' @export
z_end = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster.")
  }
  coords[, "Z"][nrow(coords)]
}
#' @rdname z_value
#' @export
z_mean = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster.")
  }
  mean(coords[, "Z"], na.rm = TRUE)
}
#' @rdname z_value
#' @export
z_max = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster.")
  }
  max(coords[, "Z"], na.rm = TRUE)
}
#' @rdname z_value
#' @export
z_min = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster.")
  }
  min(coords[, "Z"], na.rm = TRUE)
}
#' @rdname z_value
#' @export
z_elevation_change_start_end = function(x) {
  z_end(x) - z_start(x)
}

#' @rdname z_value
#' @export
z_direction = function(x) {
  sign(z_elevation_change_start_end(x))
}

#' @rdname z_value
#' @export
z_cumulative_difference = function(x) {
  sum(abs(diff(z_value(x))))
}
