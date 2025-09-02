% --- Refactored scr_load_glider_and_acoustic_data_nc_two_freq.m ---

% Main script to load and process glider and acoustic data.
clear;
fprintf('[f_load_] - Preparing to load glider data.\n');

% Load glider data
gliderDataProcessed = loadGliderNetCDF('delayed-sci.nc');
gliderDataGridded = loadGliderNetCDF('grid-delayed-5m.nc');

fprintf('[f_load_] - Loaded Pyglider Processed Glider data\n');

% Process 70 kHz acoustic data
[acousticData70, gliderProfileData] = processAcousticData(gliderDataProcessed, '70 kHz');

% Process 120 kHz acoustic data
acousticData120 = processAcousticData(gliderDataProcessed, '120 kHz');

fprintf('f_load_glider_and_acoustic_data DONE\n');

% --- Helper Functions ---

function data = loadGliderNetCDF(filePattern)
    [filename, inputPath] = uigetfile(['*' filePattern], ['Select pyglider ' filePattern ' file.']);
    fullFilename = fullfile(inputPath, filename);
    info = ncinfo(fullFilename);
    data = struct();
    for i = 1:length(info.Variables)
        varName = info.Variables(i).Name;
        data.(varName) = ncread(fullFilename, varName);
    end
end

function [acousticData, gliderProfileData] = processAcousticData(gliderData, frequency)
    % Prompt user to select directory
    acousticPath = uigetdir('D:\APPLICATIONS\MATLAB', ['Pick Echoview ' frequency ' output Directory']);
    
    % Merge acoustic files
    mergedAcoustic = f_merge_acoustic_abc(acousticPath);
    
    % Define depth bins
    zbins = [0:5:1100]; % 5m bins
    
    % Bin acoustic data
    [int_data, mn_lat, mn_lon, sv_int_data] = eview_2_matlab(mergedAcoustic(:,1), mergedAcoustic(:,4), ...
        mergedAcoustic(:,5), mergedAcoustic(:,2), mergedAcoustic(:,3), zbins, mergedAcoustic(:,6));
    
	G3_AZFP_TIME_1 = [gliderDataProcessed.time gliderDataProcessed.profile_index gliderDataProcessed.profile_direction gliderDataProcessed.longitude gliderDataProcessed.latitude ...
gliderDataProcessed.depth gliderDataProcessed.pitch gliderDataProcessed.roll];
% glider time here is in epoch time and will be converted to matlab date
% number below.
    % Process glider profiles
    full_prfl = gliderData.G3_AZFP_TIME_1((mod(gliderData.G3_AZFP_TIME_1(:,2),1) == 0),:);
    isodd = rem(full_prfl(:,2),2) == 1;
    subset = full_prfl(isodd,:);
    glider_datenum1 = epoch2datenum(subset(:,1));
    
    % Find nearest acoustic data
    uni_dates = unique(mergedAcoustic(:,1));
    [near_idx, ~] = nearestpoint(uni_dates, glider_datenum1);
    
    % Aggregate data
    Uniq_prfiles = unique(subset(near_idx,2));
    n_profiles = length(Uniq_prfiles);
    n_depth_bins = size(int_data, 1);
    
    prfl_abc = NaN(n_depth_bins, n_profiles);
    prfl_sv = NaN(n_depth_bins, n_profiles);
    num_pings_profil = NaN(1, n_profiles);
    avg_profile_num = NaN(1, n_profiles);
    avg_time = NaN(1, n_profiles);
    avg_lat = NaN(1, n_profiles);
    avg_lon = NaN(1, n_profiles);
    
    for ii = 1:length(Uniq_prfiles)
        aa = find(subset(near_idx,2)==Uniq_prfiles(ii));
        prfl_abc(:,ii) = mean(int_data(:,aa), 2, 'omitnan');
        prfl_sv(:,ii) = mean(sv_int_data(:,aa), 2, 'omitnan');
        num_pings_profil(ii) = length(aa);
        avg_profile_num(ii) = Uniq_prfiles(ii);
        avg_time(ii) = mean(uni_dates(aa), 'omitnan');
        avg_lat(ii) = mean(mn_lat(aa));
        avg_lon(ii) = mean(mn_lon(aa));
    end
    
    % Store results in a structure
    acousticData.int_data = int_data;
    acousticData.sv_int_data = sv_int_data;
    acousticData.prfl_abc = prfl_abc;
    acousticData.prfl_sv = prfl_sv;
    
    gliderProfileData.avg_profile_num = avg_profile_num;
    gliderProfileData.num_pings_profil = num_pings_profil;
    gliderProfileData.avg_time = avg_time;
    gliderProfileData.avg_lat = avg_lat;
    gliderProfileData.avg_lon = avg_lon;
    gliderProfileData.zbins = zbins;
end