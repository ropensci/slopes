#' Get elevation data for routes
#'
#' Downloads elevation data using the ceramic package for given routes.
#' Returns a `SpatRaster` object (terra package).
#'
#' @param routes An sf object containing linestring geometries
#' @param ... Additional arguments passed to ceramic::cc_elevation
#' @param output_format Deprecated. Ignored; always returns a SpatRaster.
#' @return A SpatRaster covering the routes
#' @export
elevation_get = function(routes, ..., output_format = NULL) {
  if (!is.null(output_format)) {
    .Deprecated(msg = "The 'output_format' argument is deprecated. elevation_get() now always returns a SpatRaster.")
  }
  if (!requireNamespace("ceramic", quietly = TRUE)) {
    stop("Install the package ceramic to use elevation_get().")
  }
  mid_ext = sf_mid_ext_lonlat(routes)
  bw = max(c(mid_ext$width, mid_ext$height)) / 1 # buffer width
  suppressWarnings({
    e = ceramic::cc_elevation(loc = mid_ext$midpoint, buffer = bw, ...)
  })
  crs_routes = sf::st_crs(routes)
  terra::project(e, y = crs_routes$wkt)
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

#' Convert slope matrix to SpatRaster
#'
#' Converts a slope matrix or a legacy RasterLayer to a SpatRaster (terra).
#' Accepts `SpatRaster`, legacy `Raster*`, or a plain matrix.
#'
#' @param x A matrix, SpatRaster, or legacy RasterLayer object
#' @return A SpatRaster object
#' @export
slope_matrix_to_raster <- function(x) {
  if (methods::is(x, "SpatRaster")) {
    return(x)
  }
  if (methods::is(x, "Raster")) {
    message("Converting legacy Raster* object to SpatRaster. Consider using terra::rast() directly.")
    return(terra::rast(x))
  }
  if (is.matrix(x)) {
    return(terra::rast(x))
  }
  stop("Input must be a matrix, SpatRaster, or legacy RasterLayer")
}

#' Extract XYZ coordinates from SpatRaster or matrix
#'
#' Simplifies raster or matrix data to XYZ coordinate format.
#' Accepts `SpatRaster` (terra), legacy `Raster*` objects, or a plain matrix.
#'
#' @param x A SpatRaster, legacy RasterLayer, or matrix object
#' @return A data frame with x, y, z coordinates
#' @export
slope_xyz_simple <- function(x) {
  if (methods::is(x, "Raster")) {
    message("Converting legacy Raster* object to SpatRaster. Consider using terra::rast() directly.")
    x <- terra::rast(x)
  }
  if (methods::is(x, "SpatRaster")) {
    df <- terra::as.data.frame(x, xy = TRUE)
    names(df) <- c("x", "y", "z")
    return(df)
  }
  if (is.matrix(x)) {
    df <- as.data.frame(as.table(x))
    names(df) <- c("y", "x", "z")
    return(df)
  }
  stop("Input must be a SpatRaster, legacy RasterLayer, or matrix")
}
