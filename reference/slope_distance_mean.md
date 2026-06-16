# Calculate mean slope using distance weighting

Computes the mean slope across segments using distance-weighted
averaging.

## Usage

``` r
slope_distance_mean(d, elevations, directed = FALSE)
```

## Arguments

- d:

  Vector of distance values between points

- elevations:

  Vector of elevation values

- directed:

  Logical, whether to calculate directed slopes (default: FALSE)

## Value

Numeric value representing the mean slope
