## code to prepare `dem_lisbon` dataset goes here

remotes::install_github("zonebuilders/zonebuilder")
lisbon_centrepoint = tmaptools::geocode_OSM("lisbon", as.sf = TRUE)
lisbon_1km = stplanr::geo_buffer(shp = lisbon_centrepoint, dist = 1000)
mapview::mapview(lisbon_1km)
lisbon_road_segments_esri = sf::read_sf("~/wip/pctLisbon-data/Shapefiles/route_segments_gradient2_Zelevation.gpkg")
lisbon_1km_projected = sf::st_transform(lisbon_1km, sf::st_crs(lisbon_road_segments_esri))
lisbon_road_segments = sf::st_intersection(lisbon_road_segments_esri, lisbon_1km_projected)
plot(lisbon_road_segments["Avg_Slope"])
usethis::use_data(lisbon_road_segments)

download.file("https://github.com/geocompr/d/releases/download/1/r1.zip", "r1.zip")
unzip("r1.zip")dem_lisbon_raster = raster::raster("r1")
dem_lisbon_raster = raster::crop(dem_lisbon_raster, lisbon_1km_projected)
dem_lisbon_raster = raster::trim(dem_lisbon_raster)
raster::crs(dem_lisbon_raster) # no CRS
raster::plot(dem_lisbon_raster)
usethis::use_data(dem_lisbon_raster, overwrite = TRUE)
file.size("data/dem_lisbon_raster.rda") / 1e6 # tiny dataset
unlink("r1", recursive = TRUE)
unlink("r1.zip")

# saving alternative formats
dir.create("inst")
# raster::writeRaster(dem_lisbon_raster, filename = "dem_lisbon_raster.tif", options("COMPRESS=DEFLATE"), overwrite = TRUE, format = ".tif")
raster::writeRaster(dem_lisbon_raster, "inst/dem_lisbon_raster.asc", overwrite = TRUE)
file.size("inst/dem_lisbon_raster.asc") / 1e6 # large, so deleted

# With terra
lisbon_road_segments_terra = terra::vect("~/wip/pctLisbon-data/Shapefiles/route_segments_gradient2_Zelevation.gpkg")
dem_lisbon_terra = terra::rast("r1/hdr.adf")
dem_lisbon_terra = terra::crop(dem_lisbon_terra, terra::ext(lisbon_road_segments_terra))

