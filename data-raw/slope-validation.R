# Aim: get incline data for validation of slopes package

remotes::install_github("ropensci/slopes")
# remotes::install_github("ropensci/slopes", "2c9ef51509ffc64309d5100148cbc21c212f5772")

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
magnolia_xy = s_magnolia %>%
  select(BLOCKNBR, SPEEDLIMIT, SLOPE_PCT)

usethis::use_data(magnolia_xy, overwrite = TRUE)
sf::st_crs(magnolia_xy)

# slope_raster(magnolia_xy) # fails
magnolia_xyz = elevation_add(magnolia_xy)
magnolia_xyz$slopes = round(slope_xyz(magnolia_xyz)*100)
summary(magnolia_xyz$SLOPE_PCT)
summary(magnolia_xyz$slopes)
plot(magnolia_xyz$SLOPE_PCT, magnolia_xyz$slopes)
cor.test(magnolia_xyz$SLOPE_PCT, magnolia_xyz$slopes) #0.8888281 -- original vs. ceramic

# test with slope_raster, and SRTM raster file
load("data-raw/dem_seattle_raster.rda")
# dem = raster::raster("~/itsleeds/pctLisbon-data/Seattle_clip_SRTM.tif")
dem = seattleraster

raster::plot(dem)
plot(sf::st_geometry(magnolia_xyz), add = TRUE)
magnolia_xyz$slope_srtm = slope_raster(magnolia_xyz, e = dem, lonlat = TRUE)
magnolia_xyz$slope_srtm = round(100 * magnolia_xyz$slope_srtm)
summary(magnolia_xyz$slope_srtm)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max.
# 0.000   2.000   4.000   5.522   8.000  19.000
mapview::mapview(magnolia_xyz["slope_srtm"])

cor.test(magnolia_xyz$SLOPE_PCT, magnolia_xyz$slope_srtm) #0.8013725 -- original vs. SRTM
cor.test(magnolia_xyz$slopes, magnolia_xyz$slope_srtm) #0.8284203 -- ceramic vs. SRTM

