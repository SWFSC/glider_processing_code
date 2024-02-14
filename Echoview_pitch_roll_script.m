% Script for writing the GPS, pitch, roll, and depth files from the Socib files
% for use in Echoview to join glider data with acoustic data. 
%
% requires epoch2datenum.m
% 2/10/2022 A Cossio initial
% 2/9/2023 A Cossio cleaned up code and added more comments.

%load SOCIB processed mat file of glider data for the survey you want. It
%needs to contain "data_processed" data
%load ('C:\glider_data\amlr02\SOCIB\MAT_FILES\AMLR02_data_Cali_cruisin_5_24.mat')

fn = 'amlr04'; % Change glider name as needed

yrs = datestr(epoch2datenum(data_processed.time),'yyyymmdd') ; %date string for depth files

dts = datestr(epoch2datenum(data_processed.time),'mm/dd/yyyy'); % date string for pitch and roll files
dts4 = datestr(epoch2datenum(data_processed.time),'yyyy-mm-dd'); % date string for GPS files

tmss = datestr(epoch2datenum(data_processed.time),'HH:MM:SS'); % time for GPS, Pitch and Roll files
tms2 = datestr(epoch2datenum(data_processed.time),'HHMMSS'); % time for depth files

tms3 = [tms2 repmat('0000',length(tms2),1)]; % make sure that time for GPS is 10 digits
pitchdeg = rad2deg(data_processed.pitch); % convert pitch radians to degrees
rolldeg = rad2deg(data_processed.roll); % convert roll radians to degree

rep3 = repmat(3,length(tms2),1); % column of 3 for depth file. 3 indicates good line

%Write GPS data for Echoview
gps_table = table(dts4, tmss, data_processed.latitude, data_processed.longitude, 'VariableNames',{'GPS_date','GPS_time', 'Latitude', 'Longitude'} );
gps_table = rmmissing(gps_table); % remove missing values and NaNs

%write one very large csv file of GPS data for Echoview
% writetable(gps_table,sprintf('%sALL.gps.csv',fn),'FileType','text') 

%Write pitch table for Echoview
pitch_table = table(dts, tmss, pitchdeg, 'VariableNames',{'Pitch_date','Pitch_time', 'Pitch_angle'} );
pitch_table = rmmissing(pitch_table); % remove missing values and NaNs

%write one very large csv file of pitch data for Echoview
% writetable(pitch_table,sprintf('%sALL.pitch.csv',fn),'FileType','text')  %Pitch_date,Pitch_time,Pitch_angle

%Write roll table for Echoview
roll_table = table(dts, tmss, rolldeg,  'VariableNames',{'Roll_date','Roll_time', 'Roll_angle'}  );
roll_table = rmmissing(roll_table); % remove missing values and NaNs

%write one very large csv file of roll data for Echoview
% writetable(roll_table,sprintf('%sALL.roll.csv',fn), 'FileType','text')

%Write depth data for Echoview
depth_table = table(yrs, tms3, data_processed.depth, rep3);  %add a column of 3
depth_table = rmmissing(depth_table); % remove missing values and NaNs

%write one very large csv file of depth data for Echoview
% writetable(depth_table,sprintf('%sALL.depth.evl',fn),'FileType','text','Delimiter','tab')   

%Copy this header then below is the count of entries must equal that number
%below. 6070 would be 6070 entries
% TODO add this to header of the writetable
%EVBD 3 8.0.73.30735			
%500000	



% GPS tables written to csv files in 500000 chunk files

X = 1:500000:size(gps_table,1);
for i = 1:length(X)
 if i < length(X)
writetable(gps_table(X(i):X(i+1)-1,:), sprintf('%sEV%d.gps.csv',fn, i), 'FileType', 'text')
 else
writetable(gps_table(X(i):end,:), sprintf('%sEV%d.gps.csv',fn, i), 'FileType', 'text')
 end
end


% Roll tables written to csv filesin 500000 chunk files

X = 1:500000:size(roll_table,1);
for i = 1:length(X)
 if i < length(X)
writetable(roll_table(X(i):X(i+1)-1,:), sprintf('%sEV%d.roll.csv',fn, i), 'FileType', 'text')
 else
writetable(roll_table(X(i):end,:), sprintf('%sEV%d.roll.csv',fn, i), 'FileType', 'text')
 end
end


% Pitch tables written to csv files in 500000 chunk files

X = 1:500000:size(pitch_table,1);
for i = 1:length(X)
 if i < length(X)
writetable(pitch_table(X(i):X(i+1)-1,:), sprintf('%sEV%d.pitch.csv',fn, i), 'FileType', 'text')
 else
writetable(pitch_table(X(i):end,:), sprintf('%sEV%d.pitch.csv',fn, i), 'FileType', 'text')
 end
end


% Depth table written to csv files in 500000 chunk files

X = 1:500000:size(depth_table,1);
for i = 1:length(X)
 if i < length(X)
writetable(depth_table(X(i):X(i+1)-1,:), sprintf('%sEV%d.depth.evl',fn, i), 'FileType','text','Delimiter','tab')
 else
writetable(depth_table(X(i):end,:), sprintf('%sEV%d.depth.evl',fn, i), 'FileType','text','Delimiter','tab')
 end
end
%Copy this header then below is the count of entries must equal the number below.
%EVBD 3 8.0.73.30735			
%500000	

