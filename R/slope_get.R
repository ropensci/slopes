#' Get elevation data from hosted maptile services
#'
#' `elevation_get()` uses the `[ceramic::cc_elevation()]` function to get
#' DEM data in raster format anywhere worldwide.
#' It requires an API that can be added by following guidance in the package's
#' [README](https://github.com/ITSLeeds/slopes#installation-for-dem-downloads).
#'
#'
#' Note: if you use the `cc_elevation()` function directly to get DEM data,
#' you can cache the data, as described in the package's
#' [README](https://github.com/hypertidy/ceramic#local-caching-of-tiles).
#'
#' @param file Where to save the resulting data if specified (not implemented)
#' @param ... Options passed to `cc_elevation()`
#' @inheritParams slope_raster
#' @export
#' @examples
#' # Time-consuming examples that require an internet connection and API key:
#' \donttest{
#' library(sf)
#' library(raster)
#' routes = cyclestreets_route
#' e = elevation_get(routes)
#' class(e)
#' e
#' plot(e)
#' plot(sf::st_geometry(routes), add = TRUE)
#' }
elevation_get = function(routes, ...) {
  if(requireNamespace("ceramic")) {
    mid_ext = sf_mid_ext_lonlat(routes)
    bw = max(c(mid_ext$width, mid_ext$height)) / 1 # buffer width
    suppressWarnings({
      e = ceramic::cc_elevation(loc = mid_ext$midpoint, buffer = bw, ...)
    })
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
