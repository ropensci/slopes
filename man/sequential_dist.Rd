% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/slopes.R
\name{sequential_dist}
\alias{sequential_dist}
\title{Calculate the sequential distances between sequential coordinate pairs}
\usage{
sequential_dist(m, lonlat = TRUE)
}
\arguments{
\item{m}{Matrix containing coordinates and elevations.
The matrix should have three columns: x, y, and z, in that order. Typically
these correspond to location in the West-East, South-North, and vertical
elevation axes respectively.
In data with geographic coordinates, Z values are assumed to be in
metres. In data with projected coordinates, Z values are assumed to have
the same units as the X and Y coordinates.}

\item{lonlat}{Are the coordinates in lon/lat (geographic) coordinates? TRUE by default.}
}
\value{
A vector of distance values in meters if \code{lonlat = TRUE}
or the map units of the input data if \code{lonlat = FALSE} between
consecutive vertices.
}
\description{
Set \code{lonlat} to \code{FALSE} if you have projected data, e.g. with coordinates
representing distance in meters, not degrees. Lonlat coodinates are assumed
(\code{lonlat = TRUE} is the default).
}
\examples{
x = c(0, 2, 3, 4, 5, 9)
y = c(0, 0, 0, 0, 0, 1)
m = cbind(x, y)
d = sequential_dist(m, lonlat = FALSE)
d
nrow(m)
length(d)
}
