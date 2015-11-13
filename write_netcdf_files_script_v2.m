close all
clear all

cd /home/server/pi/homes/crisien/nanoos_nvs/buoy_climatology/Wave_data/PNW/46050

%Specify X,Y,Z positions for 46050
Latitude=44.656;
Longitude=235.474;
depth=-1;
NDBC_ID = 0;

filenames = dir;
dir_list = strcat('46050h*.mat');
f = dir(dir_list);

for i = 1:length(f)-1   %load 1987:2014

    if i==1
        load(f(i,1).name)
        stdmet_array=stdmet;
    else
        load(f(i,1).name)
        stdmet_array(length(stdmet_array(:,1))+1:length(stdmet_array(:,1))+length(stdmet),:)=stdmet;        
    end
    
end

sst = stdmet_array(:,11);
sst(isnan(sst))=-9999;

time = datenum(1987,1,1,0,0,0)*24:1:datenum(2014,12,31,23,0,0)*24;

ref_time = datenum(1970,1,1,0,0,0)*24;

time = time-ref_time;

time_bounds = [time(:)-.5 time(:)+.5];
bnds =2;

%datestr((time(end)+datenum(1970,1,1,0,0,0)*24)/24)
%datestr((time_bounds(end-1:end)+datenum(1970,1,1,0,0,0)*24)/24)

dc = datestr(now,31);
dc = strcat(num2str(dc(1:10)),'T',num2str(dc(12:19)));
dc_hist = strcat('Created:_',num2str(dc(1:10)),'T',num2str(dc(12:19)),'. Version: 1.0');
dc_hist = strrep(dc_hist,'_',' ');

first_measurement = datestr((time(1)+datenum(1970,1,1,0,0,0)*24)/24,31);
first_measurement = strcat(num2str(first_measurement(1:10)),'T',num2str(first_measurement(12:19)));

last_measurement = datestr((time(end)+datenum(1970,1,1,0,0,0)*24)/24,31);
last_measurement = strcat(num2str(last_measurement(1:10)),'T',num2str(last_measurement(12:19)));

z_axis = length(time);

%Create .nc file
netcdf_filename = strcat('/home/server/pi/homes/crisien/nanoos_nvs/buoy_climatology/Wave_data/PNW/46050/NDBC46050.nc');
ncid = netcdf.create(netcdf_filename,'clobber');

% Define dimentions
TimeDimID = netcdf.defDim(ncid, 'time', z_axis);
Bnds = netcdf.defDim(ncid, 'bnds', 2);
station_nameDimID = netcdf.defDim(ncid, 'station_name', 1);
PosDimID = netcdf.defDim(ncid, 'position', 1);

% Set global attributes
VarID = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid, VarID, 'title', 'Hourly NDBC 46050 data');
netcdf.putAtt(ncid, VarID, 'publisher_name', 'Craig Risien');
netcdf.putAtt(ncid, VarID, 'publisher_email', 'crisien@coas.oregonstate.edu');
netcdf.putAtt(ncid, VarID, 'institution', 'Oregon State University, College of Earth, Ocean, and Atmospheric Sciences');
netcdf.putAtt(ncid, VarID, 'date_created', dc);
netcdf.putAtt(ncid, VarID, 'date_modified', dc);
netcdf.putAtt(ncid, VarID, 'history', dc_hist);
netcdf.putAtt(ncid, VarID, 'time_coverage_start', first_measurement);
netcdf.putAtt(ncid, VarID, 'time_coverage_end', last_measurement);
netcdf.putAtt(ncid, VarID, 'time_coverage_resolution', 'hourly averages');
netcdf.putAtt(ncid, VarID, 'geospatial_lat_min', 44.656);
netcdf.putAtt(ncid, VarID, 'geospatial_lat_max', 44.656);
netcdf.putAtt(ncid, VarID, 'geospatial_lat_units', 'degrees_north');
netcdf.putAtt(ncid, VarID, 'geospatial_lon_min', 235.474);
netcdf.putAtt(ncid, VarID, 'geospatial_lon_max', 235.474);
netcdf.putAtt(ncid, VarID, 'geospatial_lon_units', 'degrees_east');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_min', -1);
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_max', -1);
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_units', 'meters');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_resolution', 'point');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_positive', 'up');
netcdf.putAtt(ncid, VarID, 'keywords', 'sea surface temperature, ndbc, noaa');
netcdf.putAtt(ncid, VarID, 'keyword_vocabulary', 'GCMD');
netcdf.putAtt(ncid, VarID, 'Conventions', 'CF-1.6');
netcdf.putAtt(ncid, VarID, 'comments', 'no comment');
netcdf.putAtt(ncid, VarID, 'cdm_data_type', 'Station');
netcdf.putAtt(ncid, VarID, 'featureType', 'timeSeries');
netcdf.putAtt(ncid, VarID, 'data_type', 'NDBC time-series data');
netcdf.putAtt(ncid, VarID, 'area', 'North Pacific Ocean');
netcdf.putAtt(ncid, VarID, 'license', 'Follows NDBC standards. Data available free of charge. User assumes all risk for use of data. User must display citation in any publication or product using data.');
netcdf.putAtt(ncid, VarID, 'citation', 'These data were collected and made freely available by NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'acknowledgement', 'These data were collected and made freely available by NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'wmo_platform_code', '46050');
netcdf.putAtt(ncid, VarID, 'summary', 'Quality controlled NDBC Station data that have been repackaged and distributed by NANOOS');
netcdf.putAtt(ncid, VarID, 'naming_authority', 'NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'history', 'Quality controlled at NOAA NDBC');

% Define variables.
VarIdLatitude = netcdf.defVar(ncid, 'latitude' , 'float', PosDimID);
netcdf.putAtt(ncid, VarIdLatitude, 'units', 'degrees_north');
netcdf.putAtt(ncid, VarIdLatitude, 'long_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'standard_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'valid_min', 44.656);
netcdf.putAtt(ncid, VarIdLatitude, 'valid_max', 44.656);
netcdf.putAtt(ncid, VarIdLatitude, 'axis', 'Y');

VarIdLongitude = netcdf.defVar(ncid, 'longitude' , 'float', PosDimID);
netcdf.putAtt(ncid, VarIdLongitude, 'units', 'degrees_east');
netcdf.putAtt(ncid, VarIdLongitude, 'long_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'standard_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'valid_min', 235.474);
netcdf.putAtt(ncid, VarIdLongitude, 'valid_max', 235.474);
netcdf.putAtt(ncid, VarIdLongitude, 'axis', 'X');

VarIdTime = netcdf.defVar(ncid, 'time' , 'float', TimeDimID);
netcdf.putAtt(ncid, VarIdTime, 'units', 'hours since 1970-01-01');
netcdf.putAtt(ncid, VarIdTime, 'calendar', 'gregorian');
netcdf.putAtt(ncid, VarIdTime, 'long_name', 'time');
netcdf.putAtt(ncid, VarIdTime, 'standard_name', 'time');
netcdf.putAtt(ncid, VarIdTime, 'valid_min', time(1));
netcdf.putAtt(ncid, VarIdTime, 'valid_max', time(end));
netcdf.putAtt(ncid, VarIdTime, 'axis', 'T');
netcdf.putAtt(ncid, VarIdTime, 'bounds', 'time_bnds');

VarIdDepth = netcdf.defVar(ncid, 'depth' , 'float', PosDimID);
netcdf.putAtt(ncid, VarIdDepth, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepth, 'long_name', 'Depth of each measurement');
netcdf.putAtt(ncid, VarIdDepth, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepth, 'valid_min', -1);
netcdf.putAtt(ncid, VarIdDepth, 'valid_max', -1);
netcdf.putAtt(ncid, VarIdDepth, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepth, 'positive', 'up');

VarIdTS = netcdf.defVar(ncid, 'station_name' , 'int', station_nameDimID);
netcdf.putAtt(ncid, VarIdTS, 'long_name', 'station name');
netcdf.putAtt(ncid, VarIdTS, 'cf_role', 'timeseries_id');
netcdf.putAtt(ncid, VarIdTS, 'units', '1');

%Variable Bounds
VarIdTimeBds = netcdf.defVar(ncid, 'time_bnds' , 'float', [Bnds TimeDimID]);
netcdf.putAtt(ncid, VarIdTimeBds, 'units', 'hours since 1970-01-01');
netcdf.putAtt(ncid, VarIdTimeBds, 'long_name', 'time cell boundaries');

VarIdSSTemp = netcdf.defVar(ncid, 'sea_water_temperature', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdSSTemp, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdSSTemp, 'units', 'degree_Celsius');
netcdf.putAtt(ncid, VarIdSSTemp, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdSSTemp, 'long_name', 'Hourly Sea Water Temperature');
netcdf.putAtt(ncid, VarIdSSTemp, 'standard_name', 'sea_water_temperature');
netcdf.putAtt(ncid, VarIdSSTemp, 'coordinates', 'longitude latitude time depth');
netcdf.putAtt(ncid, VarIdSSTemp, 'sensor_mount', 'mounted on mooring bridal');
netcdf.putAtt(ncid, VarIdSSTemp, 'valid_min', -2);
netcdf.putAtt(ncid, VarIdSSTemp, 'valid_max', 30);

netcdf.endDef(ncid)  % Leave define mode.

% Now store the data
netcdf.putVar(ncid, VarIdLatitude  ,Latitude);
netcdf.putVar(ncid, VarIdLongitude  ,Longitude);
netcdf.putVar(ncid, VarIdTime  ,time);
netcdf.putVar(ncid, VarIdDepth  ,depth);
netcdf.putVar(ncid, VarIdTS ,NDBC_ID);
netcdf.putVar(ncid, VarIdTimeBds  ,time_bounds);
netcdf.putVar(ncid, VarIdSSTemp  ,sst)

% Close the file. Finished.
netcdf.sync(ncid)
netcdf.close(ncid)
