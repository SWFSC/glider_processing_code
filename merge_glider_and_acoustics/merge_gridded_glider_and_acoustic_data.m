% merge_gridded_glider_and_acoustic_data.m
% This script merges the data from the glider and the acoustics after processing
% It will need to be generalized or turned into a function.

% Load the data that was saved from the scr_load_glider_and_acoustic_data.m
% You will have to do this for each frequency

%% Load processed glider-acoustic data
%load('C:\Work\AMLR01\export_1x1\Matlab_output_merge\AMLR01_2018_1x1m_67khz_250m.mat');

%% Filter for valid profiles (whole numbers)
qc = mod(avg_profile_num, 1);  % 0 = full dives/climbs
gd_prfile_idx = find(qc == 0);

% Pre-allocate and assign valid profiles
gridded_glider_abc = struct();
gridded_glider_abc.gd_prfl_abc = prfl_abc(:, gd_prfile_idx);
gridded_glider_abc.num_pings_profil_gd = num_pings_profil(gd_prfile_idx);
gridded_glider_abc.avg_profile_num_gd = avg_profile_num(gd_prfile_idx);
gridded_glider_abc.avg_time_gd = avg_time(gd_prfile_idx);
gridded_glider_abc.avg_lat_gd = avg_lat(gd_prfile_idx);
gridded_glider_abc.avg_lon_gd = avg_lon(gd_prfile_idx);
gridded_glider_abc.zbins_gd = zbins;

%% Clean unrealistic high backscatter values (bottom echoes)
abc = gridded_glider_abc.gd_prfl_abc;
bd_bottom = find(max(log10(abc(400:end, :))) > -5);  % suspect bottom artifacts
abc(400:end, bd_bottom) = NaN;
gridded_glider_abc.ABC = abc;

%% Filter gridded glider profiles with at least 4 non-NaN salinity values
valid_mask = sum(~isnan(data_gridded.salinity'), 1) > 3;
nan_idx = find(valid_mask);

fields_to_copy = {
    'depth'
    'profile'
    'time'
    'longitude'
    'latitude'
    'backscatter_700'
    'cdom'
    'chlorophyll'
    'conductivity'
    'density'
    'oxygen_concentration'
    'oxygen_saturation'
    'pressure'
    'salinity'
    'temperature'
    'par'
};

new_data_gridded = struct();
for i = 1:numel(fields_to_copy)
    field = fields_to_copy{i};
    if isfield(data_gridded, field)
        if size(data_gridded.(field), 1) >= max(nan_idx)
            new_data_gridded.(field) = data_gridded.(field)(nan_idx, :);
        else
            warning('Field %s does not have expected dimensions.', field);
        end
    end
end
new_data_gridded.depth = data_gridded.depth;  % Depth is constant, not subset

%% Find closest glider ABC times to new glider profiles
IND = nearestpoint(gridded_glider_abc.avg_time_gd, epoch2datenum(new_data_gridded.time));


%% Assign matched data to output structure
scalar_fields = {
    'time', 'glider_time';
    'longitude', 'glider_longitude';
    'latitude', 'glider_latitude';
    'profile', 'glider_prf_index'
};

for i = 1:size(scalar_fields, 1)
    raw_name = scalar_fields{i, 1};
    out_name = scalar_fields{i, 2};
    gridded_glider_abc.(out_name) = new_data_gridded.(raw_name)(IND);
end

matrix_fields = setdiff(fields_to_copy, {'depth', 'profile', 'time', 'longitude', 'latitude'});
for i = 1:numel(matrix_fields)
    fname = matrix_fields{i};
    if isfield(new_data_gridded, fname)
        gridded_glider_abc.(['glider_' fname]) = new_data_gridded.(fname)(IND, :)';
    end
end

gridded_glider_abc.glider_depth = new_data_gridded.depth;

%% Save the gridded_glider_abc as a mat file for later use. 
%save('gridded_AMLR01_AZFP_ABC_Apr7_2020.mat', 'gridded_glider_abc')