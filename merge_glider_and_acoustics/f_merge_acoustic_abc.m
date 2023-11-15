function [data] = f_merge_acoustic_abc(path)
%to read in Echoview csv files and append them into one file. After being
%brought in, get rid of bad data points (ie -9999 NASC values,etc). To be
%used in a number of other functions. 
% Anthony Cossio 9/25/2012
% 2/23/17 added lines to split YYYYMMDD and afix to data also add gm2
% Nov 2 2023 changed ymd line to be quicker. 

cd(path);
%X = dir;
%X(1:2) = [];
files = dir(fullfile(path, '*.csv'));
alldata = [];
% loop to open all the files in the folder and then attach them together to
% form one file of data
for i = 1:length(files)
    filename = fullfile(files(i).folder, files(i).name);
    data = readtable(filename, 'FileType', 'text');

    % Filtering data with logical indexing
        valid_rows = data.Interval ~= 0 & data.Depth_mean ~= 0 & data.ABC ~= -9999 & data.Lon_S ~= 999;
        data = data(valid_rows, :);

        alldata = [alldata; data];
%     nm = X(i).name;
%     aa = readtable(nm,'FileType','text');
%   % remove some bad value and minimize the overall file size  
%   data = aa; % transpose data
%   int = data.Interval~=0; % finds and removes 0 intervals
%   data = data(int,:);
%   dep = data.Depth_mean~=0; % finds and removes 0 depths
%   data = data(dep,:);
%   nasc = data.ABC~=-9999; % find and remove -9999 NASC changed to ABC
%   data = data(nasc,:);
%   lon = data.Lon_S~=999; % find and remove bad Lon_M
%   data = data(lon,:);
% alldata = [alldata;data];
end

hrs = datevec(alldata.Time_S,'HH:MM:SS.FFF');
ymd = datevec(datetime(alldata.Date_S,'ConvertFrom', 'yyyymmdd'));

acousticdtnum = datenum([ymd(:,1:3) hrs(:,4:6)]);

data = [acousticdtnum alldata.Lat_S alldata.Lon_S alldata.Depth_mean alldata.ABC];