function [CFS] = calculate_cf_glider(LF_fname)
% 
% [CFS_ALL] = CALCULATE_UFF_SDWBA_TABLE_2_ASAM09(LF_fname, COEFFS)
% This function calculates the Conversion factors for the the SDWBA model
% and claculates CFS for the MEAN scenario from Table
% 2 in ASAM 2009
% LF_fname is a TEXT file containing the length frequency distributions.
% UFFS_ALL is a 3 by 9 matrix where each 3X3 bit is the UFF for 38, 120,
% and 200 Khz (ROWS) and for the MINUS, MEAN and PLUS (COLUMNS)scenarios
% Changed Dec 3 2007 by Demer with additional imaginary numbers for simplified SDWBA
% Modified By CSR, AMC NOAA AMLR 2010
% AMC Mar 09, 2023 Updated for all glider frequencies 



lf = load(LF_fname)' ;% krill length-frequencies by cluster
load TS_krill_length_values_alt_fin.mat % TS for [38 120 200 67 70 74 82 91 99 108 120 125]
c = 1456; % sound speed
freq = [38 67.5 70 74 82 91 99 108 120 125]*1e3; % acoustic frequency
k = (2*pi.*freq)/c;                   % acoustic wavenumber
lo = 38.35;                           % reference length (mm)
Lo = 38.35*1e-3;                      % reference length (m)
l = lf(1,:);                          % krill lengths (mm)
L = l*1e-3;                           % krill lengths (m)
w = 2.236e-3*l.^3.314;                % krill mass (g) (CCAMLR 2000)


% compute and plot SDWBA TS model
for i = 1:size(freq,2)
    kL(i,:) = k(i)*L;
    LN(i,:) = L;
    wN(i,:) = w;
end

% wNw = wN.*lf(2:4,:);  % frequency-weighted weights

%%  simplified SDWBA model 

% %N(-20,28)  Mean Run
% f=[  1.017293647539714e+01-2.220549802893098e+01i,
     % 1.467062799925061e-01-2.320331716631431e-02i,
     % 4.707986072245677e-01-2.382463748939396e-01i,
     % 7.805131060445190e-08+0i,                         
    % -1.428575874595269e-05+0i,                         
     % 9.872816575626821e-04+0i,                        
    % -3.175055370293767e-02+0i,                         
     % 4.688300486017548e-01+0i,                        
    % -2.637181001263358e+00+0i,                        
    % -8.063422516425572e+001-6.184918959463339e+00i];
% CD_MEAN_TS = real(f(1)*(log10(f(2).*kL)./(f(2).*kL)).^f(3)+f(4)*kL.^6+f(5)*kL.^5+f(6)*kL.^4+f(7)*kL.^3+f(8)*kL.^2+f(9)*kL+f(10)+20*log10(LN./Lo));

 % % NASC
 % for cluster = 1:1:3,
 %     for i = 1:size(freq,2),
 %         SDWBA_MEAN(cluster,i)=sum(lf(cluster+1,:).*wN(i,:))/sum(lf(cluster+1,:).*(4*pi*10.^(CD_MEAN_TS(i,:)/10)));
 %     end
 % end
 % UFF_MEAN=SDWBA_MEAN'/1e+3/1852^2 ;             % Convert UFF to units of m^2/n.mi.^2

% % ABC
% for cluster = 1:1:3
    % for i = 1:size(freq,2)
        % SDWBA_MEAN(cluster,i) = sum(lf(cluster+1,:).*wN(i,:))/sum(lf(cluster+1,:).*(10.^(CD_MEAN_TS(i,:)/10)));
    % end
% end
% CF_CCAMLR_MEAN = SDWBA_MEAN'/1e+3 ;   % Convert CF to units of m^2/m^2

%% Full SDWBA model

%TS for [38 120 200 67 70 74 82 91 99 108 120 125]*1e3 change T_TS number for different
%frequency
MEAN_TS = T_TS([1 4 5 6 7 8 9 10 11 12],:);


% for NASC
% for cluster = 1:1:3,
%     for i = 1:size(freq,2),
%         SDWBA_MEAN(cluster,i) = sum(lf(cluster+1,:).*wN(i,:))/sum(lf(cluster+1,:).*(4*pi*10.^(CD_MEAN_TS(i,:)/10)));
%     end
% end
% CF_MEAN = SDWBA_MEAN'/1e+3/1852^2 ;             % Convert CF to units of m^2/n.mi.^2

CF_SDWBA_MEAN = [];
% for ABC
for cluster = 1:1:3
    for i = 1:size(freq,2)
        CF_SDWBA_MEAN(cluster,i) = sum(lf(cluster+1,:).*wN(i,:))/sum(lf(cluster+1,:).*(10.^(MEAN_TS(i,:)/10)));
    end
end
CF_MEAN = CF_SDWBA_MEAN'/1e+3 ;   % Convert CF to units of m^2/m^2

a = [38; 67.5; 70; 74; 82; 91; 99; 108; 120; 125];
ABC_CFS = [a CF_MEAN];
CFS = table(ABC_CFS);

