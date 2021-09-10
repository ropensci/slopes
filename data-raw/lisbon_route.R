sln = stplanr::SpatialLinesNetwork(lisbon_road_network)
points = sf::st_as_sf(crs = 4326, coords = c("X1", "X2"), data.frame(rbind(
  stplanr::geo_code("Santa Catarina, Lisbon"),
  stplanr::geo_code("Castelo, Lisbon")
)))
points_proj = sf::st_transform(points, sf::st_crs(lisbon_road_network))
coords = sf::st_coordinates(points_proj)
nodes = stplanr::find_network_nodes(sln, coords[, 1], coords[, 2])
lisbon_route = stplanr::sum_network_routes(sln = sln, start = nodes[1], end = nodes[2])
mapview::mapview(lisbon_route) +
  mapview::mapview(lisbon_road_network["Avg_Slope"])
lisbon_route_3d = elevation_add(lisbon_route, dem_lisbon_raster)
usethis::use_data(lisbon_route, overwrite = TRUE)
usethis::use_data(lisbon_route_3d, overwrite = TRUE)
