function write_nc_ndbc(id,lat,lon,sensor_hgts)
 
%Usage: write_nc_ndbc(46050,44.656,124.526,[-0.6 0 0 4 5])

Latitude = lat;
Longitude = (lon.*-1)+360;
depth_sst = sensor_hgts(1);
depth_wav = sensor_hgts(2);
depth_press = sensor_hgts(3);
depth_atmp = sensor_hgts(4);
depth_wnd = sensor_hgts(5);
NDBC_ID = id;

if NDBC_ID == 46022 || NDBC_ID == 46027 || NDBC_ID == 46213, 
    data_dir = strcat('cd-','/home/server/pi/homes/crisien/nanoos_nvs/buoy_climatology/Wave_data/California/',num2str(NDBC_ID));
    data_dir = strrep(data_dir,'-',' ')
    eval(data_dir);
else
    data_dir = strcat('cd-','/home/server/pi/homes/crisien/nanoos_nvs/buoy_climatology/Wave_data/PNW/',num2str(NDBC_ID));
    data_dir = strrep(data_dir,'-',' ')
    eval(data_dir);
end

filenames = dir;
dir_list = strcat(num2str(NDBC_ID),'*.mat');
f = dir(dir_list);

%load all data
for i = 1:length(f)

    if i==1
        load(f(i,1).name)
        stdmet_array=stdmet;
    else
        load(f(i,1).name)
        stdmet_array(length(stdmet_array(:,1))+1:length(stdmet_array(:,1))+length(stdmet),:)=stdmet;        
    end
    
end

stdmet_array(isnan(stdmet_array)) = -9999;

wdir = stdmet_array(:,2);  %deg
wspd = stdmet_array(:,3);  %m/s
wgst = stdmet_array(:,4);  %m/s
whgt = stdmet_array(:,5);  %m
dwpd = stdmet_array(:,6);  %sec
awpd = stdmet_array(:,7);  %sec
mwdir = stdmet_array(:,8);   %deg
press = stdmet_array(:,9).*100;   %Pa
atmp = stdmet_array(:,10)+273.15; %K
sst = stdmet_array(:,11)+273.15;   %K

%Create time array
start_year = f(1,1).name;
current_year = f(end,1).name;
time = datenum(str2num(start_year(7:10)),1,1,0,0,0)*24:1:datenum(str2num(current_year(7:10)),12,31,23,0,0)*24;

time = time-datenum(1970,1,1,0,0,0)*24;

time_bounds = [time(:)-.5 time(:)+.5];
bnds = 2;

%Time Check
%datestr((time(1)+datenum(1970,1,1,0,0,0)*24)/24)
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
netcdf_filename = strcat('/home/server/pi/homes/crisien/nanoos_nvs/buoy_climatology/netcdf_files/NDBC',num2str(NDBC_ID),'.nc');
ncid = netcdf.create(netcdf_filename,'clobber');

% Define dimentions
TimeDimID = netcdf.defDim(ncid, 'time', z_axis);
Bnds = netcdf.defDim(ncid, 'bnds', 2);

netcdf_title = strcat('Hourly_NDBC_',num2str(NDBC_ID),'_data');
netcdf_title = strrep(netcdf_title,'_',' ');

% Set global attributes
VarID = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid, VarID, 'title', netcdf_title);
netcdf.putAtt(ncid, VarID, 'publisher_name', 'Craig Risien');
netcdf.putAtt(ncid, VarID, 'publisher_email', 'crisien@coas.oregonstate.edu');
netcdf.putAtt(ncid, VarID, 'institution', 'Oregon State University, College of Earth, Ocean, and Atmospheric Sciences');
netcdf.putAtt(ncid, VarID, 'date_created', dc);
netcdf.putAtt(ncid, VarID, 'date_modified', dc);
netcdf.putAtt(ncid, VarID, 'history', dc_hist);
netcdf.putAtt(ncid, VarID, 'time_coverage_start', first_measurement);
netcdf.putAtt(ncid, VarID, 'time_coverage_end', last_measurement);
netcdf.putAtt(ncid, VarID, 'time_coverage_resolution', 'hourly averages');
netcdf.putAtt(ncid, VarID, 'geospatial_lat_min', Latitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lat_max', Latitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lat_units', 'degrees_north');
netcdf.putAtt(ncid, VarID, 'geospatial_lon_min', Longitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lon_max', Longitude);
netcdf.putAtt(ncid, VarID, 'geospatial_lon_units', 'degrees_east');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_min', depth_sst);
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_max', depth_wnd);
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_units', 'meters');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_resolution', 'point');
netcdf.putAtt(ncid, VarID, 'geospatial_vertical_positive', 'up');
netcdf.putAtt(ncid, VarID, 'keywords', 'ndbc, noaa, nanoos, sea surface temperature, wind speed, wind direction, wave height, wave period, wave direction, air temperature, barometric pressure');
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
netcdf.putAtt(ncid, VarID, 'wmo_platform_code', num2str(NDBC_ID));
netcdf.putAtt(ncid, VarID, 'summary', 'Quality controlled NDBC Station data that have been repackaged and distributed by NANOOS');
netcdf.putAtt(ncid, VarID, 'naming_authority', 'NOAA NDBC');
netcdf.putAtt(ncid, VarID, 'history', 'Quality controlled at NOAA NDBC');

% Define variables.
VarIdLatitude = netcdf.defVar(ncid, 'latitude' , 'float', []);
%VarIdLatitude = netcdf.defVar(ncid, 'latitude' , 'float', PosDimID);
netcdf.putAtt(ncid, VarIdLatitude, 'units', 'degrees_north');
netcdf.putAtt(ncid, VarIdLatitude, 'long_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'standard_name', 'latitude');
netcdf.putAtt(ncid, VarIdLatitude, 'valid_min', Latitude);
netcdf.putAtt(ncid, VarIdLatitude, 'valid_max', Latitude);
netcdf.putAtt(ncid, VarIdLatitude, 'axis', 'Y');

VarIdLongitude = netcdf.defVar(ncid, 'longitude' , 'float', []);
netcdf.putAtt(ncid, VarIdLongitude, 'units', 'degrees_east');
netcdf.putAtt(ncid, VarIdLongitude, 'long_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'standard_name', 'longitude');
netcdf.putAtt(ncid, VarIdLongitude, 'valid_min', Longitude);
netcdf.putAtt(ncid, VarIdLongitude, 'valid_max', Longitude);
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

VarIdDepthSST = netcdf.defVar(ncid, 'depth_sst' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthSST, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthSST, 'long_name', 'Depth of SST measurements');
netcdf.putAtt(ncid, VarIdDepthSST, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthSST, 'valid_min', depth_sst);
netcdf.putAtt(ncid, VarIdDepthSST, 'valid_max', depth_sst);
netcdf.putAtt(ncid, VarIdDepthSST, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthSST, 'positive', 'up');

VarIdDepthATMP = netcdf.defVar(ncid, 'depth_atmp' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthATMP, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthATMP, 'long_name', 'Height of air temperature measurements');
netcdf.putAtt(ncid, VarIdDepthATMP, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthATMP, 'valid_min', depth_atmp);
netcdf.putAtt(ncid, VarIdDepthATMP, 'valid_max', depth_atmp);
netcdf.putAtt(ncid, VarIdDepthATMP, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthATMP, 'positive', 'up');

VarIdDepthWND = netcdf.defVar(ncid, 'depth_wnd' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthWND, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthWND, 'long_name', 'Height of wind measurements');
netcdf.putAtt(ncid, VarIdDepthWND, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthWND, 'valid_min', depth_wnd);
netcdf.putAtt(ncid, VarIdDepthWND, 'valid_max', depth_wnd);
netcdf.putAtt(ncid, VarIdDepthWND, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthWND, 'positive', 'up');

VarIdDepthPRESS = netcdf.defVar(ncid, 'depth_press' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthPRESS, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'long_name', 'Height of barometric pressure measurements');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'valid_min', depth_press);
netcdf.putAtt(ncid, VarIdDepthPRESS, 'valid_max', depth_press);
netcdf.putAtt(ncid, VarIdDepthPRESS, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthPRESS, 'positive', 'up');

VarIdDepthWAV = netcdf.defVar(ncid, 'depth_wav' , 'float', []);
netcdf.putAtt(ncid, VarIdDepthWAV, 'units', 'meters');
netcdf.putAtt(ncid, VarIdDepthWAV, 'long_name', 'Height of wave measurements');
netcdf.putAtt(ncid, VarIdDepthWAV, 'standard_name', 'depth');
netcdf.putAtt(ncid, VarIdDepthWAV, 'valid_min', depth_wav);
netcdf.putAtt(ncid, VarIdDepthWAV, 'valid_max', depth_wav);
netcdf.putAtt(ncid, VarIdDepthWAV, 'axis', 'Z');
netcdf.putAtt(ncid, VarIdDepthWAV, 'positive', 'up');

VarIdTS = netcdf.defVar(ncid, 'station_name' , 'int', []);
netcdf.putAtt(ncid, VarIdTS, 'long_name', 'station name');
netcdf.putAtt(ncid, VarIdTS, 'cf_role', 'timeseries_id');
netcdf.putAtt(ncid, VarIdTS, 'units', '1');

%Variable Bounds
VarIdTimeBds = netcdf.defVar(ncid, 'time_bnds' , 'float', [Bnds TimeDimID]);
netcdf.putAtt(ncid, VarIdTimeBds, 'units', 'hours since 1970-01-01');
netcdf.putAtt(ncid, VarIdTimeBds, 'long_name', 'time cell boundaries');
netcdf.putAtt(ncid, VarIdTimeBds, 'calendar', 'gregorian');

VarIdSSTemp = netcdf.defVar(ncid, 'sea_water_temperature', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdSSTemp, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdSSTemp, 'units', 'K');
netcdf.putAtt(ncid, VarIdSSTemp, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdSSTemp, 'long_name', 'Hourly Sea Water Temperature');
netcdf.putAtt(ncid, VarIdSSTemp, 'standard_name', 'sea_water_temperature');
netcdf.putAtt(ncid, VarIdSSTemp, 'coordinates', 'longitude latitude time depth_sst');
netcdf.putAtt(ncid, VarIdSSTemp, 'sensor_mount', 'mounted on mooring bridal');
netcdf.putAtt(ncid, VarIdSSTemp, 'valid_min', -2+273.15);
netcdf.putAtt(ncid, VarIdSSTemp, 'valid_max', 30+273.15);

VarIdATemp = netcdf.defVar(ncid, 'air_temperature', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdATemp, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdATemp, 'units', 'K');
netcdf.putAtt(ncid, VarIdATemp, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdATemp, 'long_name', 'Hourly Air Temperature');
netcdf.putAtt(ncid, VarIdATemp, 'standard_name', 'air_temperature');
netcdf.putAtt(ncid, VarIdATemp, 'coordinates', 'longitude latitude time depth_atmp');
netcdf.putAtt(ncid, VarIdATemp, 'sensor_mount', 'mounted on the buoy tower');
netcdf.putAtt(ncid, VarIdATemp, 'valid_min', -30+273.15);
netcdf.putAtt(ncid, VarIdATemp, 'valid_max', 30+273.15);

VarIdPress = netcdf.defVar(ncid, 'air_pressure', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdPress, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdPress, 'units', 'Pa');
netcdf.putAtt(ncid, VarIdPress, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdPress, 'long_name', 'Hourly Air Pressure');
netcdf.putAtt(ncid, VarIdPress, 'standard_name', 'air_pressure_at_sea_level');
netcdf.putAtt(ncid, VarIdPress, 'coordinates', 'longitude latitude time depth_press');
netcdf.putAtt(ncid, VarIdPress, 'sensor_mount', 'mounted on the buoy tower');
netcdf.putAtt(ncid, VarIdPress, 'valid_min', 95000);
netcdf.putAtt(ncid, VarIdPress, 'valid_max', 105000);

VarIdWSpd = netcdf.defVar(ncid, 'wind_speed', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWSpd, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWSpd, 'units', 'm s-1');
netcdf.putAtt(ncid, VarIdWSpd, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWSpd, 'long_name', 'Hourly Wind Speed');
netcdf.putAtt(ncid, VarIdWSpd, 'standard_name', 'wind_speed');
netcdf.putAtt(ncid, VarIdWSpd, 'coordinates', 'longitude latitude time depth_wnd');
netcdf.putAtt(ncid, VarIdWSpd, 'sensor_mount', 'mounted on the buoy tower');
netcdf.putAtt(ncid, VarIdWSpd, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWSpd, 'valid_max', 60);

VarIdWSpdG = netcdf.defVar(ncid, 'wind_speed_gust', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWSpdG, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWSpdG, 'units', 'm s-1');
netcdf.putAtt(ncid, VarIdWSpdG, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWSpdG, 'long_name', 'Hourly Wind Speed Gust');
netcdf.putAtt(ncid, VarIdWSpdG, 'standard_name', 'wind_speed_of_gust');
netcdf.putAtt(ncid, VarIdWSpdG, 'coordinates', 'longitude latitude time depth_wnd');
netcdf.putAtt(ncid, VarIdWSpdG, 'sensor_mount', 'mounted on the buoy tower');
netcdf.putAtt(ncid, VarIdWSpdG, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWSpdG, 'valid_max', 60);

VarIdWDir = netcdf.defVar(ncid, 'wind_direction', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWDir, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWDir, 'units', 'degree');
netcdf.putAtt(ncid, VarIdWDir, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWDir, 'long_name', 'Hourly Wind Direction');
netcdf.putAtt(ncid, VarIdWDir, 'standard_name', 'wind_from_direction');
netcdf.putAtt(ncid, VarIdWDir, 'coordinates', 'longitude latitude time depth_wnd');
netcdf.putAtt(ncid, VarIdWDir, 'sensor_mount', 'mounted on the buoy tower');
netcdf.putAtt(ncid, VarIdWDir, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWDir, 'valid_max', 360);

VarIdWHGT = netcdf.defVar(ncid, 'significant_wave_height', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWHGT, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWHGT, 'units', 'm');
netcdf.putAtt(ncid, VarIdWHGT, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWHGT, 'long_name', 'Hourly Significant Height of Wind and Swell Waves');
netcdf.putAtt(ncid, VarIdWHGT, 'standard_name', 'sea_surface_wave_significant_height');
netcdf.putAtt(ncid, VarIdWHGT, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdWHGT, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdWHGT, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWHGT, 'valid_max', 20);

VarIdWAPd = netcdf.defVar(ncid, 'average_wave_period', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWAPd, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWAPd, 'units', 's');
netcdf.putAtt(ncid, VarIdWAPd, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWAPd, 'long_name', 'Hourly Average Wave Period');
netcdf.putAtt(ncid, VarIdWAPd, 'standard_name', 'average_wave_period');
netcdf.putAtt(ncid, VarIdWAPd, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdWAPd, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdWAPd, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWAPd, 'valid_max', 30);

VarIdWDPd = netcdf.defVar(ncid, 'dominant_wave_period', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWDPd, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWDPd, 'units', 's');
netcdf.putAtt(ncid, VarIdWDPd, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWDPd, 'long_name', 'Hourly Dominant Wave Period');
netcdf.putAtt(ncid, VarIdWDPd, 'standard_name', 'dominant_wave_period');
netcdf.putAtt(ncid, VarIdWDPd, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdWDPd, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdWDPd, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWDPd, 'valid_max', 30);

VarIdWDir = netcdf.defVar(ncid, 'mean_wave_direction', 'float', [TimeDimID]);
netcdf.putAtt(ncid, VarIdWDir, '_FillValue', single(-9999));
netcdf.putAtt(ncid, VarIdWDir, 'units', 'degree');
netcdf.putAtt(ncid, VarIdWDir, 'cell_methods', 'time: mean (interval: 1 hour comment: time indicates center hour)');
netcdf.putAtt(ncid, VarIdWDir, 'long_name', 'Hourly Mean Wave Direction');
netcdf.putAtt(ncid, VarIdWDir, 'standard_name', 'sea_surface_wave_from_direction');
netcdf.putAtt(ncid, VarIdWDir, 'coordinates', 'longitude latitude time depth_wav');
netcdf.putAtt(ncid, VarIdWDir, 'sensor_mount', 'mounted in the buoy');
netcdf.putAtt(ncid, VarIdWDir, 'valid_min', 0);
netcdf.putAtt(ncid, VarIdWDir, 'valid_max', 360);

netcdf.endDef(ncid)  % Leave define mode.

% Now store the data
netcdf.putVar(ncid, VarIdLatitude  ,Latitude);
netcdf.putVar(ncid, VarIdLongitude  ,Longitude);
netcdf.putVar(ncid, VarIdTime  ,time);
netcdf.putVar(ncid, VarIdDepthSST  ,depth_sst);
netcdf.putVar(ncid, VarIdDepthATMP  ,depth_atmp);
netcdf.putVar(ncid, VarIdDepthWND  ,depth_wnd);
netcdf.putVar(ncid, VarIdDepthPRESS  ,depth_press);
netcdf.putVar(ncid, VarIdDepthWAV  ,depth_wav);
netcdf.putVar(ncid, VarIdTS ,NDBC_ID);
netcdf.putVar(ncid, VarIdTimeBds  ,time_bounds);
netcdf.putVar(ncid, VarIdSSTemp  ,sst);
netcdf.putVar(ncid, VarIdATemp  ,atmp);
netcdf.putVar(ncid, VarIdPress  ,press);
netcdf.putVar(ncid, VarIdWSpd  ,wspd);
netcdf.putVar(ncid, VarIdWSpdG  ,wgst);
netcdf.putVar(ncid, VarIdWDir  ,wdir);
netcdf.putVar(ncid, VarIdWHGT  ,whgt);
netcdf.putVar(ncid, VarIdWAPd  ,awpd);
netcdf.putVar(ncid, VarIdWDPd  ,dwpd);
netcdf.putVar(ncid, VarIdWDir  ,mwdir);

% Close the file. Finished.
netcdf.sync(ncid)
netcdf.close(ncid)

cd /home/server/pi/homes/crisien/nanoos_nvs/buoy_climatology
