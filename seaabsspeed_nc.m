function [Freq,seaAbs, seaC] = seaabsspeed_nc(netcd,date_ST, date_ED)

% Get absorption coefficent and sound speed from Slocum glider processed
% NetCDF file created using the Pyglider code. Put in a start and end date (ie 20180625)and  
% it will get the mean Temp, Salinity, Pressure, and Conductivity. Uses
% formulas from ASL code (LoadAZFP.m) to calculate SS and absorption.
% A Cossio 10/24/2018
% A Cossio 5/12/22 added frequencies from the Nortek
% A Cossio 2/9/23 added AZFP frequencies
% A Cossio 4/4/2025 converted from Socib mat file to NetCDF

% If no inputs are given, prompt user
if nargin == 0
        [FileName,PathName] = uigetfile('*.nc','Pick glider NetCDF file to process');
    % If user pressed cancel, display and then exit
    if FileName == 0
        disp('User pressed cancel. Processing aborted.')
        return
    end
end
% Prompt for start date range.
date_ST = input('Please enter start date (YYYYMMDD): ');

% If input is empty, abort processing
if isempty(date_ST)
    disp('No start date entered. Processing aborted');
    return
end

% Prompt for end date range.
date_ED = input('Please enter end date (YYYYMMDD): ');

% If input is empty, abort processing
if isempty(date_ED)
    disp('No end date entered. Processing aborted');
    return
end


netcd = fullfile(PathName,FileName); % puts the path and file name together
ncid = netcdf.open(netcd,'NC_NOWRITE'); % Open nc file

yrs = datestr(epoch2datenum(netcdf.getVar(ncid,24)),'yyyymmdd') ; % get out the date and make it a number
dte = str2num(yrs); %convert from string to number

% data for date, temp, cond, salinity, depth
mydata = [dte netcdf.getVar(ncid,5) netcdf.getVar(ncid,4) netcdf.getVar(ncid,7) netcdf.getVar(ncid,2)];

bb = mydata(:,1) > date_ST & mydata(:,1) < date_ED; % find data between 
% subset of data based on date range
mydata01=mydata(bb,:);

T = mean(mydata01(:,2),'omitnan'); % mean temperature
C = mean(mydata01(:,3),'omitnan'); % mean conductivity
S = mean(mydata01(:,4),'omitnan'); % mean salinity
P = mean(mydata01(:,5),'omitnan'); % mean depth

% function seaAbs = computeAbs(T,P,S,Freq)
Freq = [38 67 70 74 82 91 99 108 120 125];
% calculate relaxation frequencies
T_K = T + 273.0;
f1 = 1320.0*(T_K)*exp(-1700/T_K);
f2 = (1.55e7)*T_K*exp(-3052/T_K);

% coefficients for absorption equations
k = 1 + P/10.0;
a = (8.95e-8)*(1+T*((2.29e-2)-(5.08e-4)*T));
b = (S/35.0)*(4.88e-7)*(1+0.0134*T)*(1-0.00103*k+(3.7e-7)*(k*k));
c = (4.86e-13)*(1+T*((-0.042)+T*((8.53e-4)-T*6.23e-6)))*(1+k*(-(3.84e-4)+k*7.57e-8));
freqk = Freq*1000;
seaAbs = (a*f1*(freqk.^2))./((f1*f1)+(freqk.^2))+(b*f2*(freqk.^2))./((f2*f2)+(freqk.^2))+c*(freqk.^2);

% sound speed calcuation from LoadAZFP.m
% function seaC = computeSS(T,P,S)

z = T/10;
seaC = 1449.05+z*(45.7+z*((-5.21)+0.23*z))+(1.333+z*((-0.126)+z*0.009))*(S-35.0)+(P/1000)*(16.3+0.18*(P/1000));
S
T
Freq
seaAbs
seaC
