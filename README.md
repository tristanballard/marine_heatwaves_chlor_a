# marine_heatwaves_chlor_a
Extracts MODIS chlorophyll estimates during ocean heat waves

This project tries to look at how remotely sensed (MODIS satellite) chlorophyll-a changes during a marine heat wave, defined here as 3 or more consecutive days with 'above normal' temperature. One hypothesis would be that the warm temperatures initially stimulate a bloom but eventually lead to a decrease in phytoplankton activity as nutrients are depleted. Final results are not available, so this preliminary code should be used with caution. Note also due to the large file size (high resolution satellite data), computation requires access to a good cluster, or patience.

Specifics for the heat wave definition are in 'Perkins and Alexander, 2013. On the measurement of heatwaves'. If the project is to be resumed, there are new metrics created specifically for marine heat waves to potentially consider instead. 

Data are not included here due to size limits but can be downloaded freely online (MODIS daily chlor_a and sst).

threshold.modis.p1.R and threshold.modis.p2.R Compute the heatwave metric and extract the relevant chlorophyll data.
duration.R looks at chlorophyll data for marine heat waves of different duration.


