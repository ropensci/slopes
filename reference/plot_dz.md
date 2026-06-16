# Plot distance-elevation profile with slope coloring

Creates a distance-elevation plot with segments colored by slope
gradient.

## Usage

``` r
plot_dz(
  d,
  z,
  fill = TRUE,
  horiz = FALSE,
  pal = NULL,
  ...,
  legend_position = "top",
  col = "black",
  cex = 0.9,
  bg = grDevices::rgb(1, 1, 1, 0.8),
  title = "Slope colors (percentage gradient)",
  brks = c(3, 6, 10, 20, 40, 100),
  seq_brks = NULL,
  ncol = 4
)
```

## Arguments

- d:

  Vector of cumulative distances

- z:

  Vector of elevation values

- fill:

  Logical, whether to fill segments with slope colors (default: TRUE)

- horiz:

  Logical, whether legend should be horizontal (default: FALSE)

- pal:

  Color palette for slope visualization (default: NULL, uses
  slopes_palette)

- ...:

  Additional arguments passed to graphics functions

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

  Sequence of breaks to show in legend (default: NULL, auto-generated)

- ncol:

  Number of columns in legend (default: 4)

## Value

NULL (creates plot as side effect)
