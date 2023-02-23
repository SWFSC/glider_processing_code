function results = calcBiomass(dname)
% calcBiomass   Calculate krill biomass
%   RESULTS = calcBiomass(DNAME) processes all CSV files located in the
%   directory DNAME to calculate krill density and biomass over a survey
%   area, returned in the structure RESULTS. Each CSV file is treated as a
%   transect. The user is prompted to enter a conversion factor, used to
%   convert from NASC to krill density, and survey area, to convert from
%   density to biomass.
%
%   Equations and methods are taken from Hewitt et al. (2004), "Biomass of
%   Antarctic krill in the Scotia Sea in January/February 2000 and its use
%   in revising and estimate of precautionary yield."
%
%   Written by A. Cossio and C. Reiss, Jan 2016
%   Updated by J. Renfree, Feb 2016

% If no inputs are given, prompt user
if nargin == 0
    dname = uigetdir('', 'Pick directory containing CSV files to process');
    
    % If user pressed cancel, display and then exit
    if dname == 0
        disp('User pressed cancel. Processing aborted.')
        return
    end
end

% Prompt for conversion factor used to convert from area backscattering
% coefficient (s_a; m^2/m^2) to krill density (p; krill/km^2).
C = input('Please enter SDWBA conversion factor: ');

% If input is empty, abort processing
if isempty(C);
    disp('No Conversion Factor entered. Processing aborted');
    return
end

% Prompt for survey area in square kilometers
A_k = input('Please enter survey area in km^2: ');

% If input is empty, abort processing
if isempty(A_k);
    disp('No survey area entered. Processing aborted');
    return
end

% Find CSV files in given path
csvFiles = dir(fullfile(dname, '*.csv'));

% Preallocate NASC and count vectors
rho_j = nan(length(csvFiles),1);
L_j = nan(length(csvFiles),1);

% Loop through each file, which are considered transects, to get krill
% densities and transect lengths.
try                             % Use try/catch block to catch errors
    N_k = length(csvFiles);     % Define number of transects
    for i = 1:N_k
        [rho_j(i), L_j(i)] = calcDensity(fullfile(dname, csvFiles(i).name), C);
    end
catch ME                % If an error occurred, display message and abort
    disp(ME.message)
    return
end

%% Calculate overall survey parameters

% Compute normalized transect weighting factors (Equation 9)
w_j = L_j / mean(L_j);

% Compute mean krill biomass density for entire survey area (Equation 6)
rho_k = sum(w_j .* rho_j) / sum(w_j);

% Compute total biomass over entire survey area (Equation 11)
B_0 = A_k * rho_k;

% Compute variance of mean krill biomass density (Equation 13)
var_rho_k = sum(w_j.^2 .* (rho_j-rho_k).^2) / (N_k * (N_k-1));

% Compute biomass variance and CV
var_B_0 = var_rho_k * A_k^2;    	% Biomass variance
bio_cv = sqrt(var_B_0) / B_0;     	% CV of biomass estimate

%% Create results structure
results.conversionFactor = C;
results.surveyArea = A_k;
results.files = {csvFiles(:).name};
results.transectLengths = L_j;
results.transectKrillDensity = rho_j;
results.surveyLength = sum(L_j);
results.meanKrillDensity = rho_k;
results.krillDensityVariance = var_rho_k;
results.krillBiomass = B_0;
results.krillBiomassVariance = var_B_0;
results.krillBiomassCV = bio_cv;


function [rho_j, L_j] = calcDensity(file, C)
% calcDensity   Calculate transect density
%   [RHO_J,L_J]=ccamlr_biomass_transect(FILE, C) loads the CSV-file FILE to
%   obtain NASC values, which are then summed for each interval. The summed
%   NASCs are then converted to density, RHO_J, using the conversion
%   factor, C, and latitude-dependent weighting factors. The transect
%   length is returned in L_J.
%   
%   The CSV-file FILE must have the following headers and data columns, in
%   any order, in upper or lowercase:
%       Process ID
%       Interval
%       NASC
%       Depth
%       Lat_S
%       Lat_E
%       Lon_S
%       Lon_E
%       Lat_M
%       Lon_M

fid = fopen(file, 'rt');    % Open CSV file
header = fgetl(fid);        % Get header

% Split column names by commas and remove whitespace
header = strtrim(regexp(header, ',', 'split'));

% Define headers that we're interested in
headers = {'Process_ID' 'Interval' 'NASC' 'Depth_mean' 'Lat_S' 'Lon_S' ...
    'Lat_E' 'Lon_E' 'Lat_M' 'Lon_M'};

% Loop through each of the headers we're interested in and find out which
% column they are in.
idx = nan(length(headers), 1);      % Initialize indexing vector
for i = 1:length(headers)
    
    % Find which column that header resides
    temp = find(strcmpi(header, headers{i}) == 1);
    
    % If header wasn't found, throw error and exit
    if isempty(temp)
        fclose(fid);    % Close connection to file
        error(['Header ''%s'' not found in CSV file ''%s''. ' ...
            'Processing aborted.\n'], headers{i}, file);
        
    % Otherwise, store the result in our indexing vector
    else
        idx(i) = temp;
    end
end

% Create format string for reading data
fmt = repmat({'%*s'}, 1, length(header));
fmt(idx) = {'%f' '%f' '%f' '%f' '%f' '%f' '%f' '%f' '%f' '%f'};

data = textscan(fid, [fmt{:}], 'Delimiter', ',');	% Read data
fclose(fid);                                        % Close file

% Re-order data to our specifications
[~, I] = sort(idx);         % Sort the idx so we know the order
data = cell2mat(data(I));   % Re-order by the index

% Filter data to remove rows that have useless data
idx = data(:,2) == 0 ...        % Interval = 0
    | data(:,3) == -9999 ...    % NASC = -9999
    | data(:,4) == 0 ...        % Depth = 0
    | data(:,5) == 999 ...   	% Lat_S = 999
    | data(:,7) == 999;         % Lat_E = 999
data(idx,:) = [];

% Find the absolute difference between the start (Lat_S) and end (Lat_E)
% latitude of the transect
delta_initial = abs(data(1,5)-data(end,7));

% Find the distance in nautical miles between start and end points using
% the Haversine formula
[~, nmi] = haversine([data(1,5) data(1,6)], [data(end,7) data(end,8)]);

% Compute expected change in latitude for each nautical mile
e_d_lat = delta_initial/nmi ;

processID = unique(data(:,1));  % Find unique processIDs

% Compute total # of intervals by adding # of intervals for each Process ID
numInts = sum(arrayfun(@(x) length(unique(data(data(:,1) == x,2))), ...
    processID));

% Use that number to initialize the summed NASC and weighting variables
summedNASC = nan(numInts, 1);       % Interval NASCs (m^2 / n.mi^2)
W_I = nan(numInts, 1);   % Interval lengths (n.mi.)

% The entire file is considered a single transect, and we want to calculate
% krill density for each interval, however there could be multiple process
% IDs which share the same interval number. Therefore, we must separate
% intervals by also looking at Process IDs.
count = 0;
for i = 1:length(processID)         % Cycle through Process IDs
    
    % For that Process ID, find all unique Intervals
    intervals = unique(data(data(:,1) == processID(i),2));
    
    % Loop through all Intervals for that Process ID
    for j = 1:length(intervals)
        
        count = count + 1;  % Increment counter for indexing
        
        % Find all instances of that Interval for that Process ID
        idx = find(data(:,1) == processID(i) & data(:,2) == intervals(j));
        
        % Sum NASC for that interval
        summedNASC(count) = sum(data(idx,3));
        
        % Compute change in latitude
        d_lat = abs(data(idx(1), 7) - data(idx(1), 5));
        
        % Calculate weighting factor (Equation 7)
        W_I(count) = (e_d_lat - abs(e_d_lat-d_lat)) / e_d_lat;                
    end
end

% If deviation from standard track line is < 10%, then simply set
% weighting factor to 1
W_I(W_I >= 0.9) = 1;

% Compute transect length (n.mi.) by summing interval lengths (Equation 8)
L_j = sum(W_I); 

% Convert NASC to krill biomass density using weighting and conversion
% factors (Equation 10).
rho_j = sum(summedNASC .* W_I .* C) ./ L_j;


function [km, nmi, mi] = haversine(loc1, loc2)
% HAVERSINE     Compute distance between locations using Haversine formula
%   KM = HAVERSINE(LOC1, LOC2) returns the distance KM in km between
%   locations LOC1 and LOC2 using the Haversine formula.  LOC1 and LOC2 are
%   latitude and longitude coordinates that can be expressed as either
%   strings representing degrees, minutes, and seconds (suffixed with
%   N/S/E/W), or numeric arrays representing decimal degrees (where
%   negative indicates West/South).
%
%   [KM, NMI, MI] = HAVERSINE(LOC1, LOC2) returns the computed distance in
%   kilometers (KM), nautical miles (NMI), and miles (MI).
%
%   Examples
%       haversine('53 08 50N, 001 50 58W', '52 12 16N, 000 08 26E') returns
%           170.2547
%       haversine([53.1472 -1.8494], '52 12.16N, 000 08.26E') returns
%           170.2508
%       haversine([53.1472 -1.8494], [52.2044 0.1406]) returns 170.2563
%
%   Inputs
%       LOC must be either a string specifying the location in degrees,
%       minutes and seconds, or a 2-valued numeric array specifying the
%       location in decimal degrees.  If providing a string, the latitude
%       and longitude must be separated by a comma.
%
%       The first element indicates the latitude while the second is the
%       longitude.
%
%   Notes
%       The Haversine formula is used to calculate the great-circle
%       distance between two points, which is the shortest distance over
%       the earth's surface.
%
%       This program was created using equations found on the website
%       http://www.movable-type.co.uk/scripts/latlong.html

% Created by Josiah Renfree
% May 27, 2010

%% Check user inputs

% If two inputs are given, display error
if ~isequal(nargin, 2)
    error('User must supply two location inputs')
    
% If two inputs are given, handle data
else
    
    locs = {loc1 loc2};     % Combine inputs to make checking easier
    
    % Cycle through to check both inputs
    for i = 1:length(locs)
                
        % Check inputs and convert to decimal if needed
        if ischar(locs{i})
            
            % Parse lat and long info from current input
            temp = regexp(locs{i}, ',', 'split');
            lat = temp{1}; lon = temp{2};
            clear temp
            locs{i} = [];           % Remove string to make room for array
            
            % Obtain degrees, minutes, seconds, and hemisphere
            temp = regexp(lat, '(\d+)\D+(\d+)\D+(\d+)(\w?)', 'tokens');
            temp = temp{1};
            
            % Calculate latitude in decimal degrees
            locs{i}(1) = str2double(temp{1}) + str2double(temp{2})/60 + ...
                str2double(temp{3})/3600;
            
            % Make sure hemisphere was given
            if isempty(temp{4})
                error('No hemisphere given')

            % If latitude is south, make decimal negative
            elseif strcmpi(temp{4}, 'S')
                locs{i}(1) = -locs{i}(1);
            end
            
            clear temp

            % Obtain degrees, minutes, seconds, and hemisphere
            temp = regexp(lon, '(\d+)\D+(\d+)\D+(\d+)(\w?)', 'tokens');
            temp = temp{1};
            
            % Calculate longitude in decimal degrees
            locs{i}(2) = str2double(temp{1}) + str2double(temp{2})/60 + ...
                str2double(temp{3})/3600;
            
            % Make sure hemisphere was given
            if isempty(temp{4})
                error('No hemisphere given')
                
            % If longitude is west, make decimal negative
            elseif strcmpi(temp{4}, 'W')
                locs{i}(2) = -locs{i}(2);
            end
            
            clear temp lat lon
        end
    end
end

% Check that both cells are a 2-valued array
if any(cellfun(@(x) ~isequal(length(x),2), locs))
    error('Incorrect number of input coordinates')
end

% Convert all decimal degrees to radians
locs = cellfun(@(x) x .* pi./180, locs, 'UniformOutput', 0);

%% Begin calculation
R = 6371;                                   % Earth's radius in km
delta_lat = locs{2}(1) - locs{1}(1);        % difference in latitude
delta_lon = locs{2}(2) - locs{1}(2);        % difference in longitude
a = sin(delta_lat/2)^2 + cos(locs{1}(1)) * cos(locs{2}(1)) * ...
    sin(delta_lon/2)^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
km = R * c;                                 % distance in km

%% Convert result to nautical miles and miles
nmi = km * 0.539956803;                     % nautical miles
mi = km * 0.621371192;                      % miles