#' Get elevation data from hosted maptile services
#'
#' @param file Where to save the resulting data if specified (not implemented)
#' @param ... Options passed to `cc_elevation()`
#' @inheritParams slope_raster
#' @export
#' @examples
#' # time-consuming, and see
#' # https://github.com/ITSLeeds/slopes/runs/648128378#step:18:107
#' r = cyclestreets_route
#' # e = elevations_get(r)
#' # class(e)
#' # e
#' # plot(e)
#' # plot(sf::st_geometry(r), add = TRUE)
elevations_get = function(r, file = NULL, ...) {
  if(requireNamespace("ceramic")) {
    mid_ext = sf_mid_ext_lonlat(r)
    bw = max(c(mid_ext$width, mid_ext$height)) / 1 # buffer width
    e = ceramic::cc_elevation(loc = mid_ext$midpoint, buffer = bw, ...)
  } else {
    message("Install the package ceramic")
  }
  # issue: cannot convert CRS currently
  # cr = sf::st_crs(r)
  # cr$wkt
  # raster::crs(e) = raster::crs("+init=epsg:3857")
  # raster::projectRaster(e, "+init=epsg:4326")
  # raster::projectRaster(e, sf::st_crs(r)[[2]])
  e
}
#
# trace_projected = sf::st_transform(trace, 3857)
# plot(e)
# plot(trace_projected$geometry, add = TRUE)
#
# # aim: get max distance from centrepoint
# bb = sf::st_bbox(sf::st_transform(trace, 4326))

# # max of those 2 and divide by 2

sf_mid_ext_lonlat = function(r) {
  res = list()
  if(!sf::st_is_longlat(r)) {
    r = sf::st_transform(r, 4326)
  }
  bb = sf::st_bbox(r)
  res$midpoint = c(mean(c(bb[1], bb[3])), mean(c(bb[2], bb[4])))
  res$width = geodist::geodist(c(x = bb[1], y = bb[2]), c(x = bb[3], y = bb[2]))
  res$height = geodist::geodist(c(x = bb[1], y = bb[2]), c(x = bb[1], y = bb[4]))
  res
}
