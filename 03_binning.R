# Copyright 2022 Province of British Columbia
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

#IN PROGRESS - moving things over to this file from former script

# Code to take area-based metrics and bin them - based on quantiles -------

wau_analysis <- st_read("data/wshd_w_elements.gpkg", crs=3005) %>%
  st_cast(to="MULTIPOLYGON") %>%
  st_make_valid() %>%
  st_drop_geometry()

# needs to be modified

new_layer_summary <- wau_working %>%
  filter(element > 0) %>%
  summarise(r_mean = signif(mean(element, 3)),
            r_med = signif(median(element, na.rm = TRUE), 3),
            r_20 = signif(quantile(element, prob=0.20, na.rm = TRUE), 3),
            r_40 = signif(quantile(element, prob=0.40, na.rm = TRUE), 3),
            r_60 = signif(quantile(element, prob=0.60, na.rm = TRUE), 3),
            r_80 = signif(quantile(element, prob=0.80, na.rm = TRUE), 3),
            r_95 = signif(quantile(element, prob=0.95, na.rm = TRUE), 3),
            r_min = signif(min(element, na.rm = TRUE), 3), #indicates this value is half lowest MDL
            r_max = signif(max(element, na.rm = TRUE), 3),
            r_n = length(element))


wau_ranking <- wau_working %>%
  mutate(paste0(element, "_rank") = case_when(
    element == 0 ~ 'None',
    element > 0 & element <= new_layer_summary$r_20 ~ 'Negligible',
    element > new_layer_summary$r_20 & element <= new_layer_summary$r_40 ~ 'Low',
    element > new_layer_summary$r_40 & element <= new_layer_summary$r_60 ~ 'Medium',
    element > new_layer_summary$r_60 & element <= new_layer_summary$r_80 ~ 'High',
    element > new_layer_summary$r_80 & element <= new_layer_summary$r_max ~ 'VeryHigh'
  ))


# IF RASTER, this is the last step
