# Elevation get/extract/add and Z helper functions

# ── Z value helpers ─────────────────────────────────────────────────────────

z_value <- function(x) {
  coords <- sf::st_coordinates(x)
  if ("Z" %in% colnames(coords)) {
    return(coords[, "Z"])
  } else {
    stop("No Z coordinates found in the input data")
  }
}

z_mean <- function(x) {
  mean(z_value(x), na.rm = TRUE)
}

z_min <- function(x) {
  min(z_value(x), na.rm = TRUE)
}

z_max <- function(x) {
  max(z_value(x), na.rm = TRUE)
}

z_start <- function(x) {
  z_vals <- z_value(x)
  z_vals[1]
}

z_end <- function(x) {
  z_vals <- z_value(x)
  z_vals[length(z_vals)]
}

z_elevation_change_start_end <- function(x) {
  z_end(x) - z_start(x)
}

z_direction <- function(x) {
  sign(z_elevation_change_start_end(x))
}

z_cumulative_difference <- function(x) {
  z <- z_value(x)
  sum(abs(diff(z)), na.rm = TRUE)
}

# ── elevation_get ────────────────────────────────────────────────────────────

#' Get elevation data for routes
#'
#' Downloads elevation data using the ceramic package for given routes.
#' Returns a `SpatRaster` object (terra package).
#'
#' @param routes An sf object containing linestring geometries
#' @param ... Additional arguments passed to ceramic::cc_elevation
#' @return A SpatRaster covering the routes
#' @export
elevation_get <- function(routes, ...) {
  if (!requireNamespace("ceramic", quietly = TRUE)) {
    stop("Install the package ceramic to use elevation_get().")
  }
  mid_ext <- sf_mid_ext_lonlat(routes)
  bw <- max(c(mid_ext$width, mid_ext$height)) / 1 # buffer width
  suppressWarnings({
    e <- ceramic::cc_elevation(loc = mid_ext$midpoint, buffer = bw, ...)
  })
  crs_routes <- sf::st_crs(routes)
  terra::project(e, y = crs_routes$wkt)
}

#' Extract midpoint and extent from routes in lonlat
#'
#' Internal helper function to get midpoint and extent of routes in lon/lat
#' coordinates.
#'
#' @param routes An sf object containing linestring geometries
#' @return A list with midpoint coordinates and width/height dimensions
sf_mid_ext_lonlat <- function(routes) {
  res <- list()
  if (!sf::st_is_longlat(routes)) {
    routes <- sf::st_transform(routes, 4326)
  }
  bb <- sf::st_bbox(routes)
  res$midpoint <- c(mean(c(bb[1], bb[3])), mean(c(bb[2], bb[4])))
  res$width <- geodist::geodist(c(x = bb[1], y = bb[2]), c(x = bb[3], y = bb[2]))
  res$height <- geodist::geodist(
    c(x = bb[1], y = bb[2]),
    c(x = bb[1], y = bb[4])
  )
  res
}

# ── elevation_extract ────────────────────────────────────────────────────────

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

# ── elevation_add ────────────────────────────────────────────────────────────

#' Add elevation data to routes linestrings or points
#'
#' Adds elevation data to sf objects using a digital elevation model (DEM).
#'
#' For **linestring** geometries, the function attaches elevation as the Z
#' coordinate of each vertex, returning an XYZ linestring sf object.
#'
#' For **point** geometries, the function embeds the Z coordinate directly in
#' the geometry by default (returning POINT Z features), consistent with the
#' linestring behaviour. An `elevation` column can additionally be added by
#' setting `add_column = TRUE`.
#'
#' @param routes An sf object containing linestring or point geometries.
#' @param dem A SpatRaster object containing elevation data
#'   (default: `NULL` for automatic download via `elevation_get()`).
#' @param method Method for raster extraction (default: `"bilinear"`).
#' @param add_z For **point** geometries only: if `TRUE` (the default), the Z
#'   coordinate is embedded directly in the point geometry, returning POINT Z
#'   features. Set to `FALSE` to keep the original XY geometry. Ignored for
#'   linestrings (Z is always added to linestring vertices).
#' @param add_column For **point** geometries only: if `TRUE`, an `elevation`
#'   column is added to the returned sf object in addition to (or instead of,
#'   when `add_z = FALSE`) the Z geometry. Default: `FALSE`. Ignored for
#'   linestrings.
#' @param terra Deprecated. Ignored; terra is always used.
#' @return An sf object. For linestrings: XYZ linestring geometries. For points:
#'   POINT Z geometry (when `add_z = TRUE`) and/or an `elevation` column (when
#'   `add_column = TRUE`).
#' @export
#' @examples
#' library(sf)
#' # Linestring usage:
#' routes <- lisbon_road_network[204, ]
#' dem <- dem_lisbon()
#' (r3d <- elevation_add(routes, dem))
#' st_z_range(r3d)
#' plot(st_coordinates(r3d)[, 3])
#' plot_slope(r3d)
#' # Point usage — Z embedded in geometry by default:
#' pts <- sf::st_cast(sf::st_geometry(lisbon_road_network[204, ]), "POINT")
#' pts <- sf::st_sf(id = seq_along(pts), geometry = pts)
#' (pts_z <- elevation_add(pts, dem))
#' sf::st_z_range(pts_z)
#' # Also add an elevation column:
#' (pts_z_col <- elevation_add(pts, dem, add_column = TRUE))
#' pts_z_col$elevation
#' # Only an elevation column, keep XY geometry:
#' (pts_col <- elevation_add(pts, dem, add_z = FALSE, add_column = TRUE))
#' \dontrun{
#' # Get elevation data (requires internet connection, ceramic pkg, and API key):
#' if (requireNamespace("ceramic", quietly = TRUE)) {
#'   r3d_get <- elevation_add(cyclestreets_route)
#'   plot_slope(r3d_get)
#' }
#' }
elevation_add <- function(routes, dem = NULL, method = "bilinear",
                          add_z = TRUE, add_column = FALSE,
                          terra = NULL) {
  if (!is.null(terra)) {
    .Deprecated(msg = "The 'terra' argument is deprecated and ignored. terra is always used.")
  }
  stopifnotsf(routes)

  geom_types <- unique(sf::st_geometry_type(routes))

  # ── POINT branch ────────────────────────────────────────────────────────────
  if (all(geom_types %in% c("POINT", "MULTIPOINT"))) {
    if (is.null(dem)) {
      dem <- elevation_get(routes)
      r_original <- routes
      routes <- sf::st_transform(routes, terra::crs(dem))
      suppressWarnings({
        sf::st_crs(routes) <- sf::st_crs(r_original)
      })
      m <- sf::st_coordinates(routes)
      mo <- sf::st_coordinates(r_original)
      z <- as.numeric(elevation_extract(m, dem, method = method))
      routes <- r_original # restore original CRS / coords
    } else {
      m <- sf::st_coordinates(routes)
      z <- as.numeric(elevation_extract(m, dem, method = method))
      mo <- m
    }
    if (add_column) {
      routes$elevation <- z
    }
    if (add_z) {
      m_xyz <- cbind(mo[, 1:2], z)
      points_z <- lapply(seq_len(nrow(m_xyz)), function(i) {
        sf::st_point(m_xyz[i, ], dim = "XYZ")
      })
      sf::st_geometry(routes) <- sf::st_sfc(points_z, crs = sf::st_crs(routes))
    }
    return(routes)
  }

  # ── LINESTRING branch ────────────────────────────────────────────────────────
  if (is.null(dem)) {
    dem <- elevation_get(routes) # returns SpatRaster
    r_original <- routes
    routes <- sf::st_transform(routes, terra::crs(dem))
    suppressWarnings({
      sf::st_crs(routes) <- sf::st_crs(r_original)
    })
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
