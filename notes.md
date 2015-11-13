# NANOOS handling of long time series
11/12/2015. Messy notes and issues for discussion.

## Issues with changing deployment configurations

## Craig's nc file from NDBC
- See our email exchanges, "Example CF1.6 NetCDF file"; Craig sent out the email on July 21
- Which DSG pattern to use? Is a single pattern good for all use cases?
- Compare to my AAT ERDDAP DSG time series configurations and downloaded files
- Look at the results of my compliance-checker runs from August

## Python implementations

### xray and netcdf
- Have some simple [xray](http://xray.readthedocs.org) examples of writing nc DSG files with some standard attributes. See the [xray netcdf serialization page.](http://xray.readthedocs.org/en/stable/io.html#netcdf)
- Note: "By default, the file is saved as netCDF4 (assuming netCDF4-Python is installed). You can control the format and engine used to write the file with the format and engine arguments."

## THREDDS, ncml aggregation, ncml Python package
- [ncml @ github](https://github.com/ioos/ncml) -- [2014-Sept email from Rich](https://groups.google.com/d/msg/ioos_tech/uid-ZM3abgk/AIRBY6LUCrEJ)
- [Advice: THREDDS/TDS 4.5 (dev) or 4.3 (stable)? (2014 Sept)](https://groups.google.com/forum/#!topic/ioos_tech/FJsf8lVjvz4)

## IOOS compliance checker
- My tests on Craig's nc file. Reported on the same "Example CF1.6 NetCDF file" email thread Craig started
```
I ran two configurations only: cf "test", and lenient vs normal "criteria". Here's the statement for one of them:
compliance-checker --test=cf --criteria=lenient NDBC46050.nc > iooscompcheck_cf_lenient_NDBC46050.log
```
- My conda env for running compliance checker
- See also the CF Checker, http://puma.nerc.ac.uk/cgi-bin/cf-checker.pl

## NCEI (NODC/NCEI Templates, Archiving)
- https://github.com/ioos/cc-plugin-ncei
- http://www.nodc.noaa.gov/data/formats/netcdf/v1.1/

## My query to ioos_tech from 2014, and responses from PacIOOS, NERACOOS, etc
- [Handling changed station deployments in SOS and CF/CDM discrete geometry, 2014-Oct](https://groups.google.com/d/msg/ioos_tech/2vxZRxBhd90/BDdwPaFaCbMJ)

## NANOOS/APL infrastructure to use these data files
- From NVS
	- Will need "deployment properties" by time range; boils down to something like a platform_data_details version with start-and-end time periods (deployment)
- From [ERDDAP TableDAP datasets](http://data.nanoos.org/deverddap/tabledap/index.html)
	- [Sample TimeSeries DSG FeatureType.](http://data.nanoos.org/deverddap/tabledap/otnnepJDFDetects.html) Can download as netcdf file to examine nc structure, or just see the `.das` content at the bottom of the page, or in the dataset metadata link.
	- Paste my file paths to my ERDDAP configs

## OceanSITES Netcdf and metadata conventions
- See its information on [data access, data format manual, etc](http://www.oceansites.org/data/index.html)
- These files are NOT DSG, I think

### 11/2/2015 notes from GITHUB ISSUE (FOR REGISTRY) from ROB RAGSDALE, today
- [registry] OceanSITES Metadata Registration (#84). @amilan17  Could you check on the harvest status of the OceanSITES metadata URLs submitted on 10/30. They did not show up in the NDBC production WAF. Collection source list URL: https://www.ngdc.noaa.gov/docucomp/collectionSource/list?recordSetId=2604649&componentId=&serviceType=&serviceStatus=SUBMITTED&serviceUrl=&search=List+Collection+Sources
- Note at that NGDC Collection Source List one "catalog" entry per site, including these NVS and IPACOA relevant ones:
	- CCE (S. Calif):
		- http://dods.ndbc.noaa.gov/thredds/catalog/oceansites/DATA/CCE1/catalog.xml
		- http://dods.ndbc.noaa.gov/thredds/catalog/oceansites/DATA/CCE2/catalog.xml
	- PAPA:
		- http://dods.ndbc.noaa.gov/thredds/catalog/oceansites/DATA/PAPA/catalog.xml
		- http://dods.ndbc.noaa.gov/thredds/catalog/oceansites/DATA/PAPA/catalog.html
		- http://dods.ndbc.noaa.gov/thredds/catalog/oceansites/DATA_GRIDDED/PAPA/catalog.xml
- From there, I found the "user-friendly" THREDDS page for NDBC/OceanSites catalog:
	- http://dods.ndbc.noaa.gov/thredds/catalog/oceansites/catalog.html
	- Note the "DATA" vs "DATA_GRIDDED" organization / sub-catalogs
