#' Calculate slopes from vector data
#'
#' Calculates slope gradients using vector distance and elevation data.
#'
#' @param x Vector of distance values
#' @param elevations Vector of elevation values
#' @return Numeric vector of slope values
#' @export
slope_vector <- function(x, elevations) {
  d <- diff(x)
  e_change <- diff(elevations)
  e_change / d
}

#' Calculate slopes using distance data
#'
#' Calculates slope gradients from distance and elevation vectors.
#'
#' @param d Vector of distance values between points
#' @param elevations Vector of elevation values
#' @return Numeric vector of slope values
#' @export
slope_distance <- function(d, elevations) {
  e_change <- diff(elevations)
  e_change / d
}

#' Calculate mean slope using distance weighting
#'
#' Computes the mean slope across segments using distance-weighted averaging.
#'
#' @param d Vector of distance values between points
#' @param elevations Vector of elevation values
#' @param directed Logical, whether to calculate directed slopes (default: FALSE)
#' @return Numeric value representing the mean slope
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

#' Calculate distance-weighted slopes
#'
#' Applies distance-based weighting to slope calculations for more accurate results.
#'
#' @param d Vector of distance values between points
#' @param elevations Vector of elevation values
#' @param directed Logical, whether to calculate directed slopes (default: FALSE)
#' @return Numeric value representing the weighted slope
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

#' Calculate slopes from coordinate matrix
#'
#' Calculates slope gradients from a matrix of coordinates and elevation data.
#'
#' @param m Matrix of coordinates (x, y, z)
#' @param elevations Vector of elevation values (default: third column of m)
#' @param lonlat Logical, whether coordinates are longitude/latitude (default: TRUE)
#' @return Numeric vector of slope values
#' @export
slope_matrix <- function(m, elevations = m[, 3], lonlat = TRUE) {
  d <- sequential_dist(m, lonlat = lonlat)
  e_change <- diff(elevations)
  e_change / d
}

#' Calculate mean slope from coordinate matrix
#'
#' Computes the mean slope from a matrix of coordinates with elevation data.
#'
#' @param m Matrix of coordinates (x, y, z)
#' @param elevations Vector of elevation values (default: third column of m)
#' @param lonlat Logical, whether coordinates are longitude/latitude (default: TRUE)
#' @param directed Logical, whether to calculate directed slopes (default: FALSE)
#' @return Numeric value representing the mean slope
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

#' Calculate weighted slopes from coordinate matrix
#'
#' Applies distance-based weighting to slope calculations from coordinate matrix.
#'
#' @param m Matrix of coordinates (x, y, z)
#' @param elevations Vector of elevation values (default: third column of m)
#' @param lonlat Logical, whether coordinates are longitude/latitude (default: TRUE)
#' @param directed Logical, whether to calculate directed slopes (default: FALSE)
#' @return Numeric value representing the weighted slope
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

#' Calculate sequential distances between points
#'
#' Calculates distances between consecutive points in a coordinate matrix.
#'
#' @param m Matrix of coordinates (x, y)
#' @param lonlat Logical, whether coordinates are longitude/latitude (default: TRUE)
#' @return Numeric vector of distances between consecutive points
#' @export
sequential_dist <- function(m, lonlat = TRUE) {
  if (lonlat) {
    geodist::geodist(m[, 1:2], sequential = TRUE)
  } else {
    sqrt(diff(m[, 1])^2 + diff(m[, 2])^2)
  }
}

#' Calculate slopes for multiple coordinate matrices
#'
#' Applies slope calculation function to a list of coordinate matrices.
#'
#' @param m_xyz_split List of coordinate matrices with elevation data
#' @param fun Function to apply for slope calculation (default: slope_matrix_weighted)
#' @param ... Additional arguments passed to the slope function
#' @return Numeric vector of slope values for all matrices
#' @export
slope_matrices <- function(m_xyz_split, fun = slope_matrix_weighted, ...) {
  slope_list <- pbapply::pblapply(m_xyz_split, fun, ...)
  unlist(slope_list)
}

#' Calculate slopes using raster elevation data
#'
#' Calculates slope gradients for routes using digital elevation model (DEM) raster data.
#'
#' @param routes An sf object containing linestring geometries
#' @param dem A SpatRaster object (terra package) containing elevation data
#' @param lonlat Logical, whether coordinates are longitude/latitude (default: auto-detected)
#' @param method Method for raster extraction (default: "bilinear")
#' @param fun Function for slope calculation (default: slope_matrix_weighted)
#' @param terra Deprecated. Ignored; terra is always used.
#' @param directed Logical, whether to calculate directed slopes (default: FALSE)
#' @return Numeric vector of slope values
#' @export
slope_raster <- function(routes, dem, lonlat = sf::st_is_longlat(routes),
                         method = "bilinear", fun = slope_matrix_weighted,
                         terra = NULL,
                         directed = FALSE) {
  if (!is.null(terra)) {
    .Deprecated(msg = "The 'terra' argument is deprecated and ignored. terra is always used.")
  }
  if (is.na(lonlat)) stop("CRS of routes not known. Set CRS with sf::st_crs(routes) = 4326")
  stop_is_not_linestring(routes)
  routes <- sf::st_geometry(routes)
  m <- sf::st_coordinates(routes)
  z <- elevation_extract(m, dem, method = method)
  m_xyz_df <- data.frame(x = m[, "X"], y = m[, "Y"], z = z, L1 = m[, "L1"])
  slope_xyz(m_xyz_df, fun = fun, lonlat = lonlat, directed = directed)
}

#' Calculate slopes from XYZ coordinate data
#'
#' Calculates slope gradients from linestring geometries with XYZ coordinates.
#'
#' @param route_xyz An sf object or data frame with XYZ coordinates
#' @param fun Function for slope calculation (default: slope_matrix_weighted)
#' @param lonlat Logical, whether coordinates are longitude/latitude (default: TRUE)
#' @param directed Logical, whether to calculate directed slopes (default: FALSE)
#' @return Numeric vector of slope values
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

#' Extract elevation values from coordinates
#'
#' Extracts elevation values from a DEM raster at specified coordinate locations.
#' Accepts both `SpatRaster` (terra) and legacy `Raster*` (raster) objects;
#' legacy objects are automatically converted to `SpatRaster`.
#'
#' @param m Matrix or sf object with coordinates
#' @param dem A SpatRaster (or legacy RasterLayer) containing elevation data
#' @param method Method for raster extraction (default: "bilinear")
#' @param terra Deprecated. Ignored; terra is always used.
#' @return Numeric vector of elevation values
#' @export
elevation_extract <- function(m, dem, method = "bilinear", terra = NULL) {
  if (!is.null(terra)) {
    .Deprecated(msg = "The 'terra' argument is deprecated and ignored. terra is always used.")
  }
  if (any(grepl(pattern = "sf", class(m)))) m <- sf::st_coordinates(m)
  if (!methods::is(dem, "SpatRaster")) {
    if (requireNamespace("terra", quietly = TRUE)) {
      message("Converting legacy Raster* object to SpatRaster. Consider using terra::rast() directly.")
      dem <- terra::rast(dem)
    } else {
      stop("terra package is required. Install it with: install.packages('terra')")
    }
  }
  terra::extract(dem, m[, 1:2], method = method)[[1]]
}

#' Add elevation data to route linestrings
#'
#' Adds elevation (Z) coordinates to linestring geometries using DEM data.
#'
#' @param routes An sf object containing linestring geometries
#' @param dem A SpatRaster object containing elevation data (default: NULL for automatic download)
#' @param method Method for raster extraction (default: "bilinear")
#' @param terra Deprecated. Ignored; terra is always used.
#' @return An sf object with XYZ linestring geometries
#' @export
#' @examples
#' library(sf)
#' routes = lisbon_road_network[204, ]
#' dem = dem_lisbon()
#' (r3d = elevation_add(routes, dem))
#' st_z_range(routes)
#' st_z_range(r3d)
#' plot(st_coordinates(r3d)[, 3])
#' plot_slope(r3d)
#' \dontrun{
#' # Get elevation data (requires internet connection, ceramic pkg, and API key):
#' if (requireNamespace("ceramic", quietly = TRUE)) {
#'   r3d_get = elevation_add(cyclestreets_route)
#'   plot_slope(r3d_get)
#' }
#' }
elevation_add <- function(routes, dem = NULL, method = "bilinear", terra = NULL) {
  if (!is.null(terra)) {
    .Deprecated(msg = "The 'terra' argument is deprecated and ignored. terra is always used.")
  }
  stopifnotsf(routes)
  if (is.null(dem)) {
    dem <- elevation_get(routes)  # returns SpatRaster
    r_original <- routes
    routes <- sf::st_transform(routes, terra::crs(dem))
    suppressWarnings({sf::st_crs(routes) <- sf::st_crs(r_original)})
    m <- sf::st_coordinates(routes)
    mo <- sf::st_coordinates(r_original)
    z <- as.numeric(elevation_extract(m, dem, method = method))
    m_xyz <- cbind(mo[, 1:2], z)
  } else {
    m <- sf::st_coordinates(routes)
    z <- as.numeric(elevation_extract(m, dem, method = method))
    m_xyz <- cbind(m[, 1:2], z)
  }
  n <- nrow(routes)
  linestrings <- lapply(seq(n), function(i) sf::st_linestring(m_xyz[m[, "L1"] == i, ]))
  rgeom3d_sfc <- sf::st_sfc(linestrings, crs = sf::st_crs(routes))
  sf::st_geometry(routes) <- rgeom3d_sfc
  routes
}

# Utility functions
has_terra <- function() requireNamespace("terra", quietly = TRUE)
is_linestring <- function(x) unique(sf::st_geometry_type(x)) == "LINESTRING"
stop_is_not_linestring <- function(x) if (!is_linestring(x)) stop("Only works with LINESTRINGs. Convert with sf::st_cast()")
stopifnotsf <- function(x, arg_name = "routes") if (!methods::is(x, "sf")) stop(arg_name, " is not an sf object. Try again with an sf object.")
