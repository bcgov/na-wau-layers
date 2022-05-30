[![img](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

# na-wau-layers

## Usage

The na-wau-layers repository processes new B.C. geospatial layers and
adds them into the WAU Biodiversity Layer. The process uses the most
recent version of the WAU Biodiversity Layer, adds the new information,
and re-writes a new version of the WAU Biodiversity Layer.

To process new layers, there are several important steps and
considerations.

### Considerations

-   The WAU Biodiversity Layer currently considers areas outside of
    current Parks and Protected Areas and Other Area-Based Conservation
    Measures (OECMs) current to 2021. New layers do not necessarily need
    to follow this standard, but users should be aware of the current
    data extent.
-   Layers should be clean and ready to use prior to inclusion in the
    WAU Biodiversity Layer.
-   There are processing options throughout for vector or raster files.
    It is up to the user to decide what type of file to use.
-   For **area-only metrics** - ***raster*** processing will be faster.
    The `01_load.R` script ensures the raster is in Hectares BC format
    prior to processing.
-   For **additional metrics** are required (e.g. species number,
    species name) - processing should likely be done in ***vector***
    format.

### Processing Steps

The first step in processing a new layer is to fill in the `header.R`
file. An example using old-growth data

#### Header Example

``` r
#update with file of interest
spatialOutDir <- "out/"
layer_file <- file.path("data/old-growth/Map1_PriorityDeferral_2021_10_24.shp")
out_dir <- file.path("out/old-growth/")
dir.create(out_dir)
#> Warning in dir.create(out_dir): 'out\old-growth' already exists
element <- 'priority_old_growth'  #underscores only, used as a file name but also column name
```

After the header script is completed, there are 4 (or 5 for vector)
scripts that need to be run in order:

-   `01_load.R`
-   `02_intersect_wau.R`
-   `03_binning.R`
-   `04_vector-metrics.R` - only use with vector inputs
-   `05_output.R`

#### Example

This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
```

### Project Status

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/na-wau-layers/issues/).

### How to Contribute

If you would like to contribute, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

### License

    Copyright 2021 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

------------------------------------------------------------------------

*This project was created using the
[bcgovr](https://github.com/bcgov/bcgovr) package.*
