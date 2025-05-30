% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/z.R
\name{z_value}
\alias{z_value}
\alias{z_start}
\alias{z_end}
\alias{z_mean}
\alias{z_max}
\alias{z_min}
\alias{z_elevation_change_start_end}
\alias{z_direction}
\alias{z_cumulative_difference}
\title{Calculate summary values for 'Z' elevation attributes}
\usage{
z_value(x)

z_start(x)

z_end(x)

z_mean(x)

z_max(x)

z_min(x)

z_elevation_change_start_end(x)

z_direction(x)

z_cumulative_difference(x)
}
\arguments{
\item{x}{An \code{sfc} object with \'XYZ\' coordinates}
}
\value{
A vector of numeric values representing elevations associated with
simple feature geometries that have elevations (XYZ coordinates).

A numeric vector of length 1 representing the first Z coordinate.

A numeric vector of length 1 representing the last Z coordinate.

A numeric vector of length 1 representing the mean of Z coordinates.

A numeric vector of length 1 representing the maximum of Z coordinates.

A numeric vector of length 1 representing the minimum of Z coordinates.

A numeric vector of length 1 representing the difference between the last and first Z coordinates.

A numeric vector of length 1 representing the sign of the difference between the last and first Z coordinates.

A numeric vector of length 1 representing the sum of absolute differences between consecutive Z coordinates.
}
\description{
The \verb{slope_z*()} functions calculate summary values for the Z axis
in \code{sfc} objects with \code{XYZ} geometries.
}
\examples{
if (rlang::is_installed("sf")) {
  x = slopes::lisbon_route_3d
  x
  z_value(x)[1:5]
  xy = slopes::lisbon_route
  try(z_value(xy)) # error message
  z_start(x)
  z_end(x)
  z_direction(x)
  z_elevation_change_start_end(x)
  z_direction(x)
  z_cumulative_difference(x)
}
}
