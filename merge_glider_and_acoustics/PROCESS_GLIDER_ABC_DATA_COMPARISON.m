cd 'E:\ANTARCTIC_DEPLOYMENTS\AMLR2023_2024\Data'

amlr03=load('AMLR03_23_24_ABC.mat');
%amlr03=RenameField(amlr03,'gridded_glider_abc_survey', 'data');

%amlr04=load('AMLR04_23_24_CAL03.mat');
amlr04=load('AMLR04_23_24_ABC.mat');
%amlr04=RenameField(amlr04,'gridded_glider_abc_survey', 'data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK CALCS AGAINST INTEGRATED PROFILES
%int_abc_03=nansum(amlr03.data.ABC,1);
%int_abc_04=nansum(amlr04.data.ABC,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int_abc_03 = sum(amlr03.gridded_glider_abc_survey.ABC,"omitnan");
int_abc_04 = sum(amlr04.gridded_glider_abc_survey.ABC,"omitnan");

figure(1)
%subplot(2,1,1)
edges = [-9:0.5:-4];
histogram(log10(int_abc_03),edges,'Normalization','pdf','FaceColor','k', 'FaceAlpha',0.4)
hold on
%subplot(2,1,2)
histogram(log10(int_abc_04),edges,'Normalization','pdf','FaceColor','r', 'FaceAlpha',0.1) %, 'DisplayStyle','stairs')
legend('AMLR03','AMLR04')
xlabel ('Log10 ABC')
ylabel('Frequency (PDF)')

figure(2)
%subplot(2,1,1)
edges = [-9:0.5:-4];
ecdf(log10(int_abc_03))%,edges,'Normalization','pdf','FaceColor','k', 'FaceAlpha',0.4)
hold on
%subplot(2,1,2)
ecdf(log10(int_abc_04))%,edges,'Normalization','pdf','FaceColor','r', 'FaceAlpha',0.1) %, 'DisplayStyle','stairs')
legend('AMLR03','AMLR04')

%[outdata_04]=BOOSTRP_SPATIAL_GLIDER_ESTIMATES(amlr04.data.glider_latitude, amlr04.data.glider_longitude, int_abc_04,1);
%[outdata_03]=BOOSTRP_SPATIAL_GLIDER_ESTIMATES(amlr03.data.glider_latitude, amlr03.data.glider_longitude, int_abc_03,1);
[outdata_04]=BOOSTRP_SPATIAL_GLIDER_ESTIMATES(amlr04.gridded_glider_abc_survey.glider_latitude, amlr04.gridded_glider_abc_survey.glider_longitude, int_abc_04,1);
[outdata_03]=BOOSTRP_SPATIAL_GLIDER_ESTIMATES(amlr03.gridded_glider_abc_survey.glider_latitude, amlr03.gridded_glider_abc_survey.glider_longitude, int_abc_03,1);


m_03_b = bootstrp(1000,@mean,outdata_03(:,3)); % bootstrap
m_04_b = bootstrp(1000,@mean,outdata_04(:,3)); % bootstrap

m_03_bci = bootci(1000,@mean,outdata_03(:,3)); % bootstrap confidence intervals
m_04_bci = bootci(1000,@mean,outdata_04(:,3)); % bootstrap confidence intervals

