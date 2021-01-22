# Aim: get incline data for validation of slopes package

library(dplyr)
library(slopes)

u = "https://opendata.arcgis.com/datasets/383027d103f042499693da22d72d10e3_0.kml"
f = basename(u)
download.file(u, f)

s = sf::read_sf(f)
