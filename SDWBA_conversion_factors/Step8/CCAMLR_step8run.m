% CCAMLR_step8run
%
% Calculate dB windows for target identification
%
clear
%
% Needed to calculate the range of length frequency data that we want to
% take the windows from (step 15 in the B0 re-assessment document) - this I
% have worked out in an excel spreadsheet so that can follow working LF_pdf_clusters.xls. This
% is then input here as LF_pdf_clusters_10mm.csv 
lf_pdf = importdata('LF_pdf_clusters_10mm.csv');
%
% read in the file containing the TS to length relationship
load C:\Github\glider_processing_code\SDWBA_conversion_factors\Step7\TS_krill_length_values_alt_fin.mat;
%
% Create empty matrix of zeros 9 (for iterations) by 8 (for min and max 2v
% (120-38) and 3v (200-120) dB windows for the 95 and 99% length pdfs
db_windows = zeros(1,8);
Cluster1_db_windows = db_windows;
Cluster2_db_windows = db_windows;
Cluster3_db_windows = db_windows;
Clusterall_db_windows = db_windows;
% run through all the model iterations 1 to 9 
for igo = 1
    for j = 1:1:4
        eval(['C',num2str(j),'.min95_lpos = find(krill_ls == lf_pdf(1,',num2str(j),'));']);
        eval(['C',num2str(j),'.max95_lpos = find(krill_ls == lf_pdf(2,',num2str(j),'));']);
        eval(['C',num2str(j),'.min99_lpos = find(krill_ls == lf_pdf(3,',num2str(j),'));']);
        eval(['C',num2str(j),'.max99_lpos = find(krill_ls == lf_pdf(4,',num2str(j),'));']);
        eval(['C',num2str(j),'.db_windows = db_windows;']);
        eval(['C',num2str(j),'.db_windows(igo,1) = nanmin(T_TS(4,C',num2str(j),'.min95_lpos:C',num2str(j),'.max95_lpos));']);
        eval(['C',num2str(j),'.db_windows(igo,2) = nanmax(T_TS(4,C',num2str(j),'.min95_lpos:C',num2str(j),'.max95_lpos));']);
        eval(['C',num2str(j),'.db_windows(igo,3) = nanmin(T_TS(5,C',num2str(j),'.min95_lpos:C',num2str(j),'.max95_lpos));']);
        eval(['C',num2str(j),'.db_windows(igo,4) = nanmax(T_TS(5,C',num2str(j),'.min95_lpos:C',num2str(j),'.max95_lpos));']);
        eval(['C',num2str(j),'.db_windows(igo,5) = nanmin(T_TS(4,C',num2str(j),'.min99_lpos:C',num2str(j),'.max99_lpos));']);
        eval(['C',num2str(j),'.db_windows(igo,6) = nanmax(T_TS(4,C',num2str(j),'.min99_lpos:C',num2str(j),'.max99_lpos));']);
        eval(['C',num2str(j),'.db_windows(igo,7) = nanmin(T_TS(5,C',num2str(j),'.min99_lpos:C',num2str(j),'.max99_lpos));']);
        eval(['C',num2str(j),'.db_windows(igo,8) = nanmax(T_TS(5,C',num2str(j),'.min99_lpos:C',num2str(j),'.max99_lpos));']);
    end
    eval(['Cluster1_db_windows(',num2str(igo),',:) = C1.db_windows(',num2str(igo),',:);']);
    eval(['Cluster2_db_windows(',num2str(igo),',:) = C2.db_windows(',num2str(igo),',:);']);
    eval(['Cluster3_db_windows(',num2str(igo),',:) = C3.db_windows(',num2str(igo),',:);']);
    eval(['Clusterall_db_windows(',num2str(igo),',:) = C4.db_windows(',num2str(igo),',:);']);
end

save all_db_windows_10mm.mat Cluster1_db_windows Cluster2_db_windows Cluster3_db_windows Clusterall_db_windows -MAT        

        
    