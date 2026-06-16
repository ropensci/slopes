#' Read the bundled Lisbon DEM as a SpatRaster
#'
#' Returns a `SpatRaster` (terra package) of the Digital Elevation Model
#' for central Lisbon, Portugal, bundled with the slopes package.
#'
#' @return A `SpatRaster` object with 133 rows, 200 columns, and 1 elevation layer.
#' @export
#' @examples
#' dem_lisbon()
dem_lisbon <- function() {
  tif <- system.file("dem_lisbon.tif", package = "slopes")
  if (!nzchar(tif)) stop("dem_lisbon.tif not found in slopes package installation.")
  terra::rast(tif)
}
