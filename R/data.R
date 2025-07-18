#' Elevation in central Lisbon, Portugal
#'
#' A dataset containing elevation in and around Lisbon
#' with a geographic resolution of 10m.
#' The dataset is 200 pixels wide by 133 pixels high, covering
#' 2.7 square kilometres of central Lisbon.
#'
#' The dataset was acquired by Instituto Superior
#' Técnico (University of Lisbon) in 2012, covers all the Northern
#' Metropolitan Area of Lisbon, and has a 10m cell resolution,
#' when projected at the official Portuguese EPSG: 3763 - TM06/ETRS89.
#' The dataset was released as an open access dataset with permission from the
#' University of Lisbon to support this project.
#'
#' @format A raster dataset containing elevation above sea level
#'   in a 1km bounding box in Lisbon, Portugal.
#'
#' @source \url{https://github.com/rspatial/terra/issues/29}
#' @examples
#' library(sf)
#' library(raster)
#' dim(dem_lisbon_raster)
#' res(dem_lisbon_raster)
#' names(dem_lisbon_raster)
#' plot(dem_lisbon_raster)
#' if (rlang::is_installed("sf")) {
#'   plot(lisbon_road_network["Avg_Slope"], add = TRUE)
#' }
"dem_lisbon_raster"

#' Road segments in Lisbon
#'
#' A dataset representing road segments in Lisbon,
#'   with X, Y and Z (elevation) dimensions for each coordinate.
#'
#' The dataset covers 32 km of roads in central Lisbon, overlapping with the
#' area covered by the `dem_lisbon_raster` dataset.
#'
#' @format An object of class `sf`, key variables of which include
#' \describe{
#'   \item{OBJECTID}{ID of the object}
#'   \item{Z_Min}{The minimum elevation on the linear feature from ArcMAP}
#'   \item{Z_Max}{The max elevation on the linear feature from ArcMAP}
#'   \item{Z_Mean}{The mean elevation on the linear feature from ArcMAP}
#'   \item{Slope_Min}{The minimum slope on the linear feature from ArcMAP}
#'   \item{Slope_Max}{The max slope on the linear feature from ArcMAP}
#'   \item{Slope_Mean}{The mean slope on the linear feature from ArcMAP}
#'   \item{geom}{The geometry defining the LINESTRING component of the segment}
#' }
#' @source Produced by ESRI's
#'  3D Analyst extension
#' @examples
#' library(sf)
#' names(lisbon_road_network)
#' sum(st_length(lisbon_road_network))
#' plot(lisbon_road_network["Avg_Slope"])
"lisbon_road_network"

#' A route composed of a single linestring in Lisbon, Portugal
#'
#' A route representing a trip from the Santa Catarina area
#' in the East of central Lisbon the map to the Castelo de São Jorge
#' in the West of central Lisbon.
#'
#' Different versions of this dataset are provided.
#'
#' The `lisbon_route` object has 1 row and 4 columns: geometry, ID,
#'   length and whether or not a path was found.
#'
#' The `lisbon_route_xyz_mapbox` was created with:
#' `lisbon_route_xyz_mapbox = elevation_add(lisbon_route)`.
#'
#' @format An object of class `sf`
#' @source See the `lisbon_route.R` script in `data-raw`
#' @aliases lisbon_route_3d lisbon_route_xyz_mapbox
#' @examples
#' lisbon_route
#' lisbon_route_3d
#' lisbon_route_xyz_mapbox
"lisbon_route"

#' A road segment in Lisbon, Portugal
#'
#' A single road segment and a 3d version.
#' Different versions of this dataset are provided.
#'
#' The `lisbon_road_segment` has 23 columns and 1 row.
#'
#' The `lisbon_road_segment_xyz_mapbox` was created with:
#' `lisbon_road_segment_xyz_mapbox = elevation_add(lisbon_road_segment)`.
#'
#' @format An object of class `sf`
#' @source Produced by ESRI's
#'  3D Analyst extension
#' @aliases lisbon_road_segment_3d lisbon_road_segment_xyz_mapbox
#' @examples
#' lisbon_road_segment
#' lisbon_road_segment_3d
#' lisbon_road_segment_xyz_mapbox
"lisbon_road_segment"

#' A journey from CycleStreets.net
#'
#' Road segments representing suggested route to cycle
#' in Leeds, UK.
#'
#' Simple feature collection with 30 features and 32 fields
#'
#' See `data-raw/cyclestreets_route.R` in the package's github repo for details.
#'
#' @format An object of class `sf` with 18 rows and 14 columns on route
#'   characteristics. See https://rpackage.cyclestreets.net/reference/journey.html
#'   for details.
#' @source CycleStreets.net
#' @examples
#' library(sf)
#' class(cyclestreets_route)
#' plot(cyclestreets_route$geometry)
#' cyclestreets_route
"cyclestreets_route"

#' Road segments in Magnolia, Seattle
#'
#' A dataset representing road segments in the Magnolia area of Seattle
#' with X, Y and Z (elevation) dimensions for each coordinate.
#'
#' @format An object of class `sf`
#' @source Accessed in early 2021 from the `seattle-streets` layer from the
#' [data-seattlecitygis](https://data-seattlecitygis.opendata.arcgis.com/)
#' website.
#' @examples
#' names(magnolia_xy)
#' plot(magnolia_xy["SLOPE_PCT"])
"magnolia_xy"
