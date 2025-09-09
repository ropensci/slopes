#' Calculate the gradient of line segments from distance and elevation vectors
#'
#' @description
#' `slope_vector()` calculates slopes from consecutive elements in distance and elevation vectors.
#' `slope_distance()` calculates slopes from consecutive distances and elevations.
#' `slope_distance_mean()` calculates mean slopes from consecutive distances and elevations.
#' `slope_distance_weighted()` calculates weighted slopes based on distance between elevation measurements.
#'
#' @param x Vector of locations
#' @param d Vector of distances between points
#' @param elevations Elevations in same units as x (default third column of m for matrix input)
#' @param directed Should the value be directed? FALSE by default. TRUE will make downslope negative
#' @return Vector of slope gradients for each linear element. For mean/weighted mean functions, returns a single summary value.
#' @export
#' @examples
#' x <- c(0, 2, 3, 4, 5, 9)
#' elevations <- c(1, 2, 2, 4, 3, 0) / 10
#' slope_vector(x, elevations)
slope_vector <- function(x, elevations) {
  d <- diff(x)
  e_change <- diff(elevations)
  e_change / d
}

#' @rdname slope_vector
#' @export
slope_distance <- function(d, elevations) {
  e_change <- diff(elevations)
  e_change / d
}

#' @rdname slope_vector
#' @export
slope_distance_mean <- function(d, elevations, directed = FALSE) {
  e_change <- diff(elevations)
  if (directed) {
    mean(abs(e_change) / d, na.rm = TRUE) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    mean(abs(e_change) / d, na.rm = TRUE)
  }
}

#' @rdname slope_vector
#' @export
slope_distance_weighted <- function(d, elevations, directed = FALSE) {
  e_change <- diff(elevations)
  if (directed) {
    stats::weighted.mean(abs(e_change) / d, d, na.rm = TRUE) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    stats::weighted.mean(abs(e_change) / d, d, na.rm = TRUE)
  }
}

#' Calculate the gradient of line segments from a 3D matrix of coordinates
#' @param m Matrix with columns x, y, z
#' @param elevations Optional vector of elevations (default: third column of m)
#' @param lonlat Are coordinates longitude/latitude? TRUE by default
#' @param directed Should slope be directed? FALSE by default
#' @return Vector of slope gradients for each linear element
#' @export
#' @examples
#' x <- c(0, 2, 3, 4, 5, 9)
#' y <- c(0, 0, 0, 0, 0, 9)
#' z <- c(1, 2, 2, 4, 3, 0) / 10
#' m <- cbind(x, y, z)
#' slope_matrix_weighted(m, lonlat = FALSE)
slope_matrix <- function(m, elevations = m[, 3], lonlat = TRUE) {
  d <- sequential_dist(m, lonlat = lonlat)
  e_change <- diff(elevations)
  e_change / d
}

#' @rdname slope_matrix
#' @export
slope_matrix_mean <- function(m, elevations = m[, 3], lonlat = TRUE, directed = FALSE) {
  g1 <- slope_matrix(m, elevations = elevations, lonlat = lonlat)
  if (directed) {
    mean(abs(g1), na.rm = TRUE) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    mean(abs(g1), na.rm = TRUE)
  }
}

#' @rdname slope_matrix
#' @export
slope_matrix_weighted <- function(m, elevations = m[, 3], lonlat = TRUE, directed = FALSE) {
  g1 <- slope_matrix(m, elevations = elevations, lonlat = lonlat)
  d <- sequential_dist(m, lonlat = lonlat)
  if (directed) {
    stats::weighted.mean(abs(g1), d, na.rm = TRUE) *
      sign(utils::tail(elevations, 1) - utils::head(elevations, 1))
  } else {
    stats::weighted.mean(abs(g1), d, na.rm = TRUE)
  }
}

#' Calculate sequential distances between coordinate pairs
#' @param m Matrix of coordinates
#' @param lonlat Are coordinates lon/lat? TRUE by default
#' @return Vector of distances
#' @export
sequential_dist <- function(m, lonlat = TRUE) {
  if (lonlat) {
    geodist::geodist(m[, 1:2], sequential = TRUE)
  } else {
    sqrt(diff(m[, 1])^2 + diff(m[, 2])^2)
  }
}

#' Apply slope function over multiple matrices
#' @param m_xyz_split List of matrices/data.frames with xyz coordinates
#' @param fun Slope function to apply (default: slope_matrix_weighted)
#' @param ... Additional arguments to fun
#' @export
slope_matrices <- function(m_xyz_split, fun = slope_matrix_weighted, ...) {
  slope_list <- pbapply::pblapply(m_xyz_split, fun, ...)
  unlist(slope_list)
}

#' Calculate slopes from raster and sf routes
#' @param routes sf object with LINESTRING geometries
#' @param dem RasterLayer or SpatRaster
#' @param lonlat logical; are coordinates longitude/latitude? Default: sf::st_is_longlat(routes)
#' @param method character; method for extracting raster values (default "bilinear")
#' @param fun slope function to apply (default: slope_matrix_weighted)
#' @param terra logical; use terra if TRUE
#' @param directed logical; if TRUE, downslope is negative
#' @export
slope_raster <- function(routes, dem, lonlat = sf::st_is_longlat(routes),
                         method = "bilinear", fun = slope_matrix_weighted,
                         terra = has_terra() && methods::is(dem, "SpatRaster"),
                         directed = FALSE) {
  if (is.na(lonlat)) stop("CRS of routes not known. Set CRS with sf::st_crs(routes) = 4326")
  stop_is_not_linestring(routes)
  routes <- sf::st_geometry(routes)
  m <- sf::st_coordinates(routes)
  z <- elevation_extract(m, dem, method = method, terra = terra)
  m_xyz_df <- data.frame(x = m[, "X"], y = m[, "Y"], z = z, L1 = m[, "L1"])
  slope_xyz(m_xyz_df, fun = fun, lonlat = lonlat, directed = directed)
}

#' Calculate slopes from xyz data frames or sf objects
#' @param route_xyz data.frame or sf object
#' @param fun slope function (default: slope_matrix_weighted)
#' @param lonlat logical; are coordinates longitude/latitude?
#' @param directed logical; if TRUE, downslope is negative
#' @export
slope_xyz <- function(route_xyz, fun = slope_matrix_weighted, lonlat = TRUE, directed = FALSE) {
  if (inherits(route_xyz, "sf") | inherits(route_xyz, "sfc")) {
    lonlat <- sf::st_is_longlat(route_xyz)
    route_xyz <- as.data.frame(sf::st_coordinates(route_xyz))
  }
  if ("L1" %in% colnames(route_xyz)) {
    m_xyz_split <- split(route_xyz, route_xyz[, "L1"])
    slope_matrices(m_xyz_split, lonlat = lonlat, fun = fun, directed = directed)
  } else {
    warning("No 'L1' column found. Cannot compute slopes.")
    return(NULL)
  }
}

#' Extract elevations from coordinates
#' @param m Coordinates matrix or sf object
#' @param dem RasterLayer or SpatRaster
#' @param method character; extraction method (default "bilinear")
#' @param terra logical; use terra if TRUE
#' @export
elevation_extract <- function(m, dem, method = "bilinear", terra = has_terra() && methods::is(dem, "SpatRaster")) {
  if (any(grepl(pattern = "sf", class(m)))) m <- sf::st_coordinates(m)
  if (terra) {
    terra::extract(dem, m[, 1:2], method = method)[[1]]
  } else {
    raster::extract(dem, m[, 1:2], method = method)
  }
}

#' Add elevations to linestring sf object
#' @param routes sf object with LINESTRING geometries
#' @param dem RasterLayer or SpatRaster
#' @param method character; extraction method (default "bilinear")
#' @param terra logical; use terra if TRUE
#' @export
elevation_add <- function(routes, dem = NULL, method = "bilinear", terra = has_terra() && methods::is(dem, "SpatRaster")) {
  stopifnotsf(routes)
  if (is.null(dem)) {
    dem <- elevation_get(routes)  # Example will be \donttest{} in Rd
    r_original <- routes
    routes <- sf::st_transform(routes, raster::crs(dem))
    suppressWarnings({sf::st_crs(routes) <- sf::st_crs(r_original)})
    m <- sf::st_coordinates(routes)
    mo <- sf::st_coordinates(r_original)
    z <- as.numeric(elevation_extract(m, dem, method = method, terra = terra))
    m_xyz <- cbind(mo[, 1:2], z)
  } else {
    m <- sf::st_coordinates(routes)
    z <- as.numeric(elevation_extract(m, dem, method = method, terra = terra))
    m_xyz <- cbind(m[, 1:2], z)
  }
  n <- nrow(routes)
  linestrings <- lapply(seq(n), function(i) sf::st_linestring(m_xyz[m[, 3] == i, ]))
  rgeom3d_sfc <- sf::st_sfc(linestrings, crs = sf::st_crs(routes))
  sf::st_geometry(routes) <- rgeom3d_sfc
  routes
}

# Utility functions
#' Check if terra package is available
#'
#' Checks whether the terra package is installed and can be loaded.
#'
#' @return Logical value indicating if terra is available
#' @export
has_terra <- function() requireNamespace("terra", quietly = TRUE)
is_linestring <- function(x) unique(sf::st_geometry_type(x)) == "LINESTRING"
stop_is_not_linestring <- function(x) if (!is_linestring(x)) stop("Only works with LINESTRINGs. Convert with sf::st_cast()")
stopifnotsf <- function(x, arg_name = "routes") if (!methods::is(x, "sf")) stop(arg_name, " is not an sf object. Try again with an sf object.")

