%--------------------------------------------------------------
% scr_load_glider_and_acoustic_data.m
% 
% Load processed Slocum G3 glider data. 
%  (It will be included as an output in the glider section in SOCIB eventually) 
% C. Reiss, 2018-08-22 
% modified by G. Cutter
% rewritten by CREISS to simplify everything we are doing
% A Cossio 2/13/2023 cleaned up
%--------------------------------------------------------------

%% Load glider data produced from socib glider toolbox (mod. by Reiss). This is currently a mat file. 
%--------------------------------------------------------------
clear
fprintf('[f_load_] - Preparing to load glider data.\n');

[INFILE, INPATH] = uigetfile('*.mat;*.*', 'Select socib-processed glider mat file.','MultiSelect', 'off');

infn = fullfile(INPATH,INFILE);
load( infn ,'data_processed');
load( infn ,'data_gridded');

fprintf('[f_load_] - Loaded SOCIB Processed Glider data\n');
clear infn

%--------------------------------------------------------------
%% Load processed acoustic output as a linked table. These data are csv files exported from Echoview in binned exports.
%--------------------------------------------------------------

fprintf('[f_load_] - Preparing to load acoustic data.\n');

[INPATH] = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick a Directory');

[data] = f_merge_acoustic_abc(INPATH);

fprintf('[f_load_] Loaded socib-processed glider data and acoustic data.\n');

fprintf('f_load_glider_and_acoustic_data DONE\n');

%%%
% First work with the acoustic data to generate an array from the echoview
% data output (data)

%generate a list of unique dates for the processing

uni_dates = unique(data(:,1));

% CHANGE BIN SIZES ACCORDINGLY

% zbins=[0:1:1005];  %1m bins
zbins = [0:5:1005]; %5m bins

% Now bin and create profiles
% [out mn_lats mn_lons] = EVIEW_2_MATLAB( dates, depths, acoustic_data, lats, lons, bins)
[int_data, mn_lat, mn_lon] = eview_2_matlab(data(:,1), data(:,4), data(:,5),data(:,2),data(:,3), zbins);

%% Generate a time, profile, lat lon start and end matrix for the glider data
 
% Actual glider time, location and motion data
G3_AZFP_TIME_1 = [data_processed.time data_processed.profile_index data_processed.profile_direction data_processed.longitude data_processed.latitude ...
data_processed.depth data_processed.pitch data_processed.roll];
% glider time here is in epoch time and will be converted to matlab date
% number below.

%%% Here is the conversion of the useful time chunks to datenumber
 
down_prfiles = find(G3_AZFP_TIME_1(:,3)>0); %profile direction
round_down_prfiles = ceil(G3_AZFP_TIME_1(down_prfiles,2)); %profile index

profile_index2(down_prfiles) = round_down_prfiles;

dnyo = find(profile_index2 > 0);
subset = G3_AZFP_TIME_1(dnyo,:);

glider_datenum1 = epoch2datenum(subset(:,1)) ;

 %%
 %Now find the elements of the glider dates that match the nearest
 % acoustic data
 
 [near_idx,near_dist] = nearestpoint(uni_dates, glider_datenum1);
 

 Uniq_prfiles = unique(subset(near_idx,2));
 
 for ii = 1:length(Uniq_prfiles)
     aa = find(subset(near_idx,2)==Uniq_prfiles(ii) );
     avg_abc = mean(int_data(:,aa),2,'omitnan');          
     prfl_abc(:,ii) = avg_abc;            
     num_pings_profil(ii) = length(aa);
     avg_profile_num(ii) = Uniq_prfiles(ii);
     avg_time(ii) = mean(uni_dates(aa),'omitnan');
     avg_lat(ii) = mean(mn_lat(aa));
     avg_lon(ii) = mean(mn_lon(aa));
 end
 
 %Now remove half profiles and other 'bad data'
 %
 qc = mod(avg_profile_num,1);
 bd_prfile_idx = find(qc == 0.5);
 prfl_abc(:,bd_prfile_idx) = NaN;
       
%% Figures

 figure (1)
pcolor(uni_dates, -1*zbins(2:end), int_data); shading flat 
xlabel ('Time')
ylabel ('Depth')
datetick('x',6,'keepticks')
title('Glider profiles')
  
figure(2)
pcolor(1:length(Uniq_prfiles), -1*zbins(2:end),(log(prfl_abc))); shading flat %amc2/2/22 uniq_prfl_nasc was causing wider bands. 
colorcet('BWRA')
c = colorbar;
c.Label.String = ' Log ABC';
xlabel('Profile number')
ylabel('Depth')
title('Log acoustics')

figure(3)
plot(avg_profile_num,num_pings_profil,'.')
xlabel('Avg Profile number')
ylabel('Number acoustic pings profile')
title('Number of acoustic pings per profile')