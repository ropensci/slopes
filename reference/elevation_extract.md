# Extract elevation values from coordinates

Extracts elevation values from a DEM raster at specified coordinate
locations. Accepts both `SpatRaster` (terra) and legacy `Raster*`
(raster) objects; legacy objects are automatically converted to
`SpatRaster`.

## Usage

``` r
elevation_extract(m, dem, method = "bilinear", terra = NULL)
```

## Arguments

- m:

  Matrix or sf object with coordinates

- dem:

  A SpatRaster (or legacy RasterLayer) containing elevation data

- method:

  Method for raster extraction (default: "bilinear")

- terra:

  Deprecated. Ignored; terra is always used.

## Value

Numeric vector of elevation values
