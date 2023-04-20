% Glider acoustic QA/QC code to see if the data look reasonable. 
% This uses the 'data' variable after scr_load_glider_and_EK60_azfp_data.m
% 2/7/2022 A Cossio

%% Plot the ABC values over time

figure (1) 
plot(data(:,5)) 
a1 = yline(0.001,'r.'); M1 = "10e-3"; % 10e-3 line
a2 = yline(0.0001,'g'); M2 = "10e-4"; % 10e-4 line
legend([a1,a2], [M1, M2]) 
%legend(a2, M2) 
title("ABC values")
%% Plot the ABC by depth

figure(2) 
plot(avg_abc,-zbins(2:end))
title("Ave ABC by depth")
%% Make a table of the highest 50 ABC values to see if there are bad data 

[mABC, idx] = maxk(data(:,5),50);  % find the highest 50 values of ABC

maxABC = data(idx,:); % grab the index from the data

dat = datetime(maxABC(:,1),'ConvertFrom','datenum'); % make the date readable

maxABC = array2table(maxABC,"VariableNames",{'datenum','Lat','Lon','Depth','ABC'}); % convert the data to a table
maxABC.date = dat; % add the date to the table

mean(data(:,5),'omitnan') % get the nanmean to see how much variability is from the max
%% Make a table of the highest 50 ABC values if there are bad bottom data

mdep = find(data(:,4)> 300); % find data deeper than 300m

dep300 = data(mdep,:); % create subdata of greater than 300m

[md, idx2] = maxk(dep300(:,5),50); % find the highest 50 values of ABC
maxABC300 = dep300(idx2,:); % grab the index from the data

dot = datetime(maxABC300(:,1),'ConvertFrom','datenum'); 
maxABC300 = array2table(maxABC300,"VariableNames",{'datenum','Lat','Lon','Depth','ABC'}); % convert the data to a table
maxABC300.date = dot; % add the date to the table
%% Map the data

% %this takes too much to load at the moment. Still figuring this out.
% %Requires M_Map
% figure(3)
% m_proj('lambert','longitudes',[(min(data(:,3))-0.5) (max(data(:,3))+0.5)],'latitudes',[(min(data(:,2))-0.5) (max(data(:,3))+0.5)])
% m_scatter(data(:,3),data(:,2),log(data(:,4)),'filled')
% m_grid('box','on')
% m_gshhs_h('patch',[.7 .7 .7],'edgecolor','k')
% colorcet('BWG')
% title('Log ABC')

% With the Mapping toolbox bubble plot the data
figure(4)

geobubble(gridded_glider_abc.glider_latitude,gridded_glider_abc.glider_longitude,mean(gridded_glider_abc.ABC,'omitnan'))
title('bubble plot of 125kHz ABC')
% Figure with more resolution of the ABC bubbles
figure(5)
bubblechart(gridded_glider_abc.glider_latitude,-gridded_glider_abc.glider_longitude,mean(gridded_glider_abc.ABC,'omitnan'))
legend('ABC')


