# Extract XYZ coordinates from SpatRaster or matrix

Simplifies raster or matrix data to XYZ coordinate format. Accepts
`SpatRaster` (terra), legacy `Raster*` objects, or a plain matrix.

## Usage

``` r
slope_xyz_simple(x)
```

## Arguments

- x:

  A SpatRaster, legacy RasterLayer, or matrix object

## Value

A data frame with x, y, z coordinates
