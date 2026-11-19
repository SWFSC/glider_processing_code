
function DATA = f_COMBINE_NORTEK_COMPACT_TELEMETRY_DATA(path1, Calib_Sv)

% Files here are converted within MIDAS. The ad2 files, are first converted to NTK 
% The output is a daily structure contaianing dat from all frequencies and both broad band IQ
% data as well as the individual narrowband (cw) amplitudes.

% Importantly in this version of the conversion no depth data is avaialble,
% I believe that if converted within Oceancontour, there may be more info
% in the structure, also the files here are not labels by TWR segment
% number not to any profile data
% 2025 C Reiss

% Pick the directory with the nortek data
if nargin < 2
    Calib_Sv = -74;
end

[dir1] = uigetdir('Pick a NORTEK directory with matlab files')
%dir1='G:\ECOSWIM\calanus_06_25\calanus_AD2\test\Processed Data'
cd (dir1)
% load(filename1)


X=dir;
X(1:2)=[];

%Make some empty arrays
Time_stmp=[];MT_timestamp=[];Max_depth=[]; dZ=[]; Blanking=[];
VBS_echo_73=[]; VBS_echo_82=[]; VBS_echo_90=[]; VBS_echo_99=[]; VBS_echo_107=[];
VBS_echo_70=[];VBS_echo_120=[];

% Data.EchoTelemetry_TimeStamp
% Data.EchoTelemetry_MatlabTimeStamp
% Data.EchoTelemetry_Ascent
% Data.EchoTelemetry_Descent
% Data.EchoTelemetry_VBSFrequency1
% Data.EchoTelemetry_VBSFrequency2
% Data.EchoTelemetry_VBSFrequency3
% Data.EchoTelemetry_VBSFrequency4
% Data.EchoTelemetry_VBSFrequency5
% Data.EchoTelemetry_VBSFrequency6
% Data.EchoTelemetry_VBSFrequency7
% Data.EchoTelemetry_VBSAmpEchogram1
% Data.EchoTelemetry_VBSAmpEchogram2
% Data.EchoTelemetry_VBSAmpEchogram3
% Data.EchoTelemetry_VBSAmpEchogram4
% Data.EchoTelemetry_VBSAmpEchogram5
% Data.EchoTelemetry_VBSAmpEchogram6
% Data.EchoTelemetry_VBSAmpEchogram7
% Data.Units
% Data.Comments


for i=1: length(X)  ;                   % loop through infiles and process them
    X(i).name
    aa=(X(i).name)
    %exten = aa(end-9:end-4)

    load(aa);
  
    if i==1
Max_depth=[Config.tmecho_dmax];
dZ=[Config.tmecho_di];
Blanking=[Config.tmecho_dmax];
Config_out=Config;        
Time_stmp=[Time_stmp; Data.EchoTelemetry_TimeStamp];
MT_timestamp =[MT_timestamp; Data.EchoTelemetry_MatlabTimeStamp];

VBS_echo_73 = [VBS_echo_73; Data.EchoTelemetry_VBSAmpEchogram1];
VBS_echo_82 = [VBS_echo_82; Data.EchoTelemetry_VBSAmpEchogram2];
VBS_echo_90 = [VBS_echo_90; Data.EchoTelemetry_VBSAmpEchogram3];
VBS_echo_99 = [VBS_echo_99; Data.EchoTelemetry_VBSAmpEchogram4];
VBS_echo_107 =[VBS_echo_107; Data.EchoTelemetry_VBSAmpEchogram5];
VBS_echo_70 = [VBS_echo_70; Data.EchoTelemetry_VBSAmpEchogram6];
VBS_echo_120 = [VBS_echo_120; Data.EchoTelemetry_VBSAmpEchogram7];

    else
Time_stmp=[Time_stmp; Data.EchoTelemetry_TimeStamp];
MT_timestamp =[MT_timestamp; Data.EchoTelemetry_MatlabTimeStamp];
VBS_echo_73 = [VBS_echo_73; Data.EchoTelemetry_VBSAmpEchogram1];
VBS_echo_82 = [VBS_echo_82; Data.EchoTelemetry_VBSAmpEchogram2];
VBS_echo_90 = [VBS_echo_90; Data.EchoTelemetry_VBSAmpEchogram3];
VBS_echo_99 = [VBS_echo_99; Data.EchoTelemetry_VBSAmpEchogram4];
VBS_echo_107 =[VBS_echo_107; Data.EchoTelemetry_VBSAmpEchogram5];
VBS_echo_70 = [VBS_echo_70; Data.EchoTelemetry_VBSAmpEchogram6];
VBS_echo_120 = [VBS_echo_120; Data.EchoTelemetry_VBSAmpEchogram7];
    end
  
end

% get teh overall size of the final array
sz_arr=size(VBS_echo_120);
% Now Generate the some additional arrays for plotting etc.
depth =[dZ:dZ:Max_depth];
times=repmat(MT_timestamp,1,sz_arr(2));


BS_120=VBS_echo_120; %RDI is multiplied by 0.45 to convert count to db, p142 manual; using raw Nortek amplitude
BS_70=VBS_echo_70;
[rr,cc]=size(BS_120);

% Also need to apply the Sv Correction (maybe read the SN from the Matlab
% file) and the use a look up to find out which is the latest offset?

%Calib_Sv = -74; %at 120kHz unless done at 70kHz as well
cal_ABC = 10.^(Calib_Sv/10); 

%120kHz
ABC_120=10.^(BS_120/10);
cal_abc_120 = ((10.^(BS_120/10) - (10.^(Calib_Sv/10))));
cal_VBS_echo_120= real(10*log10(cal_abc_120));

%70kHz
ABC_70=10.^(BS_70/10);
cal_abc_70 = ((10.^(BS_70/10) - (10.^(Calib_Sv/10))));
cal_VBS_echo_70= real(10*log10(cal_abc_70));

%Now make the output file
DATA.caldata.ABC_120=       ABC_120;
DATA.caldata.BS_120	=	    BS_120;
DATA.caldata.cal_abc_120=	cal_abc_120;
DATA.caldata.cal_ABC_120=	cal_ABC;
DATA.caldata.ABC_70=		ABC_70;
DATA.caldata.BS_70=		    BS_70;
DATA.caldata.cal_abc_70=	cal_abc_70;
DATA.caldata.cal_ABC_70=	cal_ABC;
DATA.caldata.Calib_Sv=		Calib_Sv;

DATA.cal_VBS_echo_120=	cal_VBS_echo_120;
DATA.cal_VBS_echo_70=	cal_VBS_echo_70;
DATA.MT_timestamp=MT_timestamp;
DATA.Time_stmp=Time_stmp;
DATA.times=times;
DATA.depth=		    depth;
DATA.dZ=		    dZ;

DATA.Max_depth=		Max_depth;
DATA.VBS.VBS_echo_107=		VBS_echo_107;
DATA.VBS.VBS_echo_120=		VBS_echo_120;
DATA.VBS.VBS_echo_70=		VBS_echo_70;
DATA.VBS.VBS_echo_73=		VBS_echo_73;
DATA.VBS.VBS_echo_82=		VBS_echo_82;
DATA.VBS.VBS_echo_90=		VBS_echo_90;
DATA.VBS.VBS_echo_99=		VBS_echo_99;
		
DATA.Config_out=		Config_out;





% % Make 40log10(range)+amp
% norm_amp=(cal_Sv + 40*log10(Range))';
% 
% 
% low_cal_abc=f_lowpass(double(cal_abc),60); %(positive because smaller dB are more negative)
% % Now convert back to clabrated lowpass filtered Sv
% low_cal_Sv=real(10*log10(low_cal_abc));
% 
% 
% 
% 
% figure(2)
% subplot(3,2,1)
% pcolor(BS'); shading flat; colorbar; caxis([-90 -20])
% 
% subplot(3,2,2)
% pcolor(cal_Sv'); shading flat; colorbar; caxis([-90 -20])
% 
% subplot(3,2,3)
% pcolor(low_cal_Sv'); shading flat; colorbar; caxis([-70 -40])
% 


% % BACKSCATTER    
% %Ainslie M. A., McColm J. G., "A simplified formula for
% % viscous and chemical absorption in sea water", Journal of the Acoustical
% % Society of America, 103(3), 1671-1672, 1998.
% T=1;
% S=34;
% D=floor(nanmean(Pressure)); %depth,metres
% f=120; % frequency 
% f2=42*exp(T/17);
% alpha2=f;
% 
% % rr=[-1*D:10:40]; % currently 10m; trying to make the range from transducer... not in the avg dataset
% % Range=-1*rr; %% will have to make this range again rr=[-1*D:10:52)%%%
% 
% for i=1:length(f)
%     alpha2(i)=0.52*(1+T/43)*(S/35)*f2*f(i)^2/(f2^2+f(i)^2)*exp(-D/6000)+0.00049*f(i)^2*exp(-T/27-D/17000); %db/km
% end
% 
% alpha2=alpha2/1000; % db/m 
% 
% 
% %trythis = 10*log10((10.^(BS/10) -(10.^(Calib_Sv/10))));
% % 2 way beam spreading and absorption
% LR=real(2*(20*log10((Range(1,:))') + alpha2*Range')); %*ones(1,38));
% 
% 
% lr=(repmat(LR(:,1),1,rr)');
% 
% subplot(3,2,4)
% pcolor((-1*lr)'); shading flat; colorbar; caxis([-90 -20])
% corr_cal_abc = cal_abc - 10.^((-1*lr)'/10);
% corr_cal_Sv = 10*log10(corr_cal_abc);
% 
% subplot(3,2,5)
% pcolor(corr_cal_Sv); shading flat; colorbar; caxis([-90 -20])
% 
% % 
% 
% %backscatter=(10.^(lr/10))-tryfirst;  % back scatter range attenuation correction = dB+20LogR
% 
% % Convert to arithmetic units? Then low pass, then convert back to dB.
% % Convert Sv to small (sv) in arthimetic values
% 
% 
% 
% 
% 
% %now lowpass filter (need to see how this functions (in a profile)
% 
% 
% 
% figure (2)
% subplot(3,1,1)
% pcolor((CAL_BS)'); shading interp; colormap('jet'); colorbar
% 
% 
