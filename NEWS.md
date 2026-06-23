# slopes 2.0.0

* Migrated from the deprecated `raster` package to `terra` (closes #60).
  `terra` is now a hard dependency (`Imports`); `raster` is no longer required or suggested.
* `elevation_extract()`, `slope_raster()`, and `elevation_add()` now always use
  `terra`. The `terra =` argument is deprecated (with a message) and ignored.
* `elevation_get()` now always returns a `SpatRaster`. The `output_format =`
  argument is deprecated and ignored.
* `slope_matrix_to_raster()` and `slope_xyz_simple()` now work with `SpatRaster`
  objects. Legacy `Raster*` objects are accepted with an automatic conversion
  message for backwards compatibility.
* The bundled dataset has been renamed from `dem_lisbon_raster` to `dem_lisbon`
  and is now a `SpatRaster` object (was a `RasterLayer`).
* Fixed CRAN `--run-donttest` failure: the `ceramic`/Mapbox-dependent example in
  `elevation_add()` is now wrapped in `\dontrun{}` instead of `\donttest{}` (closes #72).
* Fixed `slopes_palette()` hardcoded testing logic, allowing it to correctly return any number of requested colors for the "Green-Brown" palette.
* Substantially improved overall package test coverage (from ~59% to over 84%) by adding test wrappers for plot functions and matrix conversion utilities.

# slopes 1.0.1


* Package source code now hosted at https://github.com/ropensci/slopes
* New documentation section showing how directed routes work: https://docs.ropensci.org/slopes/articles/slopes.html#splitting-the-network

# slopes 1.0.0

* We have submitted and responded to all comments to [rOpenSci review](https://github.com/ropensci/software-review/issues/420).  
* Many changes, including breaking changes to function names.  
* Added a `NEWS.md` file to track changes to the package.  


# slopes 0.0.1

* Initial version of the package on GitHub.  
