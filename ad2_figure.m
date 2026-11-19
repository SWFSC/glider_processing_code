% Script to make a figure from a mat file created from f_COMBINE_NORTEK_COMPACT_TELEMETRY_DATA.m
% that uses converted ad2 files

% load the mat file
load('C:\Work\2025_calanus\calanus_june_25_telemtry.mat')
cal = -73.62; % apply a calibration offset

%BS = DATA.caldata.BS_120+cal;

%BS = DATA.cal_VBS_echo_120;
date = epoch2datenum(DATA.Time_stmp);
ymd = datestr(date,'yyyy-mm-dd');

figure (1)
pcolor(BS'); 
shading flat; 
colorbar; 
clim([-50 10])
set(gca, 'YDir', 'reverse');

xticklabels({ymd(10,:),ymd(20,:),ymd(30,:),ymd(40,:),ymd(50,:),ymd(60,:),ymd(70,:),ymd(80,:)})
ytik = str2double(yticklabels);
ylb = ytik*5;
yticklabels(ylb)
ylabel('Depth(m)')
xlabel('Date')
title('Telemetry 120kHz')