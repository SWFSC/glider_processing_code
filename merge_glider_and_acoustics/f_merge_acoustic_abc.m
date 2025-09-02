function [data] = f_merge_acoustic_abc(path)
% Merges Echoview .csv files from a folder and filters out bad data
% Anthony Cossio (edited for performance and clarity)

files = dir(fullfile(path, '*.csv'));
allTables = cell(length(files), 1);  % Preallocate cell array for speed

for i = 1:length(files)
    filename = fullfile(files(i).folder, files(i).name);
    T = readtable(filename, 'FileType', 'text');

    % Logical filtering of valid data rows
    valid = T.Interval ~= 0 & T.Depth_mean ~= 0 & T.ABC ~= -9999 & T.Lon_S ~= 999;
    allTables{i} = T(valid, :);  % Store filtered table
end

% Concatenate all tables at once
alldata = vertcat(allTables{:});

% Parse times more efficiently using datetime
hrs = datevec(alldata.Time_S,'HH:MM:SS.FFF');
ymd = datevec(datetime(alldata.Date_S,'ConvertFrom', 'yyyymmdd'));
acousticdtnum = datenum([ymd(:,1:3) hrs(:,4:6)]);

% Output as numeric matrix (datenum equivalent)
data = [acousticdtnum, alldata.Lat_S, alldata.Lon_S, alldata.Depth_mean, alldata.ABC, alldata.Sv_mean];

