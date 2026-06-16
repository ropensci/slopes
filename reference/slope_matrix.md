# Calculate slopes from coordinate matrix

Calculates slope gradients from a matrix of coordinates and elevation
data.

## Usage

``` r
slope_matrix(m, elevations = m[, 3], lonlat = TRUE)
```

## Arguments

- m:

  Matrix of coordinates (x, y, z)

- elevations:

  Vector of elevation values (default: third column of m)

- lonlat:

  Logical, whether coordinates are longitude/latitude (default: TRUE)

## Value

Numeric vector of slope values
