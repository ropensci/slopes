# Get elevation data for routes

Downloads elevation data using the ceramic package for given routes.
Returns a `SpatRaster` object (terra package).

## Usage

``` r
elevation_get(routes, ...)
```

## Arguments

- routes:

  An sf object containing linestring geometries

- ...:

  Additional arguments passed to ceramic::cc_elevation

## Value

A SpatRaster covering the routes
