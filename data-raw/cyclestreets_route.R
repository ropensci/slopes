# Get data from cyclestreets
cyclestreets_route = cyclestreets::journey(
  stplanr::geo_code("Potternewton Park Leeds"),
  stplanr::geo_code("University of Leeds")
)
usethis::use_data(cyclestreets_route)
