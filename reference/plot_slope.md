# Plot elevation profile with slope coloring

Creates an elevation profile plot from route geometries with XYZ
coordinates, with segments colored according to slope gradient.

## Usage

``` r
plot_slope(
  route_xyz,
  lonlat = sf::st_is_longlat(route_xyz),
  fill = TRUE,
  horiz = FALSE,
  pal = NULL,
  legend_position = "top",
  col = "black",
  cex = 0.9,
  bg = grDevices::rgb(1, 1, 1, 0.8),
  title = "Slope colors (percentage gradient)",
  brks = c(3, 6, 10, 20, 40, 100),
  seq_brks = seq(from = 3, to = length(brks) * 2 - 2),
  ncol = 4,
  ...
)
```

## Arguments

- route_xyz:

  An sf object containing linestring geometries with XYZ coordinates

- lonlat:

  Logical, whether coordinates are longitude/latitude (default:
  auto-detected)

- fill:

  Logical, whether to fill segments with slope colors (default: TRUE)

- horiz:

  Logical, whether legend should be horizontal (default: FALSE)

- pal:

  Color palette for slope visualization (default: NULL, uses
  slopes_palette)

- legend_position:

  Position of legend (default: "top")

- col:

  Color of the elevation profile line (default: "black")

- cex:

  Character expansion factor for legend text (default: 0.9)

- bg:

  Background color for legend (default: semi-transparent white)

- title:

  Title for the legend (default: "Slope colors (percentage gradient)")

- brks:

  Vector of slope break points for coloring (default: c(3, 6, 10, 20,
  40, 100))

- seq_brks:

  Sequence of breaks to show in legend (default: auto-generated)

- ncol:

  Number of columns in legend (default: 4)

- ...:

  Additional arguments passed to plot_dz

## Value

NULL (creates plot as side effect)
