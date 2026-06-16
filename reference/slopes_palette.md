# Get color palette for slopes visualization

Returns a color palette suitable for visualizing slope data, with
options for different color schemes.

## Usage

``` r
slopes_palette(n = 6, palette = "Green-Brown")
```

## Arguments

- n:

  Number of colors to return (default: 6)

- palette:

  Name of the color palette to use (default: "Green-Brown")

## Value

A character vector of color codes

## Examples

``` r
# Get default Green-Brown palette with 6 colors
slopes_palette()
#> [1] "#004B40" "#F6F6F6" "#533600" NA        NA        NA       

# Get 4 colors from Green-Brown palette
slopes_palette(n = 4)
#> [1] "#004B40" "#F6F6F6" "#533600" NA       

# Use a different palette
slopes_palette(n = 5, palette = "Blue-Red")
#> [1] "#023FA5" "#A1A6C8" "#E2E2E2" "#CA9CA4" "#8E063B"
```
