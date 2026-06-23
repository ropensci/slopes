# slopes 2.0.0 — Major release & CRAN resubmission after archival

## Summary of changes

The package was archived on 2026-05-24 due to a CRAN check failure (#72).
This submission fixes that issue and introduces a major bump to 2.0.0, resolving the long-standing issue #60
(migrating entirely from the deprecated `raster` package to `terra`).

### Key changes:
- **Migrated from `raster` to `terra`** (closes #60): `raster` is no longer
  developed and was removed from `Imports` and `Suggests`. `terra` is now the sole raster
  dependency.
- **Fixed CRAN `--run-donttest` failure** (closes #72): The
  `elevation_add()` example that triggered `ceramic`/Mapbox downloads is now
  wrapped in `\dontrun{}` instead of `\donttest{}`.
- The bundled DEM dataset has been renamed from `dem_lisbon_raster` (a
  `RasterLayer`) to `dem_lisbon()` (a function returning a `SpatRaster`).
  terra rasters cannot be serialised to `.rda`; shipping as a `.tif` in
  `inst/` and exposing via an accessor function is the recommended pattern.
- Fixed `slopes_palette()` to support dynamic lengths correctly.
- Improved test suite to increase package coverage.

## R CMD check results (local, --as-cran)

0 errors | 0 warnings | 0 notes

Tested on:
- Linux (Ubuntu 24.04), R 4.6.x
