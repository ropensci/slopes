#' Calculate the gradient of line segments from distance and elevation vectors
#'
#' @description
#'
#' [slope_vector()] calculates the slopes associated with consecutive elements
#'   in one dimensional distance and associated elevations (see examples).
#'
#' [slope_distance()] calculates the slopes associated with consecutive
#'   distances and elevations.
#'
#' [slope_distance_mean()] calculates the mean average slopes associated with
#'   consecutive distances and elevations.
#'
#' [slope_distance_weighted()] calculates the slopes associated with
#'   consecutive distances and elevations,
#'   with the mean value associated with each set of distance/elevation
#'   vectors weighted in proportion to the distance between each elevation
#'   measurement, so longer sections have proportionally more influence
#'   on the resulting gradient estimate (see examples).
#'
#' @param x Vector of locations
#' @param d Vector of distances between points
#' @param e Elevations in same units as x (assumed to be metres)
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' e = c(1, 2, 2, 4, 3, 1) / 10
#' slope_vector(x, e)
#' m = sf::st_coordinates(lisbon_road_segment)
#' d = sequential_dist(m, lonlat = FALSE)
#' e = elevation_extract(m, dem_lisbon_raster)
#' slope_distance(d, e)
#' slope_distance_mean(d, e)
#' slope_distance_weighted(d, e)
slope_vector = function(x, e) {
  d = diff(x)
  e_change = diff(e)
  e_change / d
}
#' @rdname slope_vector
#' @export
slope_distance = function(d, e) {
  e_change = diff(e)
  e_change / d
}
#' @rdname slope_vector
#' @export
slope_distance_mean = function(d, e) {
  e_change = diff(e)
  mean(abs(e_change) / d)
}
#' @rdname slope_vector
#' @export
slope_distance_weighted = function(d, e) {
  e_change = diff(e)
  stats::weighted.mean(abs(e_change) / d, d)
}
#' Calculate the gradient of line segments from a 3D matrix of coordinates
#'
#' @param m Matrix containing coordinates and elevations
#' @inheritParams slope_vector
#' @inheritParams sequential_dist
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' y = c(0, 0, 0, 0, 0, 9)
#' z = c(1, 2, 2, 4, 3, 1) / 10
#' m = cbind(x, y, z)
#' plot(x, z, ylim = c(-0.5, 0.5), type = "l")
#' (gx = slope_vector(x, z))
#' (gxy = slope_matrix(m, lonlat = FALSE))
#' abline(h = 0, lty = 2)
#' points(x[-length(x)], gx, col = "red")
#' points(x[-length(x)], gxy, col = "blue")
#' title("Distance (in x coordinates) elevation profile",
#'   sub = "Points show calculated gradients of subsequent lines")
slope_matrix = function(m, e = m[, 3], lonlat = TRUE) {
  d = sequential_dist(m, lonlat = lonlat)
  e_change = diff(e)
  g = e_change / d
  g
}
#' @rdname slope_matrix
#' @export
slope_matrix_weighted = function(m, e = m[, 3], lonlat = TRUE) {
  g1 = slope_matrix(m, e = e, lonlat = lonlat)
  d = sequential_dist(m = m, lonlat = lonlat)
  stats::weighted.mean(abs(g1), d, na.rm = TRUE)
}

#' Calculate the sequential distances between sequential coordinate pairs
#'
#' @param lonlat Are the coordinates in lon/lat order? `TRUE` by default
#' @inheritParams slope_matrix
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' y = c(0, 0, 0, 0, 0, 1)
#' m = cbind(x, y)
#' sequential_dist(m)
sequential_dist = function(m, lonlat = TRUE) {
  if(lonlat) {
    if(requireNamespace("geodist")) {
      geodist::geodist(m[, 1:2], sequential = TRUE) # lon lat
    } else {
      message("Install geodist")
    }
  } else {
    sqrt(diff(m[, 1])^2 + diff(m[, 2])^2)
  }
}

slope_matrices = function(m_xyz_split, fun = slope_matrix_weighted, ...) {
  if (requireNamespace("pbapply", quietly = TRUE)) {
    slope_list = pbapply::pblapply(m_xyz_split, fun, ...)
  } else {
    slope_list = lapply(m_xyz_split, fun, ...)
  }
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
#' @inheritParams sequential_dist
#' @inheritParams elevation_extract
#' @param routes Routes, the gradients of which are to be calculated.
#'   The object must be of class `sf` with `LINESTRING` geometries.
#' @param e Raster overlapping with `routes` and values representing elevations
#' @param method The method of estimating elevation at points,
#'   passed to the `extract` function for extracting values from raster
#'   datasets. Default: `"bilinear"`.
#' @param fun The slope function to calculate per route,
#'   `slope_matrix_weighted` by default.
#' @importFrom methods is
#' @export
#' @examples
#' routes = lisbon_road_segments[1:3, ]
#' e = dem_lisbon_raster
#' (s = slope_raster(routes, e))
#' cor(routes$Avg_Slope, s)
slope_raster = function(
 routes,
  e = NULL,
  lonlat = sf::st_is_longlat(routes),
  method = "bilinear",
  fun = slope_matrix_weighted,
  terra = has_terra() && methods::is(e, "SpatRaster")
  ) {
  stop_is_not_linestring(routes)
  routes = sf::st_geometry(routes)
  # todo: split out this bit into slope_xyz function
  m = sf::st_coordinates(routes)
  # colnames(m)
  z = elevation_extract(m, e, method = method, terra = terra)
  m_xyz_df = data.frame(x = m[, "X"], y = m[, "Y"], z = z, L1 = m[, "L1"])
  res = slope_xyz(m_xyz_df, fun = fun, lonlat = lonlat)
  res
}

#' Extract slopes from xyz dataframe or sf objects
#'
#' @param r_xyz An sf object with x, y, z dimensions
#' @inheritParams slope_raster
#'
#' @export
#' @examples
#' r_xyz = lisbon_road_segment_3d
#' slope_xyz(r_xyz)
slope_xyz = function(r_xyz, fun = slope_matrix_weighted, lonlat = NULL) {
  # browser()
  if(inherits(r_xyz, "sf") | inherits(r_xyz, "sfc")) {
    if(is.null(lonlat)) {
      lonlat = sf::st_is_longlat(r_xyz)
    }
    r_xyz = as.data.frame(sf::st_coordinates(r_xyz))
  }
  if(is.null(lonlat)) {
    lonlat = FALSE
  }
  if("L1" %in% colnames(r_xyz)) {
    m_xyz_split = split(x = r_xyz, f = r_xyz[, "L1"])
    res = slope_matrices(m_xyz_split, lonlat = lonlat, fun = fun)
  } else {
    # todo: add content here
  }
  res
}

#' Extract elevations from coordinates
#'
#' @param terra Should the `terra` package be used?
#' `TRUE` by default if the package is installed *and*
#' if `e` is of class `SpatRast`
#' @inheritParams slope_raster
#' @inheritParams slope_matrix
#' @export
#' @examples
#' m = sf::st_coordinates(lisbon_road_segments[1, ])
#' e = dem_lisbon_raster
#' elevation_extract(m, e)
#' elevation_extract(m, e, method = "simple")
#' # uncomment the following lines to test with terra (experimental)
#' # u = paste0("https://github.com/ITSLeeds/slopes/",
#' #    "releases/download/0.0.0/dem_lisbon.tif" )
#' # if(!file.exists("dem_lisbon.tif")) download.file(u, "dem_lisbon.tif")
#' # et = terra::rast("dem_lisbon.tif")
#' # elevation_extract(m, et)
elevation_extract = function(m,
                             e,
                             method = "bilinear",
                             terra = has_terra() && methods::is(e, "SpatRaster")
                             ) {
  if(terra) {
    res = terra::extract(e, m[, 1:2], method = method)[[1]]
  } else {
    res = raster::extract(e, m[, 1:2], method = method)
  }
  # unlist(res)
  res
}

#' Take a linestring and add a third (z) dimension to its coordinates
#' @inheritParams slope_raster
#' @inheritParams elevation_extract
#' @export
#' @examples
#' routes = lisbon_road_segments[204, ]
#' e = dem_lisbon_raster
#' (r3d = slope_3d(routes, e))
#' sf::st_z_range(routes)
#' sf::st_z_range(r3d)
#' plot(sf::st_coordinates(r3d)[, 3])
#' plot_slope(r3d)
#' # r3d_get = slope_3d(cyclestreets_route)
#' # plot_slope(r3d_get)
slope_3d = function(
 routes,
  e = NULL,
  method = "bilinear",
  terra = has_terra() && methods::is(e, "SpatRaster")
  ) {
  if(is.null(e)) {
    e = elevations_get(routes)
    r_original = routes # create copy to deal with projection issues
    routes = sf::st_transform(routes, raster::crs(e))
    suppressWarnings({sf::st_crs(routes) = sf::st_crs(r_original)})
    m = sf::st_coordinates(routes)
    mo = sf::st_coordinates(r_original)
    z = as.numeric(elevation_extract(m, e, method = method, terra = terra))
    m_xyz = cbind(mo[, 1:2], z)
  } else {
    m = sf::st_coordinates(routes)
    z = as.numeric(elevation_extract(m, e, method = method, terra = terra))
    m_xyz = cbind(m[, 1:2], z)
  }
  n = nrow(routes)

  if(n == 1) {
    rgeom3d_line = sf::st_linestring(m_xyz)
    rgeom3d_sfc = sf::st_sfc(rgeom3d_line, crs = sf::st_crs(routes))
    sf::st_geometry(routes) = rgeom3d_sfc
  } else {
    linestrings = lapply(seq(n), function(i){
      rgeom3d_line = sf::st_linestring(m_xyz[m[, 3] == i, ])
    })
    rgeom3d_sfc = sf::st_sfc(linestrings, crs = sf::st_crs(routes))
    sf::st_geometry(routes) = rgeom3d_sfc
  }
  r
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
# # test:
# x = sf::st_cast(lisbon_road_segment, "MULTILINESTRING")
# is_linestring(lisbon_road_segment)
# is_linestring(x)
# stop_is_not_linestring(x)
# stop_is_not_linestring(lisbon_road_segment)
