% scr_merge_gridded_glider_and_acoustic_data.m
% This script merges the data from the glider and the acoustics after processing
% It will need to be generalized or turned into a function.

% Load the data that was saved from the scr_load_glider_and_acoustic_data.m
% You will have to do this for each frequency

load('C:\Work\AMLR01\export_1x1\Matlab_output_merge\AMLR01_2018_1x1m_67khz_250m.mat');

qc = mod(avg_profile_num,1);  % Make profiles either 0 or 0.5
gd_prfile_idx = find(qc==0);  % Find profiles that are whole numbers (dives and climbs)
 
gridded_glider_abc = struct(); % Create an empty structure 

% Use only the dive and climb profiles
gridded_glider_abc.gd_prfl_abc = prfl_abc(:,gd_prfile_idx);     
gridded_glider_abc.num_pings_profil_gd = num_pings_profil(gd_prfile_idx);
gridded_glider_abc.avg_profile_num_gd = avg_profile_num(gd_prfile_idx) ;
gridded_glider_abc.avg_time_gd = avg_time(gd_prfile_idx);
gridded_glider_abc.avg_lat_gd = avg_lat(gd_prfile_idx);
gridded_glider_abc.avg_lon_gd = avg_lon(gd_prfile_idx);
gridded_glider_abc.zbins_gd = zbins;

bd_bottom = find(max(log10(gridded_glider_abc.gd_prfl_abc(400:end,:)))>-5); % Find large abc values that could be accidental bottom integration

abc = gridded_glider_abc.gd_prfl_abc;
abc(400:end,bd_bottom) = NaN;

gridded_glider_abc.ABC = abc; % These are the gridded ABC to be used in analyses

 %%% Now find profiles that are linked between glider and azfp
% was from scr_collapse NaN Profiles
prfl_nan =~ isnan(data_gridded.salinity');
nan_sum = sum(prfl_nan);
nan_idx = find(nan_sum>3);

% new profile data
new_data_gridded.depth = data_gridded.depth;
new_data_gridded.profile_index = data_gridded.profile_index(nan_idx);
new_data_gridded.time = data_gridded.time(nan_idx);
new_data_gridded.longitude = data_gridded.longitude(nan_idx) ;
new_data_gridded.latitude = data_gridded.latitude(nan_idx) ;
new_data_gridded.backscatter_700 = data_gridded.backscatter_700(nan_idx,:);
new_data_gridded.cdom = data_gridded.cdom(nan_idx,:);
new_data_gridded.chlorophyll = data_gridded.chlorophyll(nan_idx,:);
new_data_gridded.conductivity = data_gridded.conductivity(nan_idx,:);
new_data_gridded.density = data_gridded.density(nan_idx,:);
new_data_gridded.oxygen_concentration = data_gridded.oxygen_concentration(nan_idx,:);
new_data_gridded.oxygen_saturation = data_gridded.oxygen_saturation(nan_idx,:);
new_data_gridded.pressure = data_gridded.pressure(nan_idx,:);
new_data_gridded.salinity = data_gridded.salinity(nan_idx,:);
new_data_gridded.temperature = data_gridded.temperature(nan_idx,:);

 %%%%%
% Find the neartest time in glider data that is closest to the acoustic time
IND = nearestpoint(gridded_glider_abc.avg_time_gd, epoch2datenum(new_data_gridded.time));
% add glider science data to the acoustic data 
gridded_glider_abc.glider_time = new_data_gridded.time(IND);  % Time
gridded_glider_abc.glider_longitude = new_data_gridded.longitude(IND); % Longitude
gridded_glider_abc.glider_latitude = new_data_gridded.latitude(IND); % Latitude
gridded_glider_abc.glider_prf_index = new_data_gridded.profile_index(IND); % Profile index
%gridded_AZFP_ABC.glider_depth = new_data_gridded.depth(IND)
gridded_glider_abc.glider_depth = new_data_gridded.depth; % Depth
gridded_glider_abc.glider_backscatter_700 = new_data_gridded.backscatter_700(IND,:)'; % Backscatter
gridded_glider_abc.glider_cdom = new_data_gridded.cdom(IND,:)'; % CDOM
gridded_glider_abc.glider_chlorophyll = new_data_gridded.chlorophyll(IND,:)'; % Chlorophyll
gridded_glider_abc.glider_density = new_data_gridded.density(IND,:)'; 
gridded_glider_abc.glider_oxygen_concentration = new_data_gridded.oxygen_concentration(IND,:)'; % Oxygen concentration
gridded_glider_abc.glider_oxygen_saturation = new_data_gridded.oxygen_saturation(IND,:)'; % Oxygen saturation
gridded_glider_abc.glider_pressure = new_data_gridded.pressure(IND,:)'; % Pressure from the CTD
gridded_glider_abc.glider_salinity = new_data_gridded.salinity(IND,:)'; % Salinity
gridded_glider_abc.glider_temperature = new_data_gridded.temperature(IND,:)'; % Temperature

% Save the gridded_glider_abc as a mat file for later use. 
save('gridded_AMLR01_AZFP_ABC_Apr7_2020.mat', 'gridded_glider_abc')