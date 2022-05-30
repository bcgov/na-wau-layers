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

wau_analysis <- st_read("data/wshd_w_elements.gpkg", crs=3005) %>%
  st_cast(to="MULTIPOLYGON") %>%
  st_make_valid() %>%
  st_drop_geometry()

# Create a log transformation column to test
# Due to data type, most will have skewed right distributions (long right tail)

# This example is with old-growth layer - should be done for each layer in the wau_analysis
# I decided to take out the 0's and make them none.

wau_working <- wau_analysis %>%
  mutate(og_perc = round(OG_ha/ASSESSMENT_UNIT_AREA_HA*100, 2)) %>%
  mutate(log_OG = ifelse(OG_ha > 0, log(OG_ha), NA))

new_layer_summary <- wau_working %>%
  filter(OG_ha > 0) %>%
  summarise(r_mean = signif(mean(OG_ha, 3)),
            r_med = signif(median(OG_ha, na.rm = TRUE), 3),
            r_20 = signif(quantile(OG_ha, prob=0.20, na.rm = TRUE), 3),
            r_40 = signif(quantile(OG_ha, prob=0.40, na.rm = TRUE), 3),
            r_60 = signif(quantile(OG_ha, prob=0.60, na.rm = TRUE), 3),
            r_80 = signif(quantile(OG_ha, prob=0.80, na.rm = TRUE), 3),
            r_95 = signif(quantile(OG_ha, prob=0.95, na.rm = TRUE), 3),
            r_min = signif(min(OG_ha, na.rm = TRUE), 3), #indicates this value is half lowest MDL
            r_max = signif(max(OG_ha, na.rm = TRUE), 3),
            r_n = length(OG_ha))

new_layer_summary_log<- wau_working %>%
  summarise(r_mean = signif(mean(log_OG, 3)),
            r_med = signif(median(log_OG, na.rm = TRUE), 3),
            r_20 = signif(quantile(log_OG, prob=0.20, na.rm = TRUE), 3),
            r_40 = signif(quantile(log_OG, prob=0.40, na.rm = TRUE), 3),
            r_60 = signif(quantile(log_OG, prob=0.60, na.rm = TRUE), 3),
            r_80 = signif(quantile(log_OG, prob=0.80, na.rm = TRUE), 3),
            r_95 = signif(quantile(log_OG, prob=0.95, na.rm = TRUE), 3),
            r_min = signif(min(log_OG, na.rm = TRUE), 3), #indicates this value is half lowest MDL
            r_max = signif(max(log_OG, na.rm = TRUE), 3),
            r_n = length(log_OG))

#hist - raw data
dist<-ggplot(data=wau_working) +
  geom_histogram(mapping = aes(x=OG_ha), binwidth = 50)
dist

# hist - log data
dist_log<-ggplot(data=wau_working) +
  geom_histogram(mapping = aes(x=log_OG), binwidth = 0.1)
dist_log

#qq plot - normality test
ggqqplot(wau_working$log_OG)

#normality-test
ks.test(wau_working$log_OG, "pnorm", sd=sd(wau_working$log_OG))


#Classify based on percentiles
wau_ranking <- wau_working %>%
  mutate(og_rank = case_when(
    OG_ha == 0 ~ 'None',
    OG_ha > 0 & OG_ha <= new_layer_summary$r_20 ~ 'Negligible',
    OG_ha > new_layer_summary$r_20 & OG_ha <= new_layer_summary$r_40 ~ 'Low',
    OG_ha > new_layer_summary$r_40 & OG_ha <= new_layer_summary$r_60 ~ 'Medium',
    OG_ha > new_layer_summary$r_60 & OG_ha <= new_layer_summary$r_80 ~ 'High',
    OG_ha > new_layer_summary$r_80 & OG_ha <= new_layer_summary$r_max ~ 'VeryHigh'
  ),
  og_rank_log = case_when(
    OG_ha == 0 ~ 'None',
    log_OG >= new_layer_summary_log$r_min & log_OG <= new_layer_summary_log$r_20 ~ 'Negligible',
    log_OG > new_layer_summary_log$r_20 & log_OG <= new_layer_summary_log$r_40 ~ 'Low',
    log_OG > new_layer_summary_log$r_40 & log_OG <= new_layer_summary_log$r_60 ~ 'Medium',
    log_OG > new_layer_summary_log$r_60 & log_OG <= new_layer_summary_log$r_80 ~ 'High',
    log_OG > new_layer_summary_log$r_80 & log_OG <= new_layer_summary_log$r_max ~ 'VeryHigh'
  ),
  column_match = if_else(og_rank == og_rank_log, "Match", "No")) %>%
  select(aqua_id:NATURAL_LANDBASE_HA, c(OG_ha, OG_haclass, OG_haclassN, og_perc, log_OG, og_rank, og_rank_log, column_match))

#OG_haClass, OG_haclassN were previously set - I included them just for comparison sake

write.csv(wau_ranking, "out/wau_ranking_og_test.csv")


# next step is to combine









