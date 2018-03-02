# NOTES ON UNDERSTANDING, CREATING AND USING NETCDF DSG FILES

- [CF DSG description](http://cfconventions.org/Data/cf-conventions/cf-conventions-1.6/build/cf-conventions.html#discrete-sampling-geometries). Official resource, but can seem fairly abstract.
- [NCEI NetCDF Templates v2.0](https://www.nodc.noaa.gov/data/formats/netcdf/v2.0/) Some additional, helpful descriptions and comparisons of the different options for organizing data for each DSG type (eg, for `timeSeries`). Includes sample netcdf files and corresponding CDL's.
- https://github.com/USGS-R/netcdf.dsg aims to implement *all* `timeSeries` DSG's, in R. Maintained by the USGS-CIDA group, a terrific team who also do Python.

## `pocean-core`

- https://github.com/pyoceans/pocean-core/
- Here's the implementation of the "OrthogonalMultidimensionalTimeseries" (om) `timeSeries` DSG: https://github.com/pyoceans/pocean-core/blob/master/pocean/dsg/timeseries/om.py. Other `timeSeries` DSG's (cm, im, ir) are currently not implemented; only stub modules have been created.
- The best `pocean-core` example Jupyter notebook can be found in [IOOS Notebook Gallery](http://ioos.github.io/notebooks_demos/notebooks/2018-02-27-pocean-timeSeries-demo/), for `timeSeriesProfile`
- Note that apparenlty Kyle Wilcox is working on an implementation that relies on `xarray`. It's not on master yet, so it must be on Kyle's fork or on a branch.


## NANOOS resources

- https://github.com/nanoos-pnw/site-timeseries
- https://github.com/nanoos-pnw/NCEI-archiving
- CMOP NCEI archive files (I'll provide links to some of the files)
- Craig's "NDBC" long time series nc files (I'll provide links)
