# Calculate slopes using raster elevation data

Calculates slope gradients for routes using digital elevation model
(DEM) raster data.

## Usage

``` r
slope_raster(
  routes,
  dem,
  lonlat = sf::st_is_longlat(routes),
  method = "bilinear",
  fun = slope_matrix_weighted,
  terra = NULL,
  directed = FALSE
)
```

## Arguments

- routes:

  An sf object containing linestring geometries

- dem:

  A SpatRaster object (terra package) containing elevation data

- lonlat:

  Logical, whether coordinates are longitude/latitude (default:
  auto-detected)

- method:

  Method for raster extraction (default: "bilinear")

- fun:

  Function for slope calculation (default: slope_matrix_weighted)

- terra:

  Deprecated. Ignored; terra is always used.

- directed:

  Logical, whether to calculate directed slopes (default: FALSE)

## Value

Numeric vector of slope values
