% CCAMLR_step6run
%
% Run orientation inversion process. Estimate best fit of modelled to
% observed db differences using least squares sense analysis
%
% SOF 25 MAY 2010 BAS

clear

% load TS to L relationship for all orientations etc - again this will be a
% T1 to T9 option eventually to cover all shape/fatness parameters

Orient_vals = zeros(3,1);


    load C:\Github\glider_processing_code\SDWBA_conversion_factors\Step6\CCAMLR_db_freqs_obs_all.mat;
    % Undelete two lines below to investigate yuz data effects
    %load CCAMLR_step3\CCAMLR_db_freqs_obs_yuz.mat;
    %db_freq_obs = db_freq_obs_yuz;
    % Load modelled options
    load C:\Github\glider_processing_code\SDWBA_conversion_factors\Step5\all_db_diffs_calc_Ldata_fin.mat;
    chisq_temp = ones(size(dbdif_calc(:,:,:)));
    stdorientation = [1:1:50];
    meanorientation = [-45:1:45];
    for i = 1:length(meanorientation)
        for j = 1:length(stdorientation)
            for m = 1:length(db_range)
                chisq_temp(m,i,j) = ((db_freq_obs(m) - dbdif_calc(m,i,j)).^2);
            end
        end
    end
    chites = zeros(size(chisq_temp(1,:,:)));
    for i = 1:length(meanorientation)
        for j = 1:length(stdorientation)
            chites(1,i,j) = nansum(chisq_temp(:,i,j));
        end
    end
    [pl1 pl2] = nanmin(chites);
    [pl3 pl4] = min(pl1);
    sprintf(strcat('Best fit from mean orientation:',num2str(meanorientation(pl2(pl4))),' Std orientation:',num2str(stdorientation(pl4))))
    Orient_vals(1,1) = 1;
    Orient_vals(2,1) = meanorientation(pl2(pl4));
    Orient_vals(3,1) = stdorientation(pl4);
    %eval(['T',num2str(igo),'_orient_mean = ',num2str(meanorientation(pl2(pl4))),';']);
    %eval(['T',num2str(igo),'_orient_std = ',num2str(stdorientation(pl4)),';']);
    figure(1)
    plot(db_range,db_freq_obs,'-*');
    hold on
    plot(db_range,dbdif_calc(:,pl2(pl4),pl4),'k');
    xlabel('120-38 Sv dB window')
    ylabel('probability')
    legend('Observed dB distribution','Modelled distribution N[-20,28]')

save CCAMLR_orientations_Ldata_fin.mat Orient_vals