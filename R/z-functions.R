
z_value <- function(x) {
  coords <- sf::st_coordinates(x)
  if("Z" %in% colnames(coords)) {
    return(coords[, "Z"])
  } else {
    stop("No Z coordinates found in the input data")
  }
}

z_mean <- function(x) {
  mean(z_value(x), na.rm = TRUE)
}

z_min <- function(x) {
  min(z_value(x), na.rm = TRUE)
}

z_max <- function(x) {
  max(z_value(x), na.rm = TRUE)
}

z_start <- function(x) {
  z_vals <- z_value(x)
  z_vals[1]
}

z_end <- function(x) {
  z_vals <- z_value(x)
  z_vals[length(z_vals)]
}

