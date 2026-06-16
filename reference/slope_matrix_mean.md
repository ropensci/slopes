# Calculate mean slope from coordinate matrix

Computes the mean slope from a matrix of coordinates with elevation
data.

## Usage

``` r
slope_matrix_mean(m, elevations = m[, 3], lonlat = TRUE, directed = FALSE)
```

## Arguments

- m:

  Matrix of coordinates (x, y, z)

- elevations:

  Vector of elevation values (default: third column of m)

- lonlat:

  Logical, whether coordinates are longitude/latitude (default: TRUE)

- directed:

  Logical, whether to calculate directed slopes (default: FALSE)

## Value

Numeric value representing the mean slope
