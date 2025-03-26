% Glider acoustic QA/QC code to see if the data look reasonable. 
% This uses the 'data' variable after scr_load_glider_and_EK60_azfp_data.m
% 2/7/2022 A Cossio

%% If you want to use just survey data or skip this step
d_ST = '2022-12-06 16:00'; % survey start time and date
d_ED = '2023-01-11 10:44'; % survey end time and date
date_ST = datenum(datetime(d_ST,'InputFormat', 'yyyy-MM-dd HH:mm'));
date_ED = datenum(datetime(d_ED,'InputFormat','yyyy-MM-dd HH:mm'));

sub_data = data(:,1) > date_ST & data(:,1) < date_ED; % select between the survey dates only

data = data(sub_data,:); % subset of just survey data
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
plot(mean(prfl_abc,2,"omitnan"),-zbins(2:end))
title("Ave ABC by depth")
ylabel('depth (m)')
xlabel('average ABC (m2 m-2)')

%% Make a table of the highest 200 ABC values to see if there are bad data 

[mABC, idx] = maxk(data(:,5),200);  % find the highest 200 values of ABC

maxABC = data(idx,:); % grab the index from the data

dat = datetime(maxABC(:,1),'ConvertFrom','datenum'); % make the date readable

maxABC = array2table(maxABC,"VariableNames",{'datenum','Lat','Lon','Depth','ABC'}); % convert the data to a table
maxABC.date = dat; % add the date to the table
maxABC = sortrows(maxABC,"date","ascend"); % sort rows by date

mean(data(:,5),'omitnan') % get the nanmean to see how much variability is from the max

%% Make a table of values higher than 1e4 for bad values

abc4 = (data(:,5)>=1e-4); % find values greater than 1e-4
mabc = data(abc4,:); % pull the index of the greater values
dit = datetime(mabc(:,1),'ConvertFrom','datenum'); % make the date readable

mabc = array2table(mabc,"VariableNames",{'datenum','Lat','Lon','Depth','ABC'}); % convert the data to a table
mabc.date = dit; % add the date to the table
mabc = sortrows(mabc,"date","ascend"); % sort by date

%% Make a table of the highest 200 ABC values if there are bad bottom data

mdep = find(data(:,4)> 300); % find data deeper than 300m

dep300 = data(mdep,:); % create subdata of greater than 300m

[md, idx2] = maxk(dep300(:,5),200); % find the highest 200 values of ABC
maxABC300 = dep300(idx2,:); % grab the index from the data

dot = datetime(maxABC300(:,1),'ConvertFrom','datenum'); 
maxABC300 = array2table(maxABC300,"VariableNames",{'datenum','Lat','Lon','Depth','ABC'}); % convert the data to a table
maxABC300.date = dot; % add the date to the table
maxABC300 = sortrows(maxABC300,"date","ascend"); % sort rows by date

%% Use gridded data instead of the full data
% work in progress

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
geobubble(gridded_glider_abc.glider_latitude,gridded_glider_abc.glider_longitude,mean(gridded_glider_abc.ABC*CF,'omitnan'))
title('bubble plot of XXkHz ABC')

% Figure with more resolution of the ABC bubbles
figure(5)
bubblechart(gridded_glider_abc.glider_latitude,-gridded_glider_abc.glider_longitude,mean(gridded_glider_abc.ABC,'omitnan'))
legend('ABC')


