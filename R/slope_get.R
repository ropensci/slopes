#' Get elevation data for routes
#'
#' Downloads elevation data using the ceramic package for given routes.
#'
#' @param routes An sf object containing linestring geometries
#' @param ... Additional arguments passed to ceramic::cc_elevation
#' @param output_format Character string specifying output format ("raster" or "terra")
#' @return Elevation raster data covering the routes
#' @export
elevation_get = function(routes, ..., output_format = "raster") {
  if(requireNamespace("ceramic")) {
    mid_ext = sf_mid_ext_lonlat(routes)
    bw = max(c(mid_ext$width, mid_ext$height)) / 1 # buffer width
    suppressWarnings({
      e = ceramic::cc_elevation(loc = mid_ext$midpoint, buffer = bw, ...)
    })
  } else {
    message("Install the package ceramic")
  }
  crs_routes = sf::st_crs(routes)
  if(!requireNamespace("terra", quietly = TRUE)) {
    message('install.packages("terra") # for this to work')
  }
  res = terra::project(e, y = crs_routes$wkt)
  if(output_format == "raster") {
    res = raster::raster(res)
  }
  res
}

#' Extract midpoint and extent from routes in lonlat
#'
#' Internal helper function to get midpoint and extent of routes in lon/lat coordinates.
#'
#' @param routes An sf object containing linestring geometries
#' @return A list with midpoint coordinates and width/height dimensions
sf_mid_ext_lonlat = function(routes) {
  res = list()
  if(!sf::st_is_longlat(routes)) {
    routes = sf::st_transform(routes, 4326)
  }
  bb = sf::st_bbox(routes)
  res$midpoint = c(mean(c(bb[1], bb[3])), mean(c(bb[2], bb[4])))
  res$width = geodist::geodist(c(x = bb[1], y = bb[2]), c(x = bb[3], y = bb[2]))
  res$height = geodist::geodist(
    c(x = bb[1], y = bb[2]),
    c(x = bb[1], y = bb[4])
  )
  res
}

#' Convert slope matrix to raster
#'
#' Converts a slope matrix or checks if input is already a raster.
#'
#' @param x A matrix or RasterLayer object
#' @return A RasterLayer object
#' @export
slope_matrix_to_raster <- function(x) {  # <-- Changed name
  if (inherits(x, "Raster")) {
    return(x)
  }
  if (is.matrix(x)) {
    return(raster::raster(x))
  }
  stop("Input must be a matrix or RasterLayer")
}

#' Extract XYZ coordinates from raster or matrix
#'
#' Simplifies raster or matrix data to XYZ coordinate format.
#'
#' @param x A RasterLayer or matrix object
#' @return A data frame with x, y, z coordinates
#' @export
slope_xyz_simple <- function(x) {
  if (inherits(x, "Raster")) {
    xy <- raster::xyFromCell(x, 1:raster::ncell(x))
    return(data.frame(x = xy[, 1], y = xy[, 2], z = raster::getValues(x)))
  }
  if (is.matrix(x)) {
    df <- as.data.frame(as.table(x))
    names(df) <- c("y", "x", "z")
    return(df)
  }
  stop("Input must be a RasterLayer or matrix")
}
