#' Elevation in central Lisbon, Portugal
#'
#' A dataset containing elevation in and around Lisbon with a geographic resolution of 10m.
#'
#' @format A raster dataset containing elevation above sea level in a 1km bounding box in Lisbon, Portugal.
#' @source \url{https://github.com/rspatial/terra/issues/29}
#' @examples
#' names(dem_lisbon_raster)
#' raster::plot(dem_lisbon_raster)
#' plot(lisbon_road_segments["Avg_Slope"], add = TRUE)
"dem_lisbon_raster"

#' Road segments in Lisbon
#'
#' A dataset representing road segments in Lisbon, with X, Y and Z (elevation) dimensions for each coordinate.
#'
#' @format And object of class `sf`
#' @source Produced by ESRI's [3D Analyst extension](https://pro.arcgis.com/en/pro-app/help/analysis/3d-analyst/get-started-with-3d-analyst-in-pro.htm)
#' @examples
#' names(lisbon_road_segments)
#' plot(lisbon_road_segments["Avg_Slope"])
"lisbon_road_segments"

#' A road segment in Lisbon, Portugal
#'
#' A single road segment and a 3d version.
#'
#' @format And object of class `sf`
#' @source Produced by ESRI's [3D Analyst extension](https://pro.arcgis.com/en/pro-app/help/analysis/3d-analyst/get-started-with-3d-analyst-in-pro.htm)
#' @aliases lisbon_road_segment_3d
#' @examples
#' lisbon_road_segment
#' lisbon_road_segment_3d
"lisbon_road_segment"
