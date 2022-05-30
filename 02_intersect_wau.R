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

##################
# Options below depending on whether the layer is raster or vector

# Vector Processing Steps here: use if attribute based metrics are --------

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

# Raster Processing Steps here: --------
#  take raster layer and extract into WAUs

rast_element <- readRDS(file = paste0("tmp/", element, '_rast'))

extract_wau <- function(strata, raster_element){
  extract_df <- exact_extract(raster_element, strata, 'count', progress=TRUE, force_df=TRUE)
  colnames(extract_df)<-paste0(element,'_ha')
  LUT<- extract_df %>%
    mutate(aqua_id=as.numeric(rownames(extract_df)))
  return(LUT)
}

wau_w_layer<-extract_wau(wau_base, rast_element)

#Join strata and select criteria attributes data back to watersheds

wau_out <-wau_base %>%
  left_join(wau_w_layer, by='aqua_id')


