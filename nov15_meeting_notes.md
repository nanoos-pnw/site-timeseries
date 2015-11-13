A conda environment for our use today:
```
conda create -n dmac_cmop_nov15 python=2.7 ipython-notebook requests 
  xray matplotlib seaborn 
  compliance-checker ioos_qartod cf_units
```
*I tried adding cfchecker, but it had conflicts with seaborn and xray*


netcdf 4 vs netcdf 3
classic netcdf 4 is the same as netcdf 3, but has compression (from HDF5)
thredds and erddap hide netcdf version and output netcdf 3 (or give you the option of 4 in ERDDAP)
