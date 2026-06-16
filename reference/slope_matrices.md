# Calculate slopes for multiple coordinate matrices

Applies slope calculation function to a list of coordinate matrices.

## Usage

``` r
slope_matrices(m_xyz_split, fun = slope_matrix_weighted, ...)
```

## Arguments

- m_xyz_split:

  List of coordinate matrices with elevation data

- fun:

  Function to apply for slope calculation (default:
  slope_matrix_weighted)

- ...:

  Additional arguments passed to the slope function

## Value

Numeric vector of slope values for all matrices
