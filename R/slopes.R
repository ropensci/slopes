#' Calculate the gradient of line segments from distance and elevation vectors
#'
#' @description
#'
#' `slope_vector()` calculates the slopes associated with consecutive elements
#'   in one dimensional distance and associated elevations (see examples).
#'
#' `slope_distance()` calculates the slopes associated with consecutive
#'   distances and elevations.
#'
#' `slope_distance_mean()` calculates the mean average slopes associated with
#'   consecutive distances and elevations.
#'
#' `slope_distance_weighted()` calculates the slopes associated with
#'   consecutive distances and elevations,
#'   with the mean value associated with each set of distance/elevation
#'   vectors weighted in proportion to the distance between each elevation
#'   measurement, so longer sections have proportionally more influence
#'   on the resulting gradient estimate (see examples).
#'
#' @param x Vector of locations
#' @param d Vector of distances between points
#' @param elevations Elevations in same units as x (assumed to be metres)
#' @param directed Should the value be directed? `FALSE` by default.
#'   If `TRUE` the result will be negative when it represents a downslope
#'   (when the end point is lower than the start point).
#' @return A vector of slope gradients associated with each linear element
#'   (each line between consecutive vertices) associated with linear features.
#'   Returned values for `slope_distance_mean()` and
#'   `slope_distance_mean_weighted()` are summary statistics for all
#'   linear elements in the linestring.
#'   The output value is a proportion representing the change in elevation
#'   for a given change in horizontal movement along the linestring.
#'   0.02, for example, represents a low gradient of 2% while 0.08 represents
#'   a steep gradient of 8%.
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' elevations = c(1, 2, 2, 4, 3, 0) / 10 # downward slope overall
#' slope_vector(x, elevations)
#' library(sf)
#' m = st_coordinates(lisbon_road_segment)
#' d = sequential_dist(m, lonlat = FALSE)
#' elevations = elevation_extract(m, dem_lisbon_raster)
#' slope_distance(d, elevations)
#' slope_distance_mean(d, elevations)
#' slope_distance_mean(d, elevations, directed = TRUE)
#' slope_distance_mean(rev(d), rev(elevations), directed = TRUE)
#' slope_distance_weighted(d, elevations)
#' slope_distance_weighted(d, elevations, directed = TRUE)
slope_vector = function(x, elevations) {
  d = diff(x)
  e_change = diff(elevations)
  e_change / d
}
#' @rdname slope_vector
#' @export
slope_distance = function(d, elevations) {
  e_change = diff(elevations)
  e_change / d
}
#' @rdname slope_vector
#' @export
slope_distance_mean = function(d, elevations, directed = FALSE) {
  e_change = diff(elevations)
  if(directed) {
    mean(abs(e_change) / d) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    mean(abs(e_change) / d)
  }
}
#' @rdname slope_vector
#' @export
slope_distance_weighted = function(d, elevations, directed = FALSE) {
  e_change = diff(elevations)
  if(directed) {
    stats::weighted.mean(abs(e_change) / d, d) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    stats::weighted.mean(abs(e_change) / d, d)
  }
}
#' Calculate the gradient of line segments from a 3D matrix of coordinates
#'
#' @param elevations Elevations in same units as x (assumed to be metres).
#'   Default value: `m[, 3]`, meaning the 'z' coordinate in a matrix of
#'   coordinates.
#' @param m Matrix containing coordinates and elevations.
#'   The matrix should have three columns: x, y, and z, in that order. Typically
#'   these correspond to location in the West-East, South-North, and vertical
#'   elevation axes respectively.
#'   In data with geographic coordinates, Z values are assumed to be in
#'   metres. In data with projected coordinates, Z values are assumed to have
#'   the same units as the X and Y coordinates.
#' @inheritParams slope_vector
#' @inheritParams sequential_dist
#' @return A vector of slope gradients associated with each linear element
#'   (each line between consecutive vertices) associated with linear features.
#'   Returned values for `slope_matrix_mean()` and
#'   `slope_matrix_weighted()` are summary statistics for all
#'   linear elements in the linestring.
#'   The output value is a proportion representing the change in elevation
#'   for a given change in horizontal movement along the linestring.
#'   0.02, for example, represents a low gradient of 2% while 0.08 represents
#'   a steep gradient of 8%.
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' y = c(0, 0, 0, 0, 0, 9)
#' z = c(1, 2, 2, 4, 3, 0) / 10
#' m = cbind(x, y, z)
#' slope_matrix_weighted(m, lonlat = FALSE)
#' slope_matrix_weighted(m, lonlat = FALSE, directed = TRUE)
#' # 0 value returned if no change in elevation:
#' slope_matrix_weighted(m,lonlat = FALSE, directed = TRUE,
#'   elevations = c(1, 2, 2, 4, 3, 1))
#' slope_matrix_mean(m, lonlat = FALSE)
#' slope_matrix_mean(m, lonlat = FALSE, directed = TRUE)
#' plot(x, z, ylim = c(-0.5, 0.5), type = "l")
#' (gx = slope_vector(x, z))
#' (gxy = slope_matrix(m, lonlat = FALSE))
#' abline(h = 0, lty = 2)
#' points(x[-length(x)], gx, col = "red")
#' points(x[-length(x)], gxy, col = "blue")
#' title("Distance (in x coordinates) elevation profile",
#'   sub = "Points show calculated gradients of subsequent lines")
slope_matrix = function(m, elevations = m[, 3], lonlat = TRUE) {
  d = sequential_dist(m, lonlat = lonlat)
  e_change = diff(elevations)
  g = e_change / d
  g
}
#' @rdname slope_matrix
#' @export
slope_matrix_mean = function(m, elevations = m[, 3], lonlat = TRUE, directed = FALSE) {
  g1 = slope_matrix(m, elevations = elevations, lonlat = lonlat)
  d = sequential_dist(m = m, lonlat = lonlat)
  if(directed) {
    mean(abs(g1), na.rm = TRUE) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    mean(abs(g1), na.rm = TRUE)
  }
}
#' @rdname slope_matrix
#' @export
slope_matrix_weighted = function(m, elevations = m[, 3], lonlat = TRUE, directed = FALSE) {
  g1 = slope_matrix(m, elevations = elevations, lonlat = lonlat)
  d = sequential_dist(m = m, lonlat = lonlat)
  if(directed) {
    stats::weighted.mean(abs(g1), d, na.rm = TRUE) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    stats::weighted.mean(abs(g1), d, na.rm = TRUE)
  }
}

#' Calculate the sequential distances between sequential coordinate pairs
#'
#' Set `lonlat` to `FALSE` if you have projected data, e.g. with coordinates
#' representing distance in meters, not degrees. Lonlat coodinates are assumed
#' (`lonlat = TRUE` is the default).
#'
#' @param lonlat Are the coordinates in lon/lat (geographic) coordinates? TRUE by default.
#' @inheritParams slope_matrix
#' @return A vector of distance values in meters if `lonlat = TRUE`
#'   or the map units of the input data if `lonlat = FALSE` between
#'   consecutive vertices.
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' y = c(0, 0, 0, 0, 0, 1)
#' m = cbind(x, y)
#' d = sequential_dist(m, lonlat = FALSE)
#' d
#' nrow(m)
#' length(d)
sequential_dist = function(m, lonlat = TRUE) {
  if(lonlat) {
    geodist::geodist(m[, 1:2], sequential = TRUE) # lon lat
  } else {
    sqrt(diff(m[, 1])^2 + diff(m[, 2])^2)
  }
}

slope_matrices = function(m_xyz_split, fun = slope_matrix_weighted, ...) {
  slope_list = pbapply::pblapply(m_xyz_split, fun, ...)
  unlist(slope_list)
}
#' Calculate the gradient of line segments from a raster dataset
#'
#' This function takes an `sf` representing routes over geographical space
#' and a raster dataset representing the terrain as inputs.
#' It returns the average gradient of each route feature.
#'
#' If calculating slopes associated with OSM data, the results may be better
#' if the network is first split-up, e.g. using the function
#' `stplanr::rnet_breakup_vertices()` from the
#' [`stplanr`](https://docs.ropensci.org/stplanr/reference/) package.
#' **Note:** The `routes` object must have a geometry type of `LINESTRING`.
#' The `sf::st_cast()` function can convert from `MULTILINESTRING` (and other)
#' geometries to `LINESTRING`s as follows:
#' `r_linestring = sf::st_cast(routes, "LINESTRING")`.
#'
#' @param terra Should the `terra` package be used?
#'   `TRUE` by default if the package is installed *and*
#'   if `dem` is of class `SpatRast`
#' @param lonlat Are the routes provided in longitude/latitude coordinates?
#'   By default, value is from the CRS of the routes (`sf::st_is_longlat(routes)`).
#' @param routes Routes, the gradients of which are to be calculated.
#'   The object must be of class `sf` or `sfc` with `LINESTRING` geometries.
#' @param dem Raster overlapping with `routes` and values representing elevations
#' @param method The method of estimating elevation at points,
#'   passed to the `extract` function for extracting values from raster
#'   datasets. Default: `"bilinear"`.
#' @param fun The slope function to calculate per route,
#'   `slope_matrix_weighted` by default.
#' @inheritParams slope_vector
#' @importFrom methods is
#' @return A vector of slopes equal in length to the number simple features
#'   (rows representing linestrings) in the input object.
#' @export
#' @examples
#' library(sf)
#' routes = lisbon_road_network[1:3, ]
#' dem = dem_lisbon_raster
#' (s = slope_raster(routes, dem))
#' cor(routes$Avg_Slope, s)
#' slope_raster(routes, dem, directed = TRUE)
#' # Demonstrate that reverse routes have the opposite directed slope
#' slope_raster(st_reverse(routes), dem, directed = TRUE)
slope_raster = function(
  routes,
  dem,
  lonlat = sf::st_is_longlat(routes),
  method = "bilinear",
  fun = slope_matrix_weighted,
  terra = has_terra() && methods::is(dem, "SpatRaster"),
  directed = FALSE
  ) {
  if(is.na(lonlat)) {
    stop(
      "CRS of routes not known. Set the CRS, e.g. as follows:\n",
      "sf::st_crs(routes) = 4326 # if the routes are in lon/lat coordinates"
      )
  }
  stop_is_not_linestring(routes)
  routes = sf::st_geometry(routes)
  # todo: split out this bit into slope_xyz function
  m = sf::st_coordinates(routes)
  # colnames(m)
  z = elevation_extract(m, dem, method = method, terra = terra)
  m_xyz_df = data.frame(x = m[, "X"], y = m[, "Y"], z = z, L1 = m[, "L1"])
  res = slope_xyz(m_xyz_df, fun = fun, lonlat = lonlat, directed = directed)
  res
}

#' Extract slopes from xyz data frame or sf objects
#'
#' The function takes a sf object with 'XYZ' coordinates and returns a vector
#' of numeric values representing the average slope of each linestring in the
#' sf data frame input.
#'
#' The default function to calculate the mean slope is `slope_matrix_weighted()`.
#' You can also use `slope_matrix_mean()` from the package or any other
#' function that takes the same inputs as these functions not in the package.
#'
#' @param route_xyz An `sf` or `sfc` object with `XYZ` coordinate dimensions
#' @param lonlat Are the coordinates in lon/lat order? TRUE by default
#' @inheritParams slope_raster
#' @return A vector of slopes equal in length to the number simple features
#'   (rows representing linestrings) in the input object.
#' @export
#' @examples
#' route_xyz = lisbon_road_segment_3d
#' slope_xyz(route_xyz, lonlat = FALSE)
#' slope_xyz(route_xyz$geom, lonlat = FALSE)
#' slope_xyz(route_xyz, lonlat = FALSE, directed = TRUE)
#' slope_xyz(route_xyz, lonlat = FALSE, fun = slope_matrix_mean)
slope_xyz = function(
  route_xyz,
  fun = slope_matrix_weighted,
  lonlat = TRUE,
  directed = FALSE
  ) {
  if(inherits(route_xyz, "sf") | inherits(route_xyz, "sfc")) {
    lonlat = sf::st_is_longlat(route_xyz)
    route_xyz = as.data.frame(sf::st_coordinates(route_xyz))
  }
  if("L1" %in% colnames(route_xyz)) {
    m_xyz_split = split(x = route_xyz, f = route_xyz[, "L1"])
    res = slope_matrices(
      m_xyz_split,
      lonlat = lonlat,
      fun = fun,
      directed = directed
      )
  } else {
    # todo: add content here if data frame was generated by sfheaders
    # or another package that does not call id colums 'L1' by default
    # (low priority)
  }
  res
}

#' Extract elevations from coordinates
#'
#' This function takes a series of points located in geographical space
#' and a digital elevation model as inputs and returns a vector of
#' elevation estimates associated with each point.
#' The function takes locations
#' represented as a matrix of XY (or longitude latitude) coordinates
#' and a digital elevation model (DEM) with class `raster` or `terra`.
#' It returns a vector of values representing estimates of elevation
#' associated with each of the points.
#'
#' By default, the elevations are estimated using
#' [bilinear interpolation](https://en.wikipedia.org/wiki/Bilinear_interpolation)
#' (`method = "bilinear"`)
#' which calculates point height based on proximity to the centroids of
#' surrounding cells.
#' The value of the `method` argument is passed to the `method` argument in
#' [`raster::extract()`](https://rspatial.github.io/raster/reference/extract.html)
#' or
#' [`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html)
#' depending on the class of the input raster dataset.
#'
#' See Kidner et al. (1999)
#' for descriptions of alternative elevation interpolation and extrapolation
#' algorithms.
#'
#' @references
#' Kidner, David, Mark Dorey, and Derek Smith.
#'   "What’s the point? Interpolation and extrapolation with a regular grid DEM."
#'   Fourth International Conference on GeoComputation, Fredericksburg,
#'   VA, USA. 1999.
#'
#' @param m Matrix containing coordinates and elevations or an sf
#'   object representing a linear feature.
#' @inheritParams slope_raster
#' @inheritParams slope_matrix
#' @return A vector of elevation values.
#' @export
#' @examples
#' dem = dem_lisbon_raster
#' elevation_extract(lisbon_road_network[1, ], dem)
#' m = sf::st_coordinates(lisbon_road_network[1, ])
#' elevation_extract(m, dem)
#' elevation_extract(m, dem, method = "simple")
#' # Test with terra (requires internet connection):
#' \donttest{
#' if(slopes:::has_terra()) {
#' et = terra::rast(dem_lisbon_raster)
#' elevation_extract(m, et)
#' }
#' }
elevation_extract = function(
  m,
  dem,
  method = "bilinear",
  terra = has_terra() && methods::is(dem, "SpatRaster")
  ) {
  if(any(grepl(pattern = "sf", class(m)))) {
    m = sf::st_coordinates(m)
  }
  if(terra) {
    res = terra::extract(dem, m[, 1:2], method = method)[[1]]
  } else {
    res = raster::extract(dem, m[, 1:2], method = method)
  }
  # unlist(res)
  res
}

#' Take a linestring and add a third (z) dimension to its coordinates
#' @inheritParams slope_raster
#' @inheritParams elevation_extract
#' @return An sf object that is identical to the input `routes`, except that
#'   the coordinate values in the ouput has a third `z` dimension representing
#'   the elevation of each vertex that defines a linear feature such as a road.
#' @export
#' @examples
#' library(sf)
#' routes = lisbon_road_network[204, ]
#' dem = dem_lisbon_raster
#' (r3d = elevation_add(routes, dem))
#' library(sf)
#' st_z_range(routes)
#' st_z_range(r3d)
#' plot(st_coordinates(r3d)[, 3])
#' plot_slope(r3d)
#' \donttest{
#' # Get elevation data (requires internet connection and API key):
#' r3d_get = elevation_add(cyclestreets_route)
#' plot_slope(r3d_get)
#' }
elevation_add = function(
  routes,
  dem = NULL,
  method = "bilinear",
  terra = has_terra() && methods::is(dem, "SpatRaster")
  ) {
  stopifnotsf(routes)
  if(is.null(dem)) {
    dem = elevation_get(routes)
    r_original = routes # create copy to deal with projection issues
    routes = sf::st_transform(routes, raster::crs(dem))
    suppressWarnings({sf::st_crs(routes) = sf::st_crs(r_original)})
    m = sf::st_coordinates(routes)
    mo = sf::st_coordinates(r_original)
    z = as.numeric(elevation_extract(m, dem, method = method, terra = terra))
    m_xyz = cbind(mo[, 1:2], z)
  } else {
    m = sf::st_coordinates(routes)
    z = as.numeric(elevation_extract(m, dem, method = method, terra = terra))
    m_xyz = cbind(m[, 1:2], z)
  }
  n = nrow(routes)
  linestrings = lapply(seq(n), function(i){
    sf::st_linestring(m_xyz[m[, 3] == i, ])
  })
  rgeom3d_sfc = sf::st_sfc(linestrings, crs = sf::st_crs(routes))
  sf::st_geometry(routes) = rgeom3d_sfc
  routes
}

# unexported function to check if the user has terra package installed
has_terra = function() {
  res = requireNamespace("terra", quietly = TRUE)
  # print(res)
  res
}

is_linestring = function(x) {
  unique(sf::st_geometry_type(x)) == "LINESTRING"
}
stop_is_not_linestring = function(x) {
  if(isFALSE(is_linestring(x)))
  stop(
    "Only works with LINESTRINGs. Try converting with sf::st_cast() first."
  )
}

stopifnotsf = function(x, arg_name = "routes") {
  if(!is(x, "sf")) {
    stop(arg_name, " is not an sf object. Try again with an sf object.")
  }
}
