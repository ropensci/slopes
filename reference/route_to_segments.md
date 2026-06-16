# Split a route into vertex-to-vertex segments

Splits a linestring with XYZ coordinates into individual 2-point
segments, one per consecutive vertex pair. Useful for computing
per-segment slopes with
[`slope_xyz()`](https://docs.ropensci.org/slopes/reference/slope_xyz.md).

## Usage

``` r
route_to_segments(route_xyz)
```

## Arguments

- route_xyz:

  An sf object with a single LINESTRING geometry with Z coordinates, as
  returned by
  [`elevation_add()`](https://docs.ropensci.org/slopes/reference/elevation_add.md).

## Value

An sf object with one LINESTRING feature per vertex-to-vertex segment.

## Examples

``` r
route_xyz = elevation_add(lisbon_route, dem = dem_lisbon())
segs = route_to_segments(route_xyz)
segs$slope = slope_xyz(segs)
summary(segs$slope)
#>      Min.   1st Qu.    Median      Mean   3rd Qu.      Max.       NAs 
#> 0.0001026 0.0239350 0.0545492 0.0770948 0.1076403 0.4570354        24 
```
