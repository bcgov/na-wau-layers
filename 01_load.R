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

source('header.R') #
source('packages.R') # load required packages

# Load basic watershed file

wau_base <- st_read("data/aqua_sfE.gpkg", crs=3005) %>%
  st_cast(to="POLYGON") %>%
  st_make_valid()


##################
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


# Raster Processing Steps here: use if metrics are area-based only --------


## Convert to ha BC format -------------------------------------------------

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
                   res = c(100,100), vals = 1)
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
  BC <-readRDS(BCr_file)
}

# convert new raster to ha BC format
new_layer_raster <- fasterize(new_layer, ProvRast, field="raster_value")
crs(new_layer_raster)<-prov_crs

saveRDS(new_layer_raster, file = paste0("tmp/", element, '_base-rast'))

write_stars(new_layer_raster, dsn=file.path(paste(out_dir, element, '.tif')), overwrite=TRUE)


# To do - create option to bring in file already in ha BC format ----------



