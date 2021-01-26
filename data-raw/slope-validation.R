# Aim: get incline data for validation of slopes package

library(dplyr)
library(slopes)

# see https://data-seattlecitygis.opendata.arcgis.com/datasets/seattle-streets
# uu = "https://opendata.arcgis.com/datasets/383027d103f042499693da22d72d10e3_0.kml" not reading the fields properly
u = "https://opendata.arcgis.com/datasets/383027d103f042499693da22d72d10e3_0.geojson"
f = basename(u)
download.file(u, f)
s = sf::read_sf(f)
s
summary(s$SLOPE_PCT)

s_steep = s %>% filter(SLOPE_PCT > 10)
mapview::mapview(s_steep)

# s_2700 = s %>% filter(BLOCKNBR == 2700)
# mapview::mapview(s_2700) # fail

magnolia_sf = tmaptools::geocode_OSM("magnolia playfield seattle", as.sf = TRUE)
mapview::mapview(magnolia_sf)
magnolia_buffer = stplanr::geo_buffer(shp = magnolia_sf, dist = 1000)
s_magnolia = s[magnolia_buffer, , op = sf::st_within]
mapview::mapview(s_magnolia["SLOPE_PCT"])
magnolia_xyz = s_magnolia %>%
  select(BLOCKNBR, SPEEDLIMIT, SLOPE_PCT)

usethis::use_data(magnolia_xyz)

s_magnolia_xyz = slope_3d(r = s_magnolia)
s_magnolia_xyz$slopes = slope_xyz(s_magnolia_xyz)*100
summary(s_magnolia_xyz$SLOPE_PCT)
summary(s_magnolia_xyz$slopes)
plot(s_magnolia_xyz$SLOPE_PCT, s_magnolia_xyz$slopes)
cor.test(s_magnolia_xyz$SLOPE_PCT, s_magnolia_xyz$slopes) #0.8907462

#test with slope_raster, and SRTM raster file
# dem = load("data-raw/dem_seattle_raster.rda")
# dem = raster::raster(dem) #not working
dem = seattleraster

raster::plot(dem)
plot(sf::st_geometry(s_magnolia_xyz), add = TRUE)
s_magnolia_xyz$slope_srtm = slope_raster(s_magnolia_xyz, e = dem)
summary(s_magnolia_xyz$slope_srtm) #??? weired results
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max.
# 27.93  2159.20  4186.92  4810.97  6843.23 18889.29
mapview::mapview(s_magnolia_xyz["slope_srtm"])

cor.test(s_magnolia_xyz$SLOPE_PCT, s_magnolia_xyz$slope_srtm) #0.7410727
cor.test(s_magnolia_xyz$slopes, s_magnolia_xyz$slope_srtm) #0.7647319

