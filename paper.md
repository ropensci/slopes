slopes: An R Package to Calculate Slopes of Roads, Rivers and
Trajectories
================
27 September 2021

# Summary

This package provides functions and example data to support research
into the slope (also known as longitudinal gradient or steepness) of
linear geographic entities such as roads (Ariza-López et al. 2019) and
rivers (Cohen et al. 2018). The package was initially developed to
calculate the steepness of street segments but can be used to calculate
steepness of any linear feature that can be represented as LINESTRING
geometries in the ‘sf’ class system (Pebesma 2018). The package takes
two main types of input data for slope calculation: vector geographic
objects representing linear features, and raster geographic objects with
elevation values (which can be downloaded using functionality in the
package) representing a continuous terrain surface. Where no raster
object is provided the package attempts to download elevation data using
the ‘ceramic’ package.

# Statement of need

Although there are several ways to name “slope”, such as “steepness”,
“hilliness”, “inclination”, “aspect”, “gradient”, “declivity”, the
referred `slopes` in this package can be defined as the “longitudinal
gradient” of linear geographic entities, as defined in the context of
rivers by(Cohen et al. 2018).

The package was initially developed to research road slopes to support
evidence-based sustainable transport policies. Accounting for gradient
when planning for new cycling infrastructure and road space reallocation
for walking and cycling can improve outcomes, for example by helping to
identify routes that avoid steep hills. The package can be used to
calculate and visualise slopes of rivers and trajectories representing
movement on roads of the type published as open data by Ariza-López et
al. (2019).

Data on slopes are useful in many fields of research, including
[hydrology](https://en.wikipedia.org/wiki/Stream_gradient), natural
hazards (including
[flooding](https://www.humanitarianresponse.info/fr/operations/afghanistan/infographic/afg-river-gradient-and-flood-hazard)
and [landslide risk
management](https://assets.publishing.service.gov.uk/media/57a08d0740f0b652dd0016f4/R7815-ADD017_col.pdf)),
recreational and competitive sports such as
[cycling](http://theclimbingcyclist.com/gradients-and-cycling-an-introduction/),
[hiking](https://trailism.com/trail-grades/), and
[skiing](https://www.snowplaza.co.uk/blog/16682-skiing-steeps-what-does-gradient-mean-ski-piste/).
Slopes are also also important in some branches of [transport and
emissions
modelling](https://doi.org/10.1016/j.trpro.2016.05.258)
and [ecology](https://doi.org/10.1016/j.ncon.2016.10.001). A growing
number of people working with geospatial data require accurate estimates
of gradient, including:

- Transport planning practitioners who require accurate estimates of
  roadway gradient for estimating energy consumption, safety and mode
  shift potential in hilly cities (such as Lisbon, the case study city
  used in the examples in the documentation).
- Vehicle routing software developers, who need to build systems are
  sensitive to going up or down steep hills (e.g. bicycles, trains, and
  large trucks), such as active travel planning, logistics, and
  emergency services.
- Natural hazard researchers and risk assessors require estimates of
  linear gradient to inform safety and mitigation plans associated with
  project on hilly terrain.
- Aquatic ecologists, flooding researchers and others, who could benefit
  from estimates of river gradient to support modelling of storm
  hydrographs

There likely other domains where slopes could be useful, such as
agriculture, geology, and civil engineering.

An example of the demand for data provided by the package is a map
showing gradients across Sao Paulo (Brazil, see image below) that has
received more than 300 ‘likes’ on Twitter and generated conversations:
<https://twitter.com/DanielGuth/status/1347270685161304069>

<img
src="https://camo.githubusercontent.com/30a3b814dd72aef5b51db635f2ab6e1b6b6c57b856d239822788967a4932d655/68747470733a2f2f7062732e7477696d672e636f6d2f6d656469612f45724a32647238574d414948774d6e3f666f726d61743d6a7067266e616d653d6c61726765"
style="width:50.0%" />

# Usage and Key functions

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("ropensci/slopes")
```

### Installation for DEM downloads

If you do not already have DEM data and want to make use of the
package’s ability to download them using the `ceramic` package, install
the package with suggested dependencies, as follows:

``` r
# install.packages("remotes")
remotes::install_github("ropensci/slopes", dependencies = "Suggests")
```

Furthermore, you will need to add a MapBox API key to be able to get DEM
datasets, by signing up and registering for a key at
<https://account.mapbox.com/access-tokens/> and then following these
steps:

``` r
usethis::edit_r_environ()
MAPBOX_API_KEY=xxxxx # replace XXX with your api key
```

The key functions in the package are `elevation_add()`, which adds a
third ‘Z’ coordinate value for each vertex defining LINESTRING objects,
and `slope_xyz()` which calculates slopes for each linear feature in a
simple features object.

By default, the elevation of each vertex is estimated using [bilinear
interpolation](https://en.wikipedia.org/wiki/Bilinear_interpolation)
(`method = "bilinear"`) which calculates point height based on proximity
to the centroids of surrounding cells. The value of the `method`
argument is passed to the `method` argument in
[`raster::extract()`](https://rspatial.github.io/raster/reference/extract.html)
or
[`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html)
depending on the class of the input raster dataset. See Kidner, Dorey,
and Smith (1999) for descriptions of alternative elevation interpolation
and extrapolation algorithms.

<!-- # Calculating slopes on regional transport networks -->
<!-- # Acknowledgements -->

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-ariza-lopez_dataset_2019" class="csl-entry">

Ariza-López, Francisco Javier, Antonio Tomás Mozas-Calvache, Manuel
Antonio Ureña-Cámara, and Paula Gil de la Vega. 2019. “Dataset of
Three-Dimensional Traces of Roads.” *Scientific Data* 6 (1): 1–10.
<https://doi.org/10.1038/s41597-019-0147-x>.

</div>

<div id="ref-cohen_global_2018" class="csl-entry">

Cohen, Sagy, Tong Wan, Md Tazmul Islam, and J. P. M. Syvitski. 2018.
“Global River Slope: A New Geospatial Dataset and Global-Scale
Analysis.” *Journal of Hydrology* 563 (August): 1057–67.
<https://doi.org/10.1016/j.jhydrol.2018.06.066>.

</div>

<div id="ref-kidner_what_1999" class="csl-entry">

Kidner, David, Mark Dorey, and Derek Smith. 1999. “GeoComputation.” In.
Vol. 99. Mary Washington College Fredericksburg, Virginia, USA:
www.geocomputation.org.
<http://www.geocomputation.org/1999/082/gc_082.htm>.

</div>

<div id="ref-pebesma_simple_2018" class="csl-entry">

Pebesma, Edzer. 2018. “Simple Features for R: Standardized Support for
Spatial Vector Data.” *The R Journal*.
<https://journal.r-project.org/archive/2018/RJ-2018-009/index.html>.

</div>

</div>
