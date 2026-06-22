# Raster / matrix utility functions for slope data
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
