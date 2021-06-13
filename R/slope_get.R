#' Get elevation data from hosted maptile services
#'
#' @param file Where to save the resulting data if specified (not implemented)
#' @param ... Options passed to `cc_elevation()`
#' @inheritParams slope_raster
#' @export
#' @examples
#' # time-consuming, and see
#' # https://github.com/ITSLeeds/slopes/runs/648128378#step:18:107
#' routes = cyclestreets_route
#' # e = elevations_get(routes)
#' # class(e)
#' # e
#' # plot(e)
#' # plot(sf::st_geometry(routes), add = TRUE)
elevations_get = function(routes, file = NULL, ...) {
  if(requireNamespace("ceramic")) {
    mid_ext = sf_mid_ext_lonlat(routes)
    bw = max(c(mid_ext$width, mid_ext$height)) / 1 # buffer width
    e = ceramic::cc_elevation(loc = mid_ext$midpoint, buffer = bw, ...)
  } else {
    message("Install the package ceramic")
  }
  # issue: cannot convert CRS currently
  # cr = sf::st_crs(routes)
  # cr$wkt
  # raster::crs(e) = raster::crs("+init=epsg:3857")
  # raster::projectRaster(e, "+init=epsg:4326")
  # raster::projectRaster(e, sf::st_crs(routes)[[2]])
  e
}

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
