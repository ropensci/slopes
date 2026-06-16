# Changelog

## slopes 1.0.2

- Migrated from the deprecated `raster` package to `terra` (closes
  [\#60](https://github.com/ropensci/slopes/issues/60)). `terra` is now
  a hard dependency (`Imports`); `raster` is no longer required.
- [`elevation_extract()`](https://docs.ropensci.org/slopes/reference/elevation_extract.md),
  [`slope_raster()`](https://docs.ropensci.org/slopes/reference/slope_raster.md),
  and
  [`elevation_add()`](https://docs.ropensci.org/slopes/reference/elevation_add.md)
  now always use `terra`. The `terra =` argument is deprecated (with a
  message) and ignored.
- [`elevation_get()`](https://docs.ropensci.org/slopes/reference/elevation_get.md)
  now always returns a `SpatRaster`. The `output_format =` argument is
  deprecated and ignored.
- [`slope_matrix_to_raster()`](https://docs.ropensci.org/slopes/reference/slope_matrix_to_raster.md)
  and
  [`slope_xyz_simple()`](https://docs.ropensci.org/slopes/reference/slope_xyz_simple.md)
  now work with `SpatRaster` objects. Legacy `Raster*` objects are
  accepted with an automatic conversion message for backwards
  compatibility.
- The bundled dataset has been renamed from `dem_lisbon_raster` to
  `dem_lisbon` and is now a `SpatRaster` object (was a `RasterLayer`).
- Fixed CRAN `--run-donttest` failure: the `ceramic`/Mapbox-dependent
  example in
  [`elevation_add()`](https://docs.ropensci.org/slopes/reference/elevation_add.md)
  is now wrapped in `\dontrun{}` instead of `\donttest{}` (closes
  [\#72](https://github.com/ropensci/slopes/issues/72)).

## slopes 1.0.1

CRAN release: 2025-06-23

- Package source code now hosted at <https://github.com/ropensci/slopes>
- New documentation section showing how directed routes work:
  <https://docs.ropensci.org/slopes/articles/slopes.html#splitting-the-network>

## slopes 1.0.0

- We have submitted and responded to all comments to [rOpenSci
  review](https://github.com/ropensci/software-review/issues/420).  
- Many changes, including breaking changes to function names.  
- Added a `NEWS.md` file to track changes to the package.

## slopes 0.0.1

- Initial version of the package on GitHub.
