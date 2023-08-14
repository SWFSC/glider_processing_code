
% Make a bunch of figures for the Glider paper - CSR

%Load the combined acoustic and glider data. This is from using the code
%XX, XX, XX
%load('F:\ANTARCTIC_DEPLOYMENTS\AMLR2018_2019\AMLR02\gridded_AMLR02_AZFP_ABC_1m_bins.mat');
load('C:\Work\AMLR19_workup\AMLR01\output\1mx1m\gridded_AMLR01_AZFP_ABC_2019_1000m.mat');
%bs_locs=xlsread('C:\Users\CSR\Documents\MATLAB\GLIDER_AZFP_CODE\azfp_glider_merge\AMLR_SHIP_BRANSFIELD.xlsx');

% remove deep_data_spike code

remove_deep_data_spikes_01

% remove zeros and convert to NaN 
% 2/4/22 AMC this is an issue with schools.

% clean_125(clean_125==0)=NaN;
% clean_67(clean_67==0)=NaN;
% clean_38(clean_38==0)=NaN;

%%
% load the UFFs
load('C:\Work\AMLR19_workup\AMLR01\UFF_Copa_2018_19.mat')
UFF= UFF_Copa;
%UFF=[5.7717e+07; 1.7132e+07;  2.2181e+07]; 

% Figure 1 - Log transformed acoustic data for all 3 frequencies for the
% entire survey
figure(1)

subplot(3,1,1)
ax(1)=pcolor([1:length(gridded_AMLR01_AZFP_ABC.num_pings_profil_gd)],-1*gridded_AMLR01_AZFP_ABC.zbins_gd(2:end),log10(clean_125));
shading flat
title ('125 kHz ABC')
xlabel('Profile number')
ylabel('Depth 1m bins')
colorbar
f=colorbar ;
f.Label.String=' log10 ABC -- 125 kHz' ;

subplot(3,1,2)
ax(2)=pcolor([1:length(gridded_AMLR01_AZFP_ABC.num_pings_profil_gd)],-1*gridded_AMLR01_AZFP_ABC.zbins_gd(2:end),log10(clean_67));
shading flat
colorcet('BWRA')
title ('67 kHz ABC')
xlabel('Profile number')
ylabel('Depth 1m bins')
colorbar
f=colorbar;
f.Label.String=' log10 ABC -- 67 kHz';


subplot(3,1,3)
ax(3)=pcolor([1:length(gridded_AMLR01_AZFP_ABC.num_pings_profil_gd)],-1*gridded_AMLR01_AZFP_ABC.zbins_gd(2:end),log10(clean_38));
shading flat
colorcet('BWRA')
title ('38 kHz ABC')
xlabel('Profile number')
ylabel('Depth 5m bins')
colorbar
f=colorbar;
f.Label.String=' log10 ABC -- 38 kHz';


%%

%Calculate some biomasses for each of the frequencies

nasc67_int=nansum(clean_67(2:201,3:end)); % is this only to 200m? AMC 2/11/20
nasc67_int(nasc67_int==0)=NaN; % amc 2/2/22 could also be an issue with schools
gm2_67=nasc67_int*UFF.ans(2,2);
mean_gm2_67=nanmean(gm2_67);
biomass67=(mean_gm2_67*3.3e+9)/1.0e+6 % check area of BS 2/11/20
 
nasc38_int=nansum(clean_38(2:201,3:end));
nasc38_int(nasc38_int==0)=NaN; % amc 2/2/22 could also be an issue with schools
gm2_38=nasc38_int*UFF(1);
mean_gm2_38=nanmean(gm2_38);
biomass38=(mean_gm2_38*3.3e+9)/1.0e+6

nasc125_int=nansum(clean_125(2:201,3:end));
nasc125_int(nasc125_int==0)=NaN; % amc 2/2/22 could also be an issue with schools
gm2_125=nasc125_int*UFF.ans(3,2);
mean_gm2_125=nanmean(gm2_125);
biomass125=(mean_gm2_125*3.3e+9)/1.0e+6


%%
% Figure 2 - Scatter plot of density biomass of the 38 kHz acoustics
figure(2)
m_proj('lambert','longitudes',[-62 -56.5],'latitudes',[-64 -62])
m_grid('box','on','xtick',16)
m_tbase('contour',[-500 -1000 -3000],'edgecolor','k')
%m_plot(bs_locs(:,1) ,bs_locs(:,2),'k')
m_gshhs_h('patch',[.7 .7 .7],'edgecolor','k')
m_scatter(gridded_AMLR01_AZFP_ABC.avg_lon_gd(3:end),gridded_AMLR01_AZFP_ABC.avg_lat_gd(3:end),sqrt(gm2_38)+0.00001,'filled')
m_plot(gridded_AMLR01_AZFP_ABC.avg_lon_gd, gridded_AMLR01_AZFP_ABC.avg_lat_gd)
colorcet('BWG')
title('Integrated biomass (g m-2) -- 38 kHz')

%%
% Figure 3 -Scatter plot of density biomass of the 67 kHz acoustics

figure(3) 
m_proj('lambert','longitudes',[-62 -56.5],'latitudes',[-64 -62])
m_grid('box','on','xtick',16)
m_tbase('contour',[-500 -1000 -3000],'edgecolor','k')
%m_plot(bs_locs(:,1) ,bs_locs(:,2),'r')
m_gshhs_h('patch',[.7 .7 .7],'edgecolor','k')
m_scatter(gridded_AMLR01_AZFP_ABC.avg_lon_gd(3:end), gridded_AMLR01_AZFP_ABC.avg_lat_gd(3:end),sqrt(gm2_67)+0.00001,'filled')
m_plot(gridded_AMLR01_AZFP_ABC.avg_lon_gd, gridded_AMLR01_AZFP_ABC.avg_lat_gd)
colorcet('BWG')
title('Integrated biomass (g m-2) -- 67 kHz')

%%
% Figure 4 -Scatter plot of density biomass of the 125 kHz acoustics

figure(4) 

m_proj('lambert','longitudes',[-62 -56.5],'latitudes',[-64 -62])
m_grid('box','on','xtick',16)
m_tbase('contour',[-500 -1000 -3000],'edgecolor','k')
%m_plot(bs_locs(:,1) ,bs_locs(:,2),'r')
m_gshhs_h('patch',[.7 .7 .7],'edgecolor','k')
m_scatter(gridded_AMLR01_AZFP_ABC.avg_lon_gd(3:end), gridded_AMLR01_AZFP_ABC.avg_lat_gd(3:end),sqrt(gm2_125)+0.00001,'filled')
m_plot(gridded_AMLR01_AZFP_ABC.avg_lon_gd, gridded_AMLR01_AZFP_ABC.avg_lat_gd)
colorcet('BWG')
title('Integrated biomass (g m-2) --125 kHz')
 
%%
% Figure 10 - Temperature and Salinity plot with g/m2 67 kHz plot and TS
% plot with log Chl a
figure (10)
%TS Plot
subplot(1,2,1)
scatter(gridded_AMLR01_AZFP_ABC.glider_salinity(:),gridded_AMLR01_AZFP_ABC.glider_temperature(:),6,log10(clean_67(:)*UFF(2)),'filled') %clean_67 has extra row... need to redo data to 1010m
colorcet('BWG')
f=colorbar
f.Label.String=' gm (m-2) -- 67 kHz'
%caxis([0 0.1])
ylabel('Temperature (C)')
xlabel('Salinity')

subplot(1,2,2)
scatter(gridded_AMLR01_AZFP_ABC.glider_salinity(:),gridded_AMLR01_AZFP_ABC.glider_temperature(:),6,log10(gridded_AMLR01_AZFP_ABC.glider_chlorophyll(:)),'filled')
colorcet('BWG')
f=colorbar
f.Label.String=' Log10 chlorophyll-a'
ylabel('Temperature (C)')
xlabel('Salinity')

%%
% Figure 11 - Log 67 kHz density vs chl a, chl a vs temp, 
figure(11)
subplot(2,2,1)
plot((nansum(gridded_AMLR01_AZFP_ABC.glider_chlorophyll(1:101,:))),log10(nansum((clean_67(6:201,:)*(UFF(2))))),'.')
ylabel('gm (m-2) -- 67 kHz')
xlabel('Chlorophyll-a')

subplot(2,2,2)
plot((nanmean(gridded_AMLR01_AZFP_ABC.glider_temperature(1:101,:))),nanmean(gridded_AMLR01_AZFP_ABC.glider_chlorophyll(1:101,:)),'.')
ylabel('Chlorophyll-a')
xlabel('Temperature')

subplot(2,2,3)
plot((nanmean(gridded_AMLR01_AZFP_ABC.glider_temperature(1:101,:))),log10(nansum((clean_67(6:201,:)*UFF(2)))),'.')
ylabel('gm (m-2) -- 67 kHz')
xlabel('Temperature')

subplot(2,2,4)
plot((nanmean(gridded_AMLR01_AZFP_ABC.glider_salinity(1:101,:))),log10(nansum((clean_67(6:201,:)*UFF(2)))),'.')
ylabel('gm (m-2) -- 67 kHz')
xlabel('Salinity')

%%
% Figure 14 - glider track comparison of first and second times of CS
% survey
% figure(14)
% m_proj('lambert','longitudes',[-62 -56.5],'latitudes',[-64 -62])
% m_grid('box','on','xtick',16)
% m_tbase('contour',[-500 -1000 -3000],'edgecolor','k')
% m_gshhs_h('patch',[.7 .7 .7],'edgecolor','k')
% m_plot(gridded_AMLR01_AZFP_ABC.avg_lon_gd(1:400), gridded_AMLR01_AZFP_ABC.avg_lat_gd(1:400),'k')
% hold on
% m_plot(gridded_AMLR01_AZFP_ABC.avg_lon_gd(445:1000), gridded_AMLR01_AZFP_ABC.avg_lat_gd(445:1000),'r')

%%
%first survey of Cape Shirreff biomass calculations

% gm2_67_surv_02_1=nasc67_int(1:400)*UFF(2);
% mean_gm2_67_surv_02_1=nanmean(gm2_67_surv_02_1)
% biomass67_surv_02_1=(mean_gm2_67_surv_02_1*3.3e+9)/1.0e+6
% 
% 
% gm2_125_surv_02_1=nasc125_int(1:400)*UFF(3);
% mean_gm2_125_sur_02_1=nanmean(gm2_125_surv_02_1)
% biomass125_surv_02_1=(mean_gm2_125_sur_02_1*3.3e+9)/1.0e+6
% 
% 
% gm2_38_surv_02_1=nasc38_int(1:400)*UFF(1);
% mean_gm2_38_surv_02_1=nanmean(gm2_38_surv_02_1)
% biomass38_surv_02_1=(mean_gm2_38_surv_02_1*3.34e+9)/1.0e+6

%%
%Second pass through CS biomass calculations

% gm2_67_surv2_02=nasc67_int(445:1000)*UFF(2);
% mean_gm2_67_surv2_02=nanmean(gm2_67_surv2_02)
% biomass67_surv2_02=(mean_gm2_67_surv2_02*3.3e+9)/1.0e+6
% 
% 
% gm2_125_surv2_02=nasc125_int(445:1000)*UFF(3);
% mean_gm2_125_surv2_02=nanmean(gm2_125_surv2_02)
% biomass125_surv2_02=(mean_gm2_125_surv2_02*3.3e+9)/1.0e+6
% 
% 
% gm2_38_surv2_02=nasc38_int(445:1000)*UFF(1);
% mean_gm2_38_surv2_02=nanmean(gm2_38_surv2_02)
% biomass38_surv2_02=(mean_gm2_38_surv2_02*3.3e+9)/1.0e+6

%%
% Figure 15 -
figure(15)
subplot(3,1,1)
ax(1)=pcolor([1:684],-1*gridded_AMLR01_AZFP_ABC.zbins_gd,log10(clean_67))
shading flat

title ('67 kHz ABC South Area All profiles')
xlabel('Profile number')
ylabel('Depth 1m bins')
colorbar('Ticks',[-16:4:-4])
f=colorbar
f.Label.String=' log10 ABC'

subplot(3, 1,2)
ax(2)=pcolor([1:300],-1*gridded_AMLR01_AZFP_ABC.zbins_gd,log10(clean_67(:,1:300)))
shading flat
colorcet('BWRA')
title ('67 kHz ABC South Area 300 profiles')
xlabel('Profile number')
ylabel('Depth 1m bins')
colorbar('Ticks',[-16:4:-4])
f=colorbar;
f.Label.String=' log10 ABC'


subplot(3, 1,3)
ax(3)=pcolor([150:300],-1*gridded_AMLR01_AZFP_ABC.zbins_gd,log10(clean_67(:,150:300)))
shading flat
colorcet('BWRA')
title ('67 kHz ABC South Area 150 profiles')
xlabel('Profile number')
ylabel('Depth 1m bins')
colorbar('Ticks',[-16:4:-4])
f=colorbar
f.Label.String=' log10 ABC'


%% Make a couple of plots of the means by time of day

dates=datevec(gridded_AMLR01_AZFP_ABC.avg_time_gd);

[mn_dly_67, sem_dly_67, gnames_dly_67 ]=grpstats(log10(nansum((clean_67(6:201,:)*UFF(2)))),dates(:,4), {'mean', 'sem','gname'});

[mn_dly_chl, sem_dly_chl, gnames_dly_67 ]=grpstats(nanmean(gridded_AMLR01_AZFP_ABC.glider_chlorophyll(1:100,:)),dates(:,4), {'mean', 'sem','gname'});

figure(14)
plot([0:23], mn_dly_chl)
xlabel('Hr of day')
ylabel('log10 biomass g m^-^2')


