# Aim: get incline data for validation of slopes package

library(dplyr)
library(slopes)

u = "https://opendata.arcgis.com/datasets/383027d103f042499693da22d72d10e3_0.kml"
f = basename(u)
download.file(u, f)
s = sf::read_sf(f)
s
summary(s$BLOCKNBR)

s_steep = s %>% filter(SLOPE_PCT > 10)
mapview::mapview(s_steep)

s_2700 = s %>% filter(BLOCKNBR == 2700)
mapview::mapview(s_2700) # fail

magnolia_sf = tmaptools::geocode_OSM("magnolia playfield seattle", as.sf = TRUE)
mapview::mapview(magnolia_sf)
magnolia_buffer = stplanr::geo_buffer(shp = magnolia_sf, dist = 1000)
s_magnolia = s[magnolia_buffer, , op = sf::st_within]
mapview::mapview(s_magnolia["SLOPE_PCT"])

s_magnolia_xyz = slope_3d(r = s_magnolia)
s_magnolia_xyz$slopes = slope(s_magnolia_xyz)
plot(s_magnolia$SLOPE_PCT, s_magnolia_xyz$slopes)
