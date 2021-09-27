#' Get elevation data from hosted maptile services
#'
#' `elevation_get()` uses the
#' [`cc_elevation()`](https://hypertidy.github.io/ceramic/reference/cc_location.html)
#' function from the `ceramic` package to get
#' DEM data in raster format anywhere worldwide.
#' It requires an API that can be added by following guidance in the package's
#' [README](https://github.com/ITSLeeds/slopes#installation-for-dem-downloads)
#' and in the
#' [`slopes` vignette](https://ropensci.github.io/slopes/articles/slopes.html).
#'
#'
#' Note: if you use the `cc_elevation()` function directly to get DEM data,
#' you can cache the data, as described in the package's
#' [README](https://github.com/hypertidy/ceramic#local-caching-of-tiles).
#'
#' @param ... Options passed to `cc_elevation()`
#' @param output_format What format to return the data in?
#'   Accepts `"raster"` (the default) and `"terra"`.
#' @inheritParams slope_raster
#' @return A raster object with cell values representing elevations in the
#'   bounding box of the input `routes` object.
#' @export
#' @examples
#' # Time-consuming examples that require an internet connection and API key:
#' \donttest{
#' library(sf)
#' library(raster)
#' routes = cyclestreets_route
#' e = elevation_get(routes)
#' class(e)
#' crs(e)
#' e
#' plot(e)
#' plot(st_geometry(routes), add = TRUE)
#' }
elevation_get = function(routes, ..., output_format = "raster") {
  if(requireNamespace("ceramic")) {
    mid_ext = sf_mid_ext_lonlat(routes)
    bw = max(c(mid_ext$width, mid_ext$height)) / 1 # buffer width
    suppressWarnings({
      e = ceramic::cc_elevation(loc = mid_ext$midpoint, buffer = bw, ...)
    })
  } else {
    message("Install the package ceramic")
  }
  crs_routes = sf::st_crs(routes)
  if(!requireNamespace("terra", quietly = TRUE)) {
    message('install.packages("terra") # for this to work')
  }
  et = terra::rast(e)
  res = terra::project(et, y = crs_routes$wkt)
  if(output_format == "raster") {
    res = raster::raster(res)
  }
  res
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
