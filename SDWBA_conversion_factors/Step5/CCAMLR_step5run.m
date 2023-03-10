% CCAMLR_step5run
%
% Script to create a modelled dB dif (120-38) distribution from observed
% length frequency pdf (which is called ...)
%
% SOF 24 MAY 2010 BAS
%
clear 
% Get length frequency data
load C:\Github\glider_processing_code\SDWBA_conversion_factors\Step5\LF_pdf_clusters_vweighted.txt % krill length-frequencies by cluster
lf = LF_pdf_clusters_vweighted;

load C:\Github\glider_processing_code\SDWBA_conversion_factors\Step4\SDWBATS_L1m_\TS_length_allOrients_fin.mat

    % need to change this line here to allow for multiple T options
    %load CCAMLR_step4\allorientations_full_corr_T5.mat

    % note to self - need to make sure that this matches to previously set
    % orientaitons otherwise will fall over or be wrong!
    stdorientation = [1:1:50]; % THIS MUST BE CONSISTENT WITH CCAMLR_step4
    meanorientation = [-45:1:45];
    krill_ls = [10:65]*1e-3; % krill length (m) frequencies model run over MUST BE CHANGED IF THIS CHANGES 
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
    db_range = [2:1:15];
    % Rounding down to the nearest integer - as assuming that when data is
    % selected between 2 and 16 it is contained by those integers
    dbdif_mod2r = floor(dbdif_mod2);
    dbdif_mod3r = floor(dbdif_mod3);
    dbdif_calc = zeros(length(db_range),length(meanorientation),length(stdorientation));
    % Calculate from frequency of lf
    for i = 1:length(meanorientation)
        for j = 1:length(stdorientation)
            for m = 1:length(db_range)
                [ax,by] = find(dbdif_mod2r(:,i,j)==db_range(m));
                lfreq_q = zeros(1,length(krill_ls))';
                for numa = 1:length(ax)
                    lfreq_q(ax(numa)) = lf(ax(numa),2);
                end
                dbdif_calc(m,i,j) = nansum(lfreq_q);
            end
        end
    end
    %now standardise pdf to make it add up to 1
    dbdif_calcs = dbdif_calc;
    for i = 1:length(meanorientation)
        for j = 1:length(stdorientation)
            db_sum = nansum(dbdif_calc(:,i,j));
           for m = 1:length(db_range)
               dbdif_calcs(m,i,j) = dbdif_calc(m,i,j)/db_sum;
           end
        end
    end
    dbdif_calc = dbdif_calcs;
    save all_db_diffs_calc_Ldata_fin.mat db_range dbdif_calc -MAT;




