% Create file of TS of krill from lengths (not adjusting frequency)
%
% Load in each file and name the BSTS component
%
clear 
% Create matrix to fill with data
freq_u = [38 70 120 200 333 67 125 74 82 91 99 108];
krill_ls = [10:65]*1e-3; % krill length (m) frequencies model run over MUST BE CHANGED IF THIS CHANGES 
for ifre = 1:length(freq_u)
    eval(['F',num2str(freq_u(ifre)),'_TS = zeros(length(krill_ls),91,45);']);
    eval(['F',num2str(freq_u(ifre)),'_sigma = zeros(length(krill_ls),91,45);']);
end
% Step one need to load the file of data for this - presume it is *_L*
for igo = 1:length(krill_ls)
    igo_num = krill_ls(igo)*1e3;
    eval(['load SDWBATS_L1m_',num2str(igo_num),'.mat;']);
    % Orientation distribution
    c = 1456;
    % Set st deviation to range from 1 - 45 (what is the reason?) Set there for
    % moment as only have data for -90 to 90 distribution
    stdorientation=[1:1:50];
    % Set mean orientation to range from -45 to 45 (what is the reason?)Set there for
    % moment as only have data for -90 to 90 distribution
    meanorientation=[-45:1:45];
    for i = 1:length(meanorientation)
        for j = 1:length(stdorientation)
            orientation=GaussianOrientation(phi,90-meanorientation(i),stdorientation(j));
            [sigma,TS]=AverageTSorientation(BSsigma,orientation,phi);
            for ifre = 1:length(freq_u)
                eval(['F',num2str(freq_u(ifre)),'_TS(igo,i,j) = TS(ifre,1);']);
                eval(['F',num2str(freq_u(ifre)),'_sigma(igo,i,j) = TS(ifre,1);']);
            end
        end
    end
end

clear i j TS sigma

save TS_length_allOrients_fin.mat F38_TS F70_TS F120_TS F200_TS F333_TS F67_TS F125_TS F74_TS F82_TS F91_TS F99_TS F108_TS meanorientation stdorientation -mat
    