
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

#' Cycle route data
#' @format An sf object
"cyclestreets_route"

#' Lisbon road network
#' @format An sf object
"lisbon_road_network"

#' Lisbon road segment
#' @format An sf object
"lisbon_road_segment"

#' Lisbon road segment 3D
#' @format An sf object
"lisbon_road_segment_3d"

#' Lisbon road segment XYZ
#' @format An sf object
"lisbon_road_segment_xyz_mapbox"

#' Lisbon route data
#' @format An sf object
"lisbon_route"

#' Lisbon route 3D
#' @format An sf object
"lisbon_route_3d"

#' Lisbon route XYZ
#' @format An sf object
"lisbon_route_xyz_mapbox"

#' Magnolia coordinates
#' @format A data frame
"magnolia_xy"
