%--------------------------------------------------------------
% scr_load_glider_and_acoustic_data_nc_two_freq.m
% 
% Load processed Slocum G3 glider data. Match acoustic data with glider
% data. Combine them. 
%  
% C. Reiss, 2018-08-22 
% modified by G. Cutter
% rewritten by CREISS to simplify everything we are doing
% A Cossio 2/13/2023 cleaned up
% A Cossio 4/24/25 converted to use nc file from pyglider
% A Cossio 5/12/25 changed profile indexing to use nc profiles, not create
% them
%--------------------------------------------------------------

%% Load glider data produced from Pyglider. There will be two 
%--------------------------------------------------------------
clear
fprintf('[f_load_] - Preparing to load glider data.\n');

[INFILE, INPATH] = uigetfile('*.nc;*.*', 'Select pyglider delayed-sci.nc files.','MultiSelect', 'off');

fn = fullfile(INPATH,INFILE);
ni = ncinfo(fn);
for i=1:length(ni.Variables)
    vn = ni.Variables(i).Name;
    data_processed.(vn) = ncread(fn, vn);  % The result is a structure 
end

[INFILE1, INPATH1] = uigetfile('*.nc;*.*', 'Select pyglider grid-delayed-5m.nc files.','MultiSelect', 'off');

fn1 = fullfile(INPATH1,INFILE1);
ni1 = ncinfo(fn1);
for i=1:length(ni1.Variables)
    vn1 = ni1.Variables(i).Name;
    data_gridded.(vn1) = ncread(fn1, vn1);  % The result is a structure 
end

fprintf('[f_load_] - Loaded Pyglider Processed Glider data\n');
clear infn

%--------------------------------------------------------------
%% Load processed acoustic output as a linked table. These data are csv files exported from Echoview in binned exports.
%--------------------------------------------------------------

fprintf('[f_load_] - Preparing to load acoustic data.\n');

[INPATH] = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick Echoview 70 kHz output Directory');

[data] = f_merge_acoustic_abc(INPATH);

fprintf('[f_load_] Loaded Pyglider-processed glider data and acoustic data.\n');

fprintf('f_load_glider_and_acoustic_data DONE\n');


fprintf('[f_load_] - Preparing to load acoustic data.\n');

[INPATH_120] = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick Echoview 120 kHz output Directory');

[data_120] = f_merge_acoustic_abc(INPATH_120);

fprintf('[f_load_] Loaded Pyglider-processed glider data and acoustic data.\n');

fprintf('f_load_glider_and_acoustic_data DONE\n');

%%%
% First work with the acoustic data to generate an array from the echoview
% data output (data)

%generate a list of unique dates for the processing

uni_dates = unique(data(:,1));

uni_dates_120 = unique(data_120(:,1));

% CHANGE BIN SIZES ACCORDINGLY

% zbins=[0:1:1005];  %1m bins
zbins = [0:5:1100]; %5m bins

% Now bin and create profiles
% [out mn_lats mn_lons] = EVIEW_2_MATLAB( dates, depths, acoustic_data_abc, lats, lons, bins, Mean_Sv)
[int_data, mn_lat, mn_lon, sv_int_data] = eview_2_matlab(data(:,1), data(:,4), data(:,5),data(:,2),data(:,3), zbins, data(:,6));

[int_data_120, mn_lat_120, mn_lon_120, sv_int_data_120] = eview_2_matlab(data_120(:,1), data_120(:,4), data_120(:,5),data_120(:,2),data_120(:,3), zbins, data_120(:,6));

%% Generate a time, profile, lat lon start and end matrix for the glider data
 
% Actual glider time, location and motion data
G3_AZFP_TIME_1 = [data_processed.time data_processed.profile_index data_processed.profile_direction data_processed.longitude data_processed.latitude ...
data_processed.depth data_processed.pitch data_processed.roll];
% glider time here is in epoch time and will be converted to matlab date
% number below.

%%% Here is the conversion of the useful time chunks to datenumber

full_prfl = G3_AZFP_TIME_1((mod(G3_AZFP_TIME_1(:,2),1) == 0),:); % subset only dives and climbs (integers), not inflections
isodd = rem(full_prfl(:,2),2) == 1; % find odd profile_index (dives)
subset = full_prfl(isodd,:); % subset odd profile_index (dives)

glider_datenum1 = epoch2datenum(subset(:,1)) ; %extract dates and convert to datenum

 %%
 %Now find the elements of the glider dates that match the nearest
 % acoustic data
 
 [near_idx,near_dist] = nearestpoint(uni_dates, glider_datenum1);

 [near_idx_120,near_dist_120] = nearestpoint(uni_dates_120, glider_datenum1);

 Uniq_prfiles = unique(subset(near_idx,2));

 Uniq_prfiles_120 = unique(subset(near_idx_120,2));

% 70 kHz
% preallocate 
n_profiles = length(Uniq_prfiles);
n_depth_bins = size(int_data, 1);  % Same as length(zbins)-1
prfl_abc = NaN(n_depth_bins, n_profiles);       % Preallocate with NaNs 
num_pings_profil = NaN(1, n_profiles);        % Integer counts
avg_profile_num  = NaN(1, n_profiles);
avg_time         = NaN(1, n_profiles);
avg_lat          = NaN(1, n_profiles);
avg_lon          = NaN(1, n_profiles);

prfl_sv = NaN(n_depth_bins, n_profiles);
%val_to_omit = -999; % empty data for Sv
%is_not_999 = (sv_int_data ~=-999);
%is_not_nan = ~isnan(sv_int_data);
%valid_sv = is_not_nan & is_not_999; % index of Sv without Nan and -999
z_sv_int_data = sv_int_data;
sv_int_data(sv_int_data == -999) = NaN; % convert -999 to NaN

 
 for ii = 1:length(Uniq_prfiles)
     aa = find(subset(near_idx,2)==Uniq_prfiles(ii) );
     avg_abc = mean(int_data(:,aa),2,'omitnan');          
     prfl_abc(:,ii) = avg_abc;      
     num_pings_profil(ii) = length(aa);
     avg_profile_num(ii) = Uniq_prfiles(ii);
     avg_time(ii) = mean(uni_dates(aa),'omitnan');
     avg_lat(ii) = mean(mn_lat(aa));
     avg_lon(ii) = mean(mn_lon(aa));
     avg_sv = mean(sv_int_data(:,aa),2,'omitnan');
     prfl_sv(:,ii) = avg_sv;
 end
 
% 120 kHz
 % preallocate 
n_profiles_120 = length(Uniq_prfiles_120);
n_depth_bins_120 = size(int_data_120, 1);  % Same as length(zbins)-1
prfl_abc_120 = NaN(n_depth_bins_120, n_profiles_120);       % Preallocate with NaNs 
num_pings_profil_120 = NaN(1, n_profiles_120);        % Integer counts
avg_profile_num_120  = NaN(1, n_profiles_120);
avg_time_120         = NaN(1, n_profiles_120);
avg_lat_120          = NaN(1, n_profiles_120);
avg_lon_120          = NaN(1, n_profiles_120);

prfl_sv_120 = NaN(n_depth_bins_120, n_profiles_120);
%val_to_omit = -999; % empty data for Sv
%is_not_999 = (sv_int_data ~=-999);
%is_not_nan = ~isnan(sv_int_data);
%valid_sv = is_not_nan & is_not_999; % index of Sv without Nan and -999
z_sv_int_data_120 = sv_int_data_120;
sv_int_data_120(sv_int_data_120 == -999) = NaN; % convert -999 to NaN

 
 for jj = 1:length(Uniq_prfiles)
     bb = find(subset(near_idx_120,2)==Uniq_prfiles(jj) );
     avg_abc_120 = mean(int_data_120(:,bb),2,'omitnan');          
     prfl_abc_120(:,jj) = avg_abc_120;      
     num_pings_profil_120(jj) = length(bb);
     avg_profile_num_120(jj) = Uniq_prfiles(jj);
     avg_time_120(jj) = mean(uni_dates_120(bb),'omitnan');
     avg_lat_120(jj) = mean(mn_lat_120(bb));
     avg_lon_120(jj) = mean(mn_lon_120(bb));
     avg_sv_120 = mean(sv_int_data_120(:,bb),2,'omitnan');
     prfl_sv_120(:,jj) = avg_sv_120;
 end

 %Now remove half profiles and other 'bad data'
 %
 qc = mod(avg_profile_num,1);
 bd_prfile_idx = find(qc == 0.5);
 prfl_abc(:,bd_prfile_idx) = NaN;
       
%% Figures
figure (1)
subplot(2,1,1)
pcolor(uni_dates, -1*zbins(2:end), int_data); shading flat 
xlabel ('Time')
ylabel ('Depth')
datetick('x',6,'keepticks')
title('70 kHz Glider profiles')
subplot(2,1,2)
pcolor(uni_dates_120, -1*zbins(2:end), int_data_120); shading flat 
xlabel ('Time')
ylabel ('Depth')
datetick('x',6,'keepticks')
title('120 kHz Glider profiles')
  
figure(2)
subplot(2,1,1)
pcolor(1:length(Uniq_prfiles), -1*zbins(2:end),(log(prfl_abc))); shading flat %amc2/2/22 uniq_prfl_nasc was causing wider bands. 
colorcet('BWRA')
c = colorbar;
c.Label.String = ' Log ABC';
xlabel('Profile number')
ylabel('Depth')
title('70 kHz Log acoustics')
%ylim([-26 -8])
subplot(2,1,2)
pcolor(1:length(Uniq_prfiles), -1*zbins(2:end),(log(prfl_abc_120))); shading flat %amc2/2/22 uniq_prfl_nasc was causing wider bands. 
colorcet('BWRA')
c = colorbar;
c.Label.String = ' Log ABC';
xlabel('Profile number')
ylabel('Depth')
title('120 kHz Log acoustics')

figure(3)
subplot(2,1,1)
plot(avg_profile_num,num_pings_profil,'.')
xlabel('Avg Profile number')
ylabel('Number acoustic pings profile')
title('70 kHz Number of acoustic pings per profile')
subplot(2,1,2)
plot(avg_profile_num_120,num_pings_profil_120,'.')
xlabel('Avg Profile number')
ylabel('Number acoustic pings profile')
title('120 kHz Number of acoustic pings per profile')

