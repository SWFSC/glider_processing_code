function [outdata]=BOOSTRP_SPATIAL_GLIDER_ESTIMATES(lats, lons, int_abc_in, yes_no)

% This function recodes glider acoustic data from a deployment into binned
% data on a foixed but user definable size spatial grid. 
% The goal is to generate a smoothed glider deployment where over sampling
% in regions where the glider was stuck, or resampled when areas were
% sampled more than once could provide a bias in the data set.

% The output of this can be used as necessary for example by bootstrapping
% to generate a biomass density estimate that breaks up the spatial
% autocorrelation. 

% Inputs are the latitudes and longitude of each profile as well as the
% integrated ABCs for each profile. yes_no= 1 = print; 0 = no print

% Load the data of the gridded acoustic abc data that is in profiles

% Requires M_Map for mapping https://www.eoas.ubc.ca/~rich/map.html
% Requires nearxy.m 
% C Reiss 06/06/2024
%%%%%%%%%%%%
%
% Select the file that you wish to open
%

%lats_gliders=amlr04.data.glider_latitude;
%lons_gliders=amlr04.data.glider_longitude;
%int_abc=int_abc_04;

lats_gliders=lats;
lons_gliders=lons;
int_abc=int_abc_in;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Generate a grid of useful size
%  Here that is 0.1 degrees
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Convert the groups where there are data back to numbers

llgrid=[-62.0:0.1:-56.8];
ltgrid=[-64:0.1:-62];

[xigrid,yigrid] = meshgrid(llgrid,ltgrid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Here is a figure of the grid on a map
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(2)
% m_proj('lambert','longitudes',[-63. -56.5],'latitudes',[-64 -61.5])
% m_grid('box','on','xtick',8)
% m_etopo2('contour',[-100: -500 : -3000],'edgecolor',[.7 .7 .7]);
% %m_etopo2('contourf',[-100: -200 : -6000],'edgecolor','none');
% 
% m_gshhs_h('patch',[.7 .7 .7],'edgecolor','k')
% colorcet('L6')
% brighten(0.5)
% 
% 
% m_plot(xigrid(:),yigrid(:),'.r')
% % m_scatter(lons_gliders,lats_gliders,5,10*gliders_wk)
% m_plot(lons_gliders,lats_gliders,'*b')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Now get the lats and the lons of each dive within
%  area defined by the grid above, and make sure that
%  data outside the bounds is removed.. perhaps using
%  tolerance to get rid of last few data points
% (here I havent removed the last few data yet)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Now reshape the grid
[rgrid,cgrid]=size(xigrid);
lonsgrid=reshape(xigrid,rgrid*cgrid,1);
latsgrid=reshape(yigrid,rgrid*cgrid,1);

%Now find the profile locations closest to the gridded locations
for i=1:length(lons_gliders);
[indexglider,distanceglider]=nearxy(lons_gliders(i),lats_gliders(i),lonsgrid,latsgrid);
idxglider(i)=[indexglider];
end


%generate the new gridded profile locations
new_lonsglider=lonsgrid(idxglider');
new_latsglider=latsgrid(idxglider');

%Now calculate the spatial mean ABC

[mfish,sumfish,vfish,sfish,nufish,gfish] = grpstats([int_abc'],{[new_lonsglider] [new_latsglider]},{'mean','sum','var','sem','numel','gname'}) 


%Convert the groups where there are data back to numbers
for j=1:length(gfish)
grd_lon=str2num(gfish{j,1});
grd_lat=str2num(gfish{j,2});

%cc=str2num(gfish{j,3});
grid_pntsglider(j,:)=[grd_lon;grd_lat];
%weeks(j)=cc;
end

outdata=[grid_pntsglider mfish vfish nufish];

if yes_no == 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Here is a figure of the grid on a map
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
m_proj('lambert','longitudes',[-63. -56.5],'latitudes',[-64 -61.5])
m_grid('box','on','xtick',8)
m_etopo2('contour',[-100: -500 : -3000],'edgecolor',[.7 .7 .7]);
%m_etopo2('contourf',[-100: -200 : -6000],'edgecolor','none');

m_gshhs_h('patch',[.7 .7 .7],'edgecolor','k')
colorcet('L6')
brighten(0.5)


m_plot(xigrid(:),yigrid(:),'.r')
m_plot(lons_gliders,lats_gliders,'*b')
m_plot(grid_pntsglider(:,1),grid_pntsglider(:,2),'^y')

end

