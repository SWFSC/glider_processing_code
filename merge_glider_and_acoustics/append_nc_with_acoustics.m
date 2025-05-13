% Append nc file created from pyglider with acoustic data output
% 

% read in nc grid-delayed-5m.nc from pyglider
[INFILE1, INPATH1] = uigetfile('*.nc;*.*', 'Select pyglider grid-delayed-5m.nc files.','MultiSelect', 'off');

filename = fullfile(INPATH1,INFILE1);
ni1 = ncinfo(filename);
for i=1:length(ni1.Variables)
    vn1 = ni1.Variables(i).Name;
    data_gridded.(vn1) = ncread(filename, vn1);  % The result is a structure 
end

%% 70kHz
% read in acoustic m file for all acoustic frequencies
[file,location] = uigetfile('*.mat;*.*', 'Select 70 kHz gridded mat.','MultiSelect', 'off');
gridded_70 = load(fullfile(location,file));
% create grid of NaNs for size of profiles and depth (profiles x depth)
mt = NaN(size(data_gridded.profile_index))';
% use profile number for index 
indx70 = gridded_70.gridded_glider_abc.avg_profile_num_gd;
% insert indexed profiles with abc
mt(:,indx70) = gridded_70.gridded_glider_abc.ABC; 
abc_70 = mt';
 % number of pings per profile
num_pings_profile70 = gridded_70.gridded_glider_abc.num_pings_profil_gd';
sz = size(abc_70); % get rows and column count for use with dimensions
% Define the new variable to append
nccreate(filename, "abc_70","Dimensions", {"time",sz(1),"depth",sz(2)},"Datatype", "double", "Format","netcdf4");
ncwrite(filename,"abc_70",abc_70)
fileattrib(filename,"+w");

% variable attributes
ncwriteatt(filename,'abc_70','units','m2 m-2')
ncwriteatt(filename,'abc_70','platform','platform')
ncwriteatt(filename,'abc_70','long_name','area backscatter coefficeient of 70 kHz')
ncwriteatt(filename,'abc_70','instrument','insturment_echosounder') 
ncwriteatt(filename,'abc_70','comment','ABC values in 5m bins of acoustic data exported from Echoview. Acoustic data was cleaned of background noise and impulse noise. Full energy from Sv was exported in 5m x 5m bins.')

nccreate(filename, "num_pings_profile_70","Dimensions", {"time",sz(1)},"Datatype", "double", "Format","netcdf4");
ncwrite(filename,'num_pings_profile_70',num_pings_profile70)
ncwriteatt(filename,'num_pings_profile_70','comment','The number of acoustic pings per profile')
ncwriteatt(filename,'num_pings_profile_70','units','number')


%% 120kHz
[file1, location1] = uigetfile('*.mat;*.*', 'Select 120 kHz gridded mat.','MultiSelect', 'off');
gridded_120 = load(fullfile(location1,file1));
mt120 = NaN(size(data_gridded.profile_index))';
indx120 = gridded_120.gridded_glider_abc.avg_profile_num_gd;
% insert indexed profiles with abc
mt120(:,indx120) = gridded_120.gridded_glider_abc.ABC; 
abc_120 = mt120';
 % number of pings per profile
num_pings_profile120 = gridded_120.gridded_glider_abc.num_pings_profil_gd';
sz120 = size(abc_120); % get rows and column count for use with dimensions

% Define the new variable to append
nccreate(filename, "abc_120","Dimensions", {"time",sz120(1),"depth",sz120(2)},"Datatype", "double", "Format","netcdf4");
ncwrite(filename,"abc_120",abc_120)
fileattrib(filename,"+w");

% variable attributes
ncwriteatt(filename,'abc_120','units','m2 m-2')
ncwriteatt(filename,'abc_120','platform','platform')
ncwriteatt(filename,'abc_120','long_name','area backscatter coefficeient of 120 kHz')
ncwriteatt(filename,'abc_120','instrument','insturment_echosounder') 
ncwriteatt(filename,'abc_120','comment','ABC values in 5m bins of acoustic data exported from Echoview. Acoustic data was cleaned of background noise and impulse noise. Full energy from Sv was exported in 5m x 5m bins.')


nccreate(filename, "num_pings_profile_120","Dimensions", {"time",sz120(1)},"Datatype", "double", "Format","netcdf4");
ncwrite(filename,'num_pings_profile_120',num_pings_profile120)
ncwriteatt(filename,'num_pings_profile_120','comment','The number of acoustic pings per profile')
ncwriteatt(filename,'num_pings_profile_120','units','number')





