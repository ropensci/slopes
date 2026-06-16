# Read the bundled Lisbon DEM as a SpatRaster

Returns a `SpatRaster` (terra package) of the Digital Elevation Model
for central Lisbon, Portugal, bundled with the slopes package.

## Usage

``` r
dem_lisbon()
```

## Value

A `SpatRaster` object with 133 rows, 200 columns, and 1 elevation layer.

## Examples

``` r
dem_lisbon()
#> class       : SpatRaster
#> size        : 133, 200, 1  (nrow, ncol, nlyr)
#> resolution  : 10, 10  (x, y)
#> extent      : -88285, -86285, -106485, -105155  (xmin, xmax, ymin, ymax)
#> coord. ref. : 
#> source      : dem_lisbon.tif
#> name        :        r1
#> min value   :         0
#> max value   : 97.905998
```
