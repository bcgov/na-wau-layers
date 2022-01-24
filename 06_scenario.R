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



### EXTRA CODE ##### For combining columns for future scenarios
mutate(Rank=case_when(
  (Low>0 & Low<=3) & Medium==0 & High==0 & VHigh==0 ~ 'Low',
  (Low>=0 & Medium>0 & Medium<=2 & High==0 & VHigh==0) | (Low>=4 & Medium==2 & High==0 & VHigh==0) ~ 'Medium',
  (Low>=0 & Medium>=0 & High==1 & VHigh==0) | (Low>=0 & Medium>=3 & High==0 & VHigh==0) |
    (Low==2 & Medium==2 & High==0 & VHigh==0) | (Low>=3 & Medium ==1 & High==0 & VHigh==0) ~ 'High',
  (Low>=0 & Medium>=0 & High>=0 & VHigh>=1) | (Low>=0 & Medium>=2 & High==1 & VHigh==0) |
    (Low>=0 & Medium>=0 & High>=2 & VHigh==0) ~ 'VHigh',
  (Low==0 & Medium==0 & High==0 & VHigh==0 ~ 'Negligible' )
))
