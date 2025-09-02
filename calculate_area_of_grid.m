% Calculate the area of a grid on the Earth
R = 6371; % Radius of the Earth
Lat_N = ltgrid(1); % northern edge of grid
Lat_S = ltgrid(2); % southern edge of grid
Lon_E = llgrid(1); % eastern edge of grid
Lon_W = llgrid(2); % western edge of grid

% convert to radians
LN = Lat_N*pi/180; 
LS = Lat_S*pi/180;
LE = Lon_E*pi/180;
LW = Lon_W*pi/180;


LL_area = R^2*(sin(LN)-sin(LS))*(LE - LW)
