## code to prepare `dem_lisbon` dataset goes here

remotes::install_github("zonebuilders/zonebuilder")
lisbon_centrepoint = tmaptools::geocode_OSM("lisbon", as.sf = TRUE)
lisbon_1km = stplanr::geo_buffer(shp = lisbon_centrepoint, dist = 1000)
mapview::mapview(lisbon_1km)
lisbon_road_segments_esri = sf::read_sf("~/wip/pctLisbon-data/Shapefiles/route_segments_gradient2_Zelevation.gpkg")
lisbon_1km_projected = sf::st_transform(lisbon_1km, sf::st_crs(lisbon_road_segments_esri))
lisbon_road_segments = sf::st_intersection(lisbon_road_segments_esri, lisbon_1km_projected)
plot(lisbon_road_segments["Avg_Slope"])


usethis::use_data(dem_lisbon, overwrite = TRUE)
