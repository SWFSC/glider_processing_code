%% merge_gridded_glider_and_acoustic_survey_data.m
% Script to merge the data from the glider and the acoustics after processing from 
% scr_load_glider_and_acoustic_data.m This script is based on scr_merge_gridded_glider_and_acoustic_data.m
% but is designed to only look at the survey data.
% Converts the data into profiles
% 5/13/2024 A Cossio

%% If you want to use just survey data or skip this step
d_ST = '2022-12-06 16:00'; % survey start time and date
d_ED = '2023-01-11 10:44'; % survey end time and date
date_ST = datenum(datetime(d_ST,'InputFormat', 'yyyy-MM-dd HH:mm'));
date_ED = datenum(datetime(d_ED,'InputFormat','yyyy-MM-dd HH:mm'));
 
survey_subset = avg_time > date_ST & avg_time < date_ED; % subset of time of profiles between survey dates

% subset the full data set
prfl_abc_survey = (prfl_abc(:,survey_subset)); % abc values of acoustics
num_pings_profil_survey = num_pings_profil(survey_subset); % pings per profile
avg_profile_num_survey =  avg_profile_num(survey_subset); % profile number
avg_time_survey = avg_time(survey_subset); % profile average time
avg_lat_survey = avg_lat(survey_subset); % average profile latitude
avg_lon_survey = avg_lon(survey_subset); % average profile longitude

qc = mod(avg_profile_num_survey,1);  % Make profiles either 0 or 0.5
gd_prfile_idx = find(qc==0);  % Find profiles that are whole numbers (dives and climbs)

%% put the data in a structure
gridded_glider_abc_survey = struct(); % Create an empty structure 

gridded_glider_abc_survey.gd_prfl_abc = prfl_abc_survey(:,gd_prfile_idx);     
gridded_glider_abc_survey.num_pings_profil_gd = num_pings_profil_survey(gd_prfile_idx);
gridded_glider_abc_survey.avg_profile_num_gd = avg_profile_num_survey(gd_prfile_idx) ;
gridded_glider_abc_survey.avg_time_gd = avg_time_survey(gd_prfile_idx);
gridded_glider_abc_survey.avg_lat_gd = avg_lat_survey(gd_prfile_idx);
gridded_glider_abc_survey.avg_lon_gd = avg_lon_survey(gd_prfile_idx);
gridded_glider_abc_survey.zbins_gd = zbins;

bd_bottom = find(max(log10(gridded_glider_abc_survey.gd_prfl_abc(400:end,:)))>-5); % Find large abc values that could be accidental bottom integration

abc = gridded_glider_abc_survey.gd_prfl_abc;
abc(400:end,bd_bottom) = NaN;

gridded_glider_abc_survey.ABC = abc; % These are the gridded ABC to be used in analyses

%% Now find profiles that are linked between glider and acoustics
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

% Find the neartest time in glider data that is closest to the acoustic time
IND = nearestpoint(gridded_glider_abc_survey.avg_time_gd, epoch2datenum(new_data_gridded.time));

% add glider science data to the acoustic data 
gridded_glider_abc_survey.glider_time = new_data_gridded.time(IND);  % Time
gridded_glider_abc_survey.glider_longitude = new_data_gridded.longitude(IND); % Longitude
gridded_glider_abc_survey.glider_latitude = new_data_gridded.latitude(IND); % Latitude
gridded_glider_abc_survey.glider_prf_index = new_data_gridded.profile_index(IND); % Profile index
gridded_glider_abc_survey.glider_depth = new_data_gridded.depth; % Depth
gridded_glider_abc_survey.glider_backscatter_700 = new_data_gridded.backscatter_700(IND,:)'; % Backscatter
gridded_glider_abc_survey.glider_cdom = new_data_gridded.cdom(IND,:)'; % CDOM
gridded_glider_abc_survey.glider_chlorophyll = new_data_gridded.chlorophyll(IND,:)'; % Chlorophyll
gridded_glider_abc_survey.glider_density = new_data_gridded.density(IND,:)'; 
gridded_glider_abc_survey.glider_oxygen_concentration = new_data_gridded.oxygen_concentration(IND,:)'; % Oxygen concentration
gridded_glider_abc_survey.glider_oxygen_saturation = new_data_gridded.oxygen_saturation(IND,:)'; % Oxygen saturation
gridded_glider_abc_survey.glider_pressure = new_data_gridded.pressure(IND,:)'; % Pressure from the CTD
gridded_glider_abc_survey.glider_salinity = new_data_gridded.salinity(IND,:)'; % Salinity
gridded_glider_abc_survey.glider_temperature = new_data_gridded.temperature(IND,:)'; % Temperature

%% Save the gridded_glider_abc as a mat file for later use. 
save('gridded_AMLR03_2023-24_120kHz_5x5_survey.mat', 'gridded_glider_abc_survey')