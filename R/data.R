#' Elevation in central Lisbon, Portugal
#'
#' A dataset containing elevation in and around Lisbon
#' with a geographic resolution of 10m.
#'
#' @format A raster dataset containing elevation above sea level
#'   in a 1km bounding box in Lisbon, Portugal.
#' @source \url{https://github.com/rspatial/terra/issues/29}
#' @examples
#' names(dem_lisbon_raster)
#' raster::plot(dem_lisbon_raster)
#' plot(lisbon_road_segments["Avg_Slope"], add = TRUE)
"dem_lisbon_raster"

#' Road segments in Lisbon
#'
#' A dataset representing road segments in Lisbon,
#'   with X, Y and Z (elevation) dimensions for each coordinate.
#'
#' @format An object of class `sf`
#' @source Produced by ESRI's
#'  [3D Analyst extension](https://pro.arcgis.com/en/pro-app/help/analysis/)
#' @examples
#' names(lisbon_road_segments)
#' plot(lisbon_road_segments["Avg_Slope"])
"lisbon_road_segments"

#' A road segment in Lisbon, Portugal
#'
#' A single road segment and a 3d version.
#'
#' @format An object of class `sf`
#' @source Produced by ESRI's
#'  [3D Analyst extension](https://pro.arcgis.com/en/pro-app/help/analysis/)
#' @aliases lisbon_road_segment_3d lisbon_route lisbon_route_3d
#' @examples
#' lisbon_road_segment
#' lisbon_road_segment_3d
"lisbon_road_segment"

#' A journey from CycleStreets.net
#'
#' Road segments representing suggested route to cycle
#' in Leeds, UK.
#'
#' @format An object of class `sf`
#' @source CycleStreets.net
#' @examples
#' # cyclestreets_route = cyclestreets::journey(
#' #   stplanr::geo_code("Potternewton Park Leeds"),
#' #   stplanr::geo_code("University of Leeds")
#' # )
#' # usethis::use_data(cyclestreets_route)
#' class(cyclestreets_route)
#' # plot(cyclestreets_route)
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
