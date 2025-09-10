#' Plot distance-elevation profile with slope coloring
#'
#' Creates a distance-elevation plot with segments colored by slope gradient.
#'
#' @param d Vector of cumulative distances
#' @param z Vector of elevation values
#' @param fill Logical, whether to fill segments with slope colors (default: TRUE)
#' @param horiz Logical, whether legend should be horizontal (default: FALSE)
#' @param pal Color palette for slope visualization (default: NULL, uses slopes_palette)
#' @param ... Additional arguments passed to graphics functions
#' @param legend_position Position of legend (default: "top")
#' @param col Color of the elevation profile line (default: "black")
#' @param cex Character expansion factor for legend text (default: 0.9)
#' @param bg Background color for legend (default: semi-transparent white)
#' @param title Title for the legend (default: "Slope colors (percentage gradient)")
#' @param brks Vector of slope break points for coloring (default: c(3, 6, 10, 20, 40, 100))
#' @param seq_brks Sequence of breaks to show in legend (default: NULL, auto-generated)
#' @param ncol Number of columns in legend (default: 4)
#' @return NULL (creates plot as side effect)
#' @export
plot_dz <- function(
    d, z, fill = TRUE, horiz = FALSE, pal = NULL, ...,
    legend_position = "top", col = "black", cex = 0.9,
    bg = grDevices::rgb(1, 1, 1, 0.8),
    title = "Slope colors (percentage gradient)",
    brks = c(3, 6, 10, 20, 40, 100),
    seq_brks = NULL,
    ncol = 4
) {
  # Make breaks
  b <- make_breaks(brks)
  # Use palette of correct length
  if (is.null(pal)) pal <- slopes_palette(n = length(b) - 1)
  # Ensure pal matches intervals
  if (length(pal) != length(b) - 1) {
    pal <- grDevices::colorRampPalette(pal)(length(b) - 1)
  }
  graphics::plot(d, z, type = "l", col = "brown", lwd = 2)
  if (fill) {
    g <- slope_vector(x = d, elevations = z)
    colz <- make_colz(g, b, pal)
    lapply(seq(d)[-(length(d))], function(i) {
      graphics::polygon(
        x = c(d[i:(i + 1)], d[(i + 1):i]),
        y = c(z[i], z[i + 1], 0, 0),
        col = colz[i],
        border = NA
      )
    })
    graphics::lines(d, z, col = col, lwd = 2)
    if(is.null(seq_brks)) seq_brks <- seq(from = 3, to = length(b) - 2)
    s <- c(seq_brks[-(length(seq_brks) / 2) -1], max(seq_brks) + 1)
    graphics::legend(x = legend_position, legend = b[s] * 100, fill = pal[s],
                     ..., bg = bg, title = title, horiz = horiz,
                     ncol = ncol, cex = cex)
  }
}

#' Plot elevation profile with slope coloring
#'
#' Creates an elevation profile plot from route geometries with XYZ coordinates,
#' with segments colored according to slope gradient.
#'
#' @param route_xyz An sf object containing linestring geometries with XYZ coordinates
#' @param lonlat Logical, whether coordinates are longitude/latitude (default: auto-detected)
#' @param fill Logical, whether to fill segments with slope colors (default: TRUE)
#' @param horiz Logical, whether legend should be horizontal (default: FALSE)
#' @param pal Color palette for slope visualization (default: NULL, uses slopes_palette)
#' @param legend_position Position of legend (default: "top")
#' @param col Color of the elevation profile line (default: "black")
#' @param cex Character expansion factor for legend text (default: 0.9)
#' @param bg Background color for legend (default: semi-transparent white)
#' @param title Title for the legend (default: "Slope colors (percentage gradient)")
#' @param brks Vector of slope break points for coloring (default: c(3, 6, 10, 20, 40, 100))
#' @param seq_brks Sequence of breaks to show in legend (default: auto-generated)
#' @param ncol Number of columns in legend (default: 4)
#' @param ... Additional arguments passed to plot_dz
#' @return NULL (creates plot as side effect)
#' @export
plot_slope <- function(
    route_xyz,
    lonlat = sf::st_is_longlat(route_xyz),
    fill = TRUE,
    horiz = FALSE,
    pal = NULL,
    legend_position = "top",
    col = "black",
    cex = 0.9,
    bg = grDevices::rgb(1, 1, 1, 0.8),
    title = "Slope colors (percentage gradient)",
    brks = c(3, 6, 10, 20, 40, 100),
    seq_brks = seq(from = 3, to = length(brks) * 2 - 2),
    ncol = 4,
    ...
) {
  if (is.null(pal)) pal <- slopes_palette(n = length(brks) - 1)
  if(is.na(lonlat)) {
    stop(
      "CRS of routes not known. Set the CRS, e.g. as follows:\n",
      "sf::st_crs(routes) = 4326 # if the routes are in lon/lat coordinates"
    )
  }
  dz <- distance_z(route_xyz, lonlat = lonlat)
  # Corrected call
  plot_dz(
    d = dz$d,
    z = dz$z,
    fill = fill,
    horiz = horiz,
    pal = pal,
    legend_position = legend_position,
    col = col,
    cex = cex,
    bg = bg,
    title = title,
    brks = brks,
    seq_brks = seq_brks,
    ncol = ncol,
    ...
  )
}

#' Create color palette for slope visualization
#'
#' Creates or processes color palettes for slope gradient visualization.
#'
#' @param pal Color palette (function or character vector)
#' @param b Vector of breaks for color mapping
#' @return Character vector of colors
make_pal <- function(pal, b) {
  if (identical(pal, colorspace::diverging_hcl)) {
    pal <- slopes_palette(n = length(b) - 1)
  } else if (is.function(pal)) {
    pal <- pal(n = length(b) - 1)
  } else if (is.character(pal)) {
    if (length(pal) < length(b) - 1) {
      pal <- grDevices::colorRampPalette(pal)(length(b) - 1)
    } else {
      pal <- pal[seq_len(length(b) - 1)]
    }
  } else {
    stop("pal must be a function or a character vector of hex colors")
  }
  pal
}

#' Extract distance and elevation data from route
#'
#' Extracts cumulative distance and elevation vectors from route XYZ coordinates.
#'
#' @param route_xyz An sf object with XYZ coordinates
#' @param lonlat Logical, whether coordinates are longitude/latitude
#' @return List with components d (distances) and z (elevations)
distance_z <- function(route_xyz, lonlat) {
  m <- sf::st_coordinates(route_xyz)
  d <- cumsum(sequential_dist(m, lonlat = lonlat))
  d <- c(0, d)
  z <- m[, 3]
  list(d = d, z = z)
}

#' Create slope breaks for color mapping
#'
#' Creates symmetric slope breaks around zero for color classification.
#'
#' @param brks Vector of positive slope break values (as percentages)
#' @return Vector of slope breaks including negative values and zero
make_breaks <- function(brks) {
  n <- brks
  n <- c(-rev(n), 0, (n))
  b <- n / 100
  b
}

#' Assign colors to slope values
#'
#' Maps slope gradient values to colors based on break points.
#'
#' @param g Vector of slope gradient values
#' @param b Vector of break points
#' @param pal Vector of colors corresponding to breaks
#' @return Character vector of colors for each slope value
make_colz <- function(g, b, pal) {
  colz <- cut(
    x = g,
    breaks = b,
    labels = pal
  )
  as.character(colz)
}
