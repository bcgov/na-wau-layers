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

source('header.R')
source('packages.R')

# Load basic watershed file

wau_base <- st_read("data/aqua_sfE.gpkg", crs=3005) %>%
  st_cast(to="POLYGON") %>%
  st_make_valid()


##################
# Options below depending on whether the layer is raster or vector

##### Vector Processing Steps here: use if attribute based metrics are required

####   Load new layer, make sure info is correct in header.R


load_data <- function(data){
  output<- st_read(data) %>%
    rename_all(tolower) %>%
    st_make_valid()
  output
}

new_layer <- load_data(layer_file)


####   intersect layer with wau

intersect_pa <- function(input1, input2){
  input1 <- st_make_valid(input1)
  input2 <- st_make_valid(input2)
  output <- st_intersection(input1, input2) %>%
    st_make_valid() %>%
    st_collection_extract(type = "POLYGON") %>%
    mutate(polygon_id = seq_len(nrow(.)))
  output
}

wau_new_layer <- intersect_pa(wau_base, new_layer)


wau_layer_sum <- wau_new_layer %>%
  mutate(area = st_area(.),
         area =as.numeric(set_units(area, ha))) %>%
  st_set_geometry(NULL) %>%
  group_by(aqua_id, LOCAL_WATERSHED_CODE, ASSESSMENT_UNIT_GROUP, ASSESSMENT_UNIT_AREA_HA) %>%
  summarise(wau_area = sum(area)) %>%
  ungroup()


# save a copy to bring into analysis rmd

saveRDS(wau_layer_sum, file = paste0("tmp/", element, '_vect'))






### Extra code here for layers with multiple metrics, other than area-based




##### Raster Processing Steps here: use if metrics are area-based only

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

# convert to raster
new_layer_raster <- fasterize(new_layer, ProvRast, field="raster_value")
crs(new_layer_raster)<-prov_crs



saveRDS(new_layer_raster, file = paste0("tmp/", element, '_rast'))

write_stars(new_layer_raster, dsn=file.path(paste(out_dir, element, '.tif')), overwrite=TRUE)


