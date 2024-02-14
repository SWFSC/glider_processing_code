% File for use with R code "Make evr file with start-end times.R"
% This will get out the profile number, min and max lat and lon with start
% and end time of the profiles, both up and down
% Use the mat file from SOCIB to get the profile index numbers, start and end time for each profile
% requires epoch2datenum.m
% AMC 2/8/22 initial


G3 = [data_processed.time data_processed.profile_index data_processed.profile_direction data_processed.longitude data_processed.latitude ...
data_processed.depth];
% glider time here is in epoch time and will be converted to matlab date
% number below.

int = (G3(:,2) - floor(G3(:,2))) == 0; % find integers in profile number

g3_int = G3(int,:); % keep just integers of profile number

%% Down profiles
down_prfiles = find(g3_int(:,3)>0); % Index of when profile direction is negative (dive) 

sub_dwn = g3_int(down_prfiles,:); % subset of just down profiles

tab_dwn = array2table(sub_dwn,'VariableNames',{'e_date','profile','direction','lon','lat','depth'}); % make the array a table

stat_dwn = grpstats(tab_dwn,'profile',{'min','max'}); % group stats to get the min and max datenum for each profile

stat_dwn.date_s = datetime(epoch2datenum(stat_dwn.min_e_date),'ConvertFrom','datenum','Format','MM/dd/yyyy HH:mm:ss'); % convert from glider date to datenum and make it readable
stat_dwn.date_e = datetime(epoch2datenum(stat_dwn.max_e_date),'ConvertFrom','datenum','Format','MM/dd/yyyy HH:mm:ss'); 

stat_dn = stat_dwn(stat_dwn.GroupCount > 15,:); % only profiles with at least 15 counts

% create table with profile #, min lon, max lon, min lat, max lat, date start and date end 
down_prfl = table(stat_dn.profile, stat_dn.min_lon, stat_dn.max_lon, stat_dn.min_lat, stat_dn.max_lat, stat_dn.date_s, stat_dn.date_e,'VariableNames',{'profile','min_lon','max_lon','min_lat','max_lat','start.time','end.time'});



%% Up profiles

up_prfiles = find(g3_int(:,3)<0); % Index of when profile direction is positive (climb) 

sub_up = g3_int(up_prfiles,:); % subset of just up profiles

tab_up = array2table(sub_up,'VariableNames',{'e_date','profile','direction','lon','lat','depth'}); % make the array a table

stat_up = grpstats(tab_up,'profile',{'min','max'}); % group stats to get the min and max datenum for each profile

stat_up.date_s = datetime(epoch2datenum(stat_up.min_e_date),'ConvertFrom','datenum','Format','MM/dd/yyyy HH:mm:ss'); % convert from glider date to datenum and make it readable
stat_up.date_e = datetime(epoch2datenum(stat_up.max_e_date),'ConvertFrom','datenum','Format','MM/dd/yyyy HH:mm:ss'); 

stat_u = stat_up(stat_up.GroupCount > 15,:); % only profiles with at least 15 counts

% create table with profile #, min lon, max lon, min lat, max lat, date start and date end 
up_prfl = table(stat_u.profile, stat_u.min_lon, stat_u.max_lon, stat_u.min_lat, stat_u.max_lat, stat_u.date_s, stat_u.date_e,'VariableNames',{'profile','min_lon','max_lon','min_lat','max_lat','start.time','end.time'});

%% Write out the tables to csv
% Change file name as needed
writetable(down_prfl,'AMLR04_down_profile.csv') %write table to csv file for use with R code
writetable(up_prfl,'AMLR04_up_profile.csv') 
