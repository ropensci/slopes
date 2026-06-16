# Calculate distance-weighted slopes

Applies distance-based weighting to slope calculations for more accurate
results.

## Usage

``` r
slope_distance_weighted(d, elevations, directed = FALSE)
```

## Arguments

- d:

  Vector of distance values between points

- elevations:

  Vector of elevation values

- directed:

  Logical, whether to calculate directed slopes (default: FALSE)

## Value

Numeric value representing the weighted slope
