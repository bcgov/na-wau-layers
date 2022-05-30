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

# Purpose of code: is to take raster layer and extract into WAUs

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


