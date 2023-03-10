% CCAMLR_step7run
%
% Create matlab file of TS versus length for each frequency and dB
% differences to calculate dB window pairs and krill biomass
%
clear
%
% Load file of orientations estimated from CCAMLR_step6run
load C:\Github\glider_processing_code\SDWBA_conversion_factors\Step6\CCAMLR_orientations_Ldata_fin.mat;
%
% run script through the different SDWBA parameter runs from 1 to 9
%for igo = 1:1:9;
 %   eval(['load F:\CAMLR\June_reanalysis\CCAMLR_step4\allorientations_full_corr_T',num2str(igo),'.mat;']);
 load  C:\Github\glider_processing_code\SDWBA_conversion_factors\Step4\TS_length_allOrients_fin.mat
 % identify mean orientation and std orientation from data
    orient_mean = Orient_vals(2,1);
    krill_ls = [10:65];
    % add in the square root of n multiplier here to get orientation SD
    % rather than SE. Where n is 50 as assumed to be number of pings
    % ensemble averaged over
    orient_std = Orient_vals(3,1)*(sqrt(50));
    orient_std = round(orient_std);
    % now find length and correct TS values for those lengths from the
    % allorientations_full_corr_T?.mat file remembering that in that file
    % any negative values of orientation are actually 360 + negative orientation
    %if orient_mean > 0;
    %    orient_mean = orient_mean;
    %else orient_mean < 0;
    %    orient_mean = 360 + orient_mean;
    %end    stdorientation=[1:1:45];
    meanorientation = [-45:1:45];
    dbdif_mod2 = ones(length(krill_ls),length(meanorientation),length(stdorientation)); %120-38 kHz TS
    dbdif_mod3 = ones(length(krill_ls),length(meanorientation),length(stdorientation)); % 200-120 kHz TS
    
    for i = 1:length(meanorientation)
        for j = 1:length(stdorientation)
            for kril = 1:length(krill_ls)
                dbdif_mod2(kril,i,j) = F120_TS(kril,i,j) - F38_TS(kril,i,j);
                dbdif_mod3(kril,i,j) = F200_TS(kril,i,j) - F120_TS(kril,i,j);
            end
        end
    end
    posc = find(meanorientation == orient_mean);
    T_TS = zeros(5,length(F120_TS(:,1,1)));
   % freq3 = [38 120 200];
   freq3 = [38 120 200 67 70 74 82 91 99 108 120 125]; 
   % for anum = 1:3
   for anum = 1:length(freq3)
        eval(['T_TS(anum,:,:) = F',num2str(freq3(anum)),'_TS(:,posc,orient_std);']);
    end
    T_TS(4,:,:) = dbdif_mod2(:,posc,orient_std);
    T_TS(5,:,:) = dbdif_mod3(:,posc,orient_std);
    
        
    %eval(['T',num2str(igo),'_TS = len.TS_',num2str(orient_mean),'_',num2str(orient_std),';']);
%end

save TS_krill_length_values_alt_fin.mat krill_ls T_TS -MAT