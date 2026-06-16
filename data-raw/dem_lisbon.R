## code to prepare `dem_lisbon` dataset goes here
## This script requires internet access and a local copy of the Lisbon road network.
## Run this script manually to regenerate the data object.

# remotes::install_github("zonebuilders/zonebuilder")
# lisbon_centrepoint = tmaptools::geocode_OSM("lisbon", as.sf = TRUE)
# lisbon_1km = stplanr::geo_buffer(shp = lisbon_centrepoint, dist = 1000)
# mapview::mapview(lisbon_1km)

# Load existing road network to get the bounding box / CRS
lisbon_road_network_esri = sf::read_sf("~/wip/pctLisbon-data/Shapefiles/route_segments_gradient2_Zelevation.gpkg")
lisbon_1km_projected = sf::st_transform(lisbon_1km, sf::st_crs(lisbon_road_network_esri))

# Download and crop DEM with terra
download.file("https://github.com/geocompr/d/releases/download/1/r1.zip", "r1.zip")
unzip("r1.zip")

dem_lisbon = terra::rast("r1/hdr.adf")
dem_lisbon = terra::crop(dem_lisbon, terra::ext(terra::vect(lisbon_1km_projected)))
dem_lisbon = terra::trim(dem_lisbon)
terra::crs(dem_lisbon) # check CRS
terra::plot(dem_lisbon)

usethis::use_data(dem_lisbon, overwrite = TRUE)
file.size("data/dem_lisbon.rda") / 1e6 # tiny dataset

# Clean up
unlink("r1", recursive = TRUE)
unlink("r1.zip")
