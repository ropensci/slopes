#' Calculate summary values for 'Z' elevation attributes
#'
#' The `slope_z*()` functions calculate summary values for the Z axis
#' in `sfc` objects with `XYZ` geometries.
#'
#' @param x An `sfc` object with 'XYZ' coordinates
#'
#' @export
#' @examples
#' x = slopes::lisbon_route_3d
#' sf::st_geometry(x)
#' slope_z_value(x)[1:5]
#' xy = slopes::lisbon_route
#' # slope_z_value(xy) # error message
#' slope_z_start(x)
#' slope_z_end(x)
slope_z_value = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster for details")
  }
  coords[, "Z"]
}
#' @rdname slope_z_value
#' @export
slope_z_start = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster for details")
  }
  coords[, "Z"][1]
}
#' @rdname slope_z_value
#' @export
slope_z_end = function(x) {
  coords = sf::st_coordinates(x)
  if(!"Z" %in% colnames(coords)) {
    stop("Requires object that have XYZ geometries, see ?slope_raster for details")
  }
  coords[, "Z"][nrow(coords)]
}
slope_z_mean = function(x) {
  # ...
}
slope_z_max = function(x) {
  # ...
}
slope_z_min = function(x) {
  # ...
}
slope_z_direction = function(x) {
  # ...
}
