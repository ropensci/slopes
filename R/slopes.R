#' Calculate the gradient of line segments from distance and elevation vectors
#'
#' @param x Vector of locations
#' @param e Elevations in same units as x (assumed to be metres)
#' @export
#' @examples
#' x = c(0, 2, 3, 4, 5, 9)
#' e = c(1, 2, 2, 4, 3, 1) / 10
#' slope_vector(x, e)
slope_vector = function(x, e) {
  d = diff(x)
  e_change = diff(e)
  e_change / d
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

# x = sf::st_coordinates(lisbon_road_segments[1, ])
# rg3d(x, elevation = dem_lisbon_raster)
rg3d_single_line = function(x, elevation = NULL) {
  if(methods::is(x, "sf")) {
    m = sf::st_coordinates(x)
  } else {
    m = x
  }
  if(!is.null(elevation)) {
    e = slope_extract_elevation_from_raster(m, elevation)
  } else {
    e = x[, 3]
  }
  g1 = slope_matrix(m, e = e, lonlat = FALSE)
  d = sequential_dist(m = m, lonlat = FALSE)
  stats::weighted.mean(abs(g1), d, na.rm = TRUE)
}

#' Calculate the gradient of line segments from a raster dataset
#'
#' @param r Routes, the gradients of which are to be calculated
#' @param e A raster object overlapping with `r` and values representing elevations
#' @export
#' @examples
#' r = lisbon_road_segments
#' e = dem_lisbon_raster
#' (s = slope_raster(r, e))
#' cor(r$Avg_Slope, s)^2
slope_raster = function(r, e = NULL) {
  # if("geom" %in% names(r)) {
  #   r = r$geom
  # } else if(methods::is(object = r[[attr(r, "sf_column")]], class2 = "sfc")) {
    r = sf::st_geometry(r)
  # }
  n_lines = length(r)
  m = sf::st_coordinates(r)
  vertex_elevations = slope_extract_elevation_from_raster(m, e)
  nrow(m) == length(vertex_elevations)
  res_list =
    if (requireNamespace("pbapply", quietly = TRUE)) {
      pbapply::pblapply(1:n_lines, function(i) {
        sel = m[, "L1"] == i
        slope_matrix_weighted(m[sel, ], vertex_elevations[sel])
      })
    } else {
      lapply(1:n_lines, function(i) {
        sel = m[, "L1"] == i
        slope_matrix_weighted(m[sel, ], vertex_elevations[sel])
      })
    }

  # res_list =
  #   if (requireNamespace("pbapply", quietly = TRUE)) {
  #     pbapply::pblapply(r_geometry, rg3d_single_line, e = e)
  #   } else {
  #     lapply(r_geometry, rg3d_single_line, e = e)
  #   }
  unlist(res_list)
}

# m = sf::st_coordinates(lisbon_road_segments[1, ])
# e = dem_lisbon_raster
# slope_extract_elevation_from_raster(m, e)
slope_extract_elevation_from_raster = function(m, e, method = "bilinear") {
  raster::extract(e, m[, 1:2], method = method)
}
