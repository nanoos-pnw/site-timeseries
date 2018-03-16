# NOTES ON UNDERSTANDING, CREATING AND USING NETCDF DSG FILES

- [CF DSG description](http://cfconventions.org/Data/cf-conventions/cf-conventions-1.6/build/cf-conventions.html#discrete-sampling-geometries). Official resource, but can seem fairly abstract.
- [NCEI NetCDF Templates v2.0](https://www.nodc.noaa.gov/data/formats/netcdf/v2.0/) Some additional, helpful descriptions and comparisons of the different options for organizing data for each DSG type (eg, for `timeSeries`). Includes sample netcdf files and corresponding CDL's.
- https://github.com/USGS-R/netcdf.dsg aims to implement *all* `timeSeries` DSG's, in R. Maintained by the USGS-CIDA group, a terrific team who also do Python.

## `pocean-core`

- https://github.com/pyoceans/pocean-core/
- Here's the implementation of the "OrthogonalMultidimensionalTimeseries" (om) `timeSeries` DSG: https://github.com/pyoceans/pocean-core/blob/master/pocean/dsg/timeseries/om.py. Other `timeSeries` DSG's (cm, im, ir) are currently not implemented; only stub modules have been created.
    - The `profile` DSG does implement [im array representation](https://github.com/pyoceans/pocean-core/blob/master/pocean/dsg/profile/im.py), as well as om. It may be a useful guide for what im for `timeSeries` DSG would look like.
- The best `pocean-core` example Jupyter notebook can be found in [IOOS Notebook Gallery](http://ioos.github.io/notebooks_demos/notebooks/2018-02-27-pocean-timeSeries-demo/), for `timeSeriesProfile`
- Filipe says that Kyle Wilcox may be working on an implementation that relies on `xarray`. It's not on master yet (and the `xarray` branch on the repo is pretty old), so if it exists it's somewhere else.


## NANOOS resources

- https://github.com/nanoos-pnw/site-timeseries (this repository)
- https://github.com/nanoos-pnw/NCEI-archiving

- [CMOP NCEI archive files, as organized in the NCEI THREDDS server](https://data.nodc.noaa.gov/thredds/catalog/ioos/nanoos/catalog.html). They're under a NANOOS "folder", as the subfolder "ohsucmop". The individual netcdf files are presented (each file encompassing one month or less, in one deployment of one instrument in one station); they have not been aggregated via ncML into logical groups (one deployment of one instrument in one station).
- Craig's "NDBC" long time series nc files (I'll provide links)
