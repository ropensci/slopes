# Calculate weighted slopes from coordinate matrix

Applies distance-based weighting to slope calculations from coordinate
matrix.

## Usage

``` r
slope_matrix_weighted(m, elevations = m[, 3], lonlat = TRUE, directed = FALSE)
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

Numeric value representing the weighted slope
