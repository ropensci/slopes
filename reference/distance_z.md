# Extract distance and elevation data from route

Extracts cumulative distance and elevation vectors from route XYZ
coordinates.

## Usage

``` r
distance_z(route_xyz, lonlat)
```

## Arguments

- route_xyz:

  An sf object with XYZ coordinates

- lonlat:

  Logical, whether coordinates are longitude/latitude

## Value

List with components d (distances) and z (elevations)
