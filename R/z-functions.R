
#' Extract elevation values from xyz linestring
#' 
#' @param x An sf object with XYZ coordinates
#' @return A numeric vector of elevation values
#' @export
z_value <- function(x) {
  coords <- sf::st_coordinates(x)
  if("Z" %in% colnames(coords)) {
    return(coords[, "Z"])
  } else {
    stop("No Z coordinates found in the input data")
  }
}

#' Extract mean elevation from xyz linestring
#' 
#' @param x An sf object with XYZ coordinates  
#' @return A numeric value representing mean elevation
#' @export
z_mean <- function(x) {
  mean(z_value(x), na.rm = TRUE)
}

#' Extract minimum elevation from xyz linestring
#' 
#' @param x An sf object with XYZ coordinates
#' @return A numeric value representing minimum elevation
#' @export
z_min <- function(x) {
  min(z_value(x), na.rm = TRUE)
}

#' Extract maximum elevation from xyz linestring
#' 
#' @param x An sf object with XYZ coordinates
#' @return A numeric value representing maximum elevation
#' @export
z_max <- function(x) {
  max(z_value(x), na.rm = TRUE)
}

#' Extract starting elevation from xyz linestring
#' 
#' @param x An sf object with XYZ coordinates
#' @return A numeric value representing starting elevation
#' @export
z_start <- function(x) {
  z_vals <- z_value(x)
  z_vals[1]
}

#' Extract ending elevation from xyz linestring
#' 
#' @param x An sf object with XYZ coordinates
#' @return A numeric value representing ending elevation
#' @export
z_end <- function(x) {
  z_vals <- z_value(x)
  z_vals[length(z_vals)]
}

