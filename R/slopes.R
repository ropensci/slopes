#' Calculate the gradient of line segments from distance and elevation vectors
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
slope_distance_weighted = function(d, e) {
  e_change = diff(e)
  stats::weighted.mean(e_change / d, d)
}
#' @rdname slope_vector
#' @export
slope_distance_mean = function(d, e) {
  e_change = diff(e)
  mean(e_change / d)
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

# convert matrices to gradients
m2g_i = function(i, m_xyz, lonlat, fun = slope_matrix_weighted) {
  sel = m_xyz[, "L1"] == i
  fun(m_xyz[sel, 1:2], m_xyz[sel, "z"], lonlat = lonlat)
}

#' Calculate the gradient of line segments from a raster dataset
#' @inheritParams sequential_dist
#' @inheritParams elevation_extract
#' @param r Routes, the gradients of which are to be calculated
#' @param e A raster object overlapping with `r` and values representing elevations
#' @param method The method of estimating elevation at points, passed to the `extract`
#' function for extracting values from raster datasets. Default: `"bilinear"`.
#' @param fun The slope function to calculate per route,
#'   `slope_matrix_weighted` by default.
#' @export
#' @examples
#' # r = lisbon_road_segments[239, ]
#' r = lisbon_road_segments
#' e = dem_lisbon_raster
#' (s = slope_raster(r, e))[1:5]
#' cor(r$Avg_Slope, s)
slope_raster = function(r, e = NULL, lonlat = sf::st_is_longlat(r), method = "bilinear",
                        fun = slope_matrix_weighted, terra = has_terra()) {
  # if(sum(c("geom", "geometry") %in% names(r)) > 0) {
  #   r = r$geom
  # } else if(methods::is(object = r[[attr(r, "sf_column")]], class2 = "sfc")) {
    r = sf::st_geometry(r)
  # }
  n = length(r)
  m = sf::st_coordinates(r)
  # colnames(m)
  z = elevation_extract(m, e, method = method, terra = terra)
  m_xyz = cbind(m, z)
  cl = colnames(m_xyz)
  if("L1" %in% cl) {
    # todo: use split() instead
    res_list = if (requireNamespace("pbapply", quietly = TRUE)) {
      pbapply::pblapply(1:n, m2g_i, m_xyz, lonlat, fun)
    } else {
      lapply(1:n, m2g_i, m_xyz, lonlat, fun)
    }
  } else {
    # todo: add content here
  }

  unlist(res_list)
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
elevation_extract = function(m,
                             e,
                             method = "bilinear",
                             terra = has_terra() && methods::is(e, "SpatRaster")
                             ) {
  if(terra) {
    res = as.numeric(terra::extract(e, m[, 1:2], method = method))
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
#' r = lisbon_road_segments[204, ]
#' e = dem_lisbon_raster
#' (r3d = slope_3d(r, e))
#' sf::st_z_range(r)
#' sf::st_z_range(r3d)
#' plot(sf::st_coordinates(r3d)[, 3])
#' # (r3d = slope_3d(r, et))
#' # takes bandwidth and time and (currently) fails with:
#' #   GDAL Error 1: No PROJ.4 translation for source SRS
#' # https://github.com/ITSLeeds/slopes/runs/648128378#step:18:107
#' # r3d_get = slope_3d(cyclestreets_route)
#' # plot_slope(r3d_get)
slope_3d = function(r, e = NULL, method = "bilinear", terra = has_terra()) {
  # if("geom" %in% names(r)) {
  #   rgeom = r$geom
  # } else if("geometry" %in% names(r)) {
  #   rgeom = r$geometry
  # } else {
  #   rgeom = sf::st_geometry(r)
  # }
  if(is.null(e)) {
    e = elevations_get(r)
    r_original = r # create copy to deal with projection issues
    r = sf::st_transform(r, raster::crs(e))
    suppressWarnings({sf::st_crs(r) = sf::st_crs(r_original)})
    # plot(e)
    # plot(r$geometry, add = TRUE)
    m = sf::st_coordinates(r)
    mo = sf::st_coordinates(r_original)
    z = as.numeric(elevation_extract(m, e, method = method, terra = terra))
    m_xyz = cbind(mo[, 1:2], z)
  } else {
    m = sf::st_coordinates(r)
    z = as.numeric(elevation_extract(m, e, method = method, terra = terra))
    m_xyz = cbind(m[, 1:2], z)
  }
  n = nrow(r)

  if(n == 1) {
    # currently only works for 1 line, to be generalised

    rgeom3d_line = sf::st_linestring(m_xyz)
    rgeom3d_sfc = sf::st_sfc(rgeom3d_line, crs = sf::st_crs(r))
    # message("Original geometry: ", ncol(rgeom[[1]]))
    sf::st_geometry(r) = rgeom3d_sfc
    # message("New geometry: ", ncol(r$geom[[1]]))
  } else {
    linestrings = lapply(seq(n), function(i){
      rgeom3d_line = sf::st_linestring(m_xyz[m[, 3] == i, ])
    })
    rgeom3d_sfc = sf::st_sfc(linestrings, crs = sf::st_crs(r))
    sf::st_geometry(r) = rgeom3d_sfc
  }
  r
}
# terra = has_terra()
# terra
has_terra = function() {
  res = requireNamespace("terra", quietly = TRUE)
  print(res)
  res
}
