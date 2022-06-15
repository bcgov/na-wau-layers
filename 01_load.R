# Copyright 2021 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

# Load base information -----------------------------------------------

source('header.R') #
source('packages.R') # load required packages

# load wau file
wau_base <- st_read("data/aqua_sfE.gpkg", crs=3005) %>%
  st_cast(to="POLYGON") %>%
  st_make_valid()


############# DON"T RUN ALL OF THIS CODE - There are 3 options below based on input data and output desired options

# Options below depending on whether the layer is raster or vector




# Vector Processing Steps here: use for attribute based metrics --------

####   Load new layer, make sure info is correct in header.R


load_data <- function(data){
  output<- st_read(data) %>%
    rename_all(tolower) %>%
    st_make_valid()
  output
}

new_layer <- load_data(layer_file)

#
saveRDS(new_layer, file = paste0("tmp/", element, '_base-vect'))




# Vector to Raster Processing Steps here: use if metrics are area-based only --------

## Create template in Hectares BC format --------------------------

prov_crs <- st_crs(bcmaps::bc_bound_hres(class='sf'))

ProvRast<-raster(nrows=15744, ncols=17216, xmn=159587.5, xmx=1881187.5,
                 ymn=173787.5, ymx=1748187.5,
                 crs=prov_crs,
                 res = c(100,100), vals = 0)

## Rasterise vector --------------------------

new_layer$value <- 1 # user will need to modify based upon data-set
new_layer_raster <- st_rasterize(new_layer, st_as_stars(ProvRast))

saveRDS(new_layer_raster, file = paste0(out_dir, "/", element, '_base-rast'))

write_stars(new_layer_raster, dsn=file.path(paste0(out_dir, "/", element, '.tif')), overwrite=TRUE)




# Raster Processing Steps here: use if metrics are area-based only ----------

new_layer<-read_stars(layer_file)

new_layer_raster <- st_rasterize(new_layer, st_as_stars(ProvRast))

saveRDS(new_layer_raster, file = paste0(out_dir, "/", element, '_base-rast'))

write_stars(new_layer_raster, dsn=file.path(paste0(out_dir, "/", element, '.tif')), overwrite=TRUE)

# Scrap code from previous work -------------------------------------------

## Do not run - temp keeping in case issues arise --------------------------


# Create a basic raster in hectares BC format
BCr_file <- file.path(spatialOutDir,"BCr.tif")
if (!file.exists(BCr_file)) {
  BC<-bcmaps::bc_bound_hres(class='sf')
  saveRDS(BC, file='out/BC.rds')
  bc_stars <- st_as_stars(BC)
  prov_crs <- st_crs(BC)
  ProvRast<-raster(nrows=15744, ncols=17216, xmn=159587.5, xmx=1881187.5,
                   ymn=173787.5, ymx=1748187.5,
                   crs=prov_crs,
                   res = c(100,100), vals = 0)
  ProvRast_S<-st_as_stars(ProvRast)
  write_stars(ProvRast_S,dsn=file.path(spatialOutDir,'ProvRast_S.tif'))
  BCr <- fasterize(BC,ProvRast)
  BCr_S <-st_as_stars(BCr)
  write_stars(BCr_S,dsn=file.path(spatialOutDir,'BCr_S.tif'))
  raster::writeRaster(BCr, filename=BCr_file, format="GTiff", overwrite=TRUE)
  raster::writeRaster(ProvRast, filename=file.path(spatialOutDir,'ProvRast'), format="GTiff", overwrite=TRUE)
} else {
  BCr <- raster(BCr_file)
  ProvRast<-raster(file.path(spatialOutDir,'ProvRast.tif'))
  BCr_S <- read_stars(file.path(spatialOutDir,'BCr_S.tif'))
  BC <-readRDS('out/BC.rds')
}
