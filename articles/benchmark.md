# Benchmarking slopes calculation

``` r
library(slopes)
library(bench)
```

## Performance

A benchmark can reveal how many route gradients can be calculated per
second using different interpolation methods:

``` r
e = dem_lisbon()
r = lisbon_road_network
res = bench::mark(check = FALSE,
  bilinear = slope_raster(r, e),
  simple   = slope_raster(r, e, method = "simple")
)
```

``` r
res
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 bilinear     21.7ms   22.8ms      43.5    18.2MB     31.6
#> 2 simple       18.8ms   19.8ms      50.1    1.88MB     32.2
```

That is approximately

``` r
round(res$`itr/sec` * nrow(r))
#> [1] 11786 13579
```

routes per second using `bilinear` and `simple` interpolation methods,
respectively.

To go faster, you can chose the `simple` method to gain some speed at
the expense of accuracy:

``` r
res2 = bench::mark(check = FALSE,
  bilinear = slope_raster(r, e, method = "bilinear"),
  simple   = slope_raster(r, e, method = "simple")
)
```

``` r
res2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 bilinear       22ms   23.5ms      42.0    1.73MB     37.8
#> 2 simple       19.3ms     20ms      49.4    1.81MB     34.2
```

``` r
round(res2$`itr/sec` * nrow(r))
#> [1] 11377 13390
```
