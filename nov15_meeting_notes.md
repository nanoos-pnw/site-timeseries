- A conda environment for our use today:
```bash
conda create -n dmac_cmop_nov15 python=2.7 ipython-notebook requests xray matplotlib seaborn compliance-checker ioos_qartod cf_units
# I tried adding cfchecker, but it had conflicts with seaborn and xray
```
- See [notes.md](notes.md) for notes from Craig regarding compliance-checker results
- netcdf 4 vs netcdf 3
  - classic netcdf 4 is the same as netcdf 3, but has compression (from HDF5)
  - thredds and erddap hide netcdf version and output netcdf 3 (or give you the option of 4 in ERDDAP)
- Notes from the board:
  1. goals:
    - NCEI archiving
    - NVS long ts
    - NANOOS and  institutional TDS/ERDDAP data access
    - QARTOD
  2. technical issues, targets:
    - speed
    - fidelity
    - flexible metadata bare minimum <-> complete (NVS/ERDDAP requirement is bare minimum; NCEI requirement is higher completeness)
- netcdf(3)
- OSG
- shared code as much as possible (python)
- OceanSITES file structure
- NCEI SECOORA example file: http://data.nodc.noaa.gov/thredds/dodsC/ioos/secoora/usf.bcp.ngwlms/usf.bcp.ngwlms_2015_02_01_18.nc.html
