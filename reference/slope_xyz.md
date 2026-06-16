# Calculate slopes from XYZ coordinate data

Calculates slope gradients from linestring geometries with XYZ
coordinates.

## Usage

``` r
slope_xyz(
  route_xyz,
  fun = slope_matrix_weighted,
  lonlat = TRUE,
  directed = FALSE
)
```

## Arguments

- route_xyz:

  An sf object or data frame with XYZ coordinates

- fun:

  Function for slope calculation (default: slope_matrix_weighted)

- lonlat:

  Logical, whether coordinates are longitude/latitude (default: TRUE)

- directed:

  Logical, whether to calculate directed slopes (default: FALSE)

## Value

Numeric vector of slope values
