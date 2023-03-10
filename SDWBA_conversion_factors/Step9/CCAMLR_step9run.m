
clear

%load in file of A and p calculated from using ProcessKrillEupSDWBATS.m
%then input the mean and standard deviation (note this is the standard
%error times sqrt(n). Save A and P as
%"simplified_coeffs_meanorientation_stdorientation.mat" then can use this
%file to generate TS to length relationship across size of krill interested
%in.
load simplified_coeffs_n20_28.mat

freq = [38 120 200]*1e3;
c = 1456;
L = [10:1:65]*1e-3;
k = (2*pi*freq)/c;
for i=1:size(freq,2)
    kL(i,:)=k(i)*L;
end
Stanlength = 38.35*1e-3;

TS = kL;
for j = 1:length(freq)
    for i = 1:length(kL)
        TS(j,i) = real(((log10(kL(j,i).*A(2))/(kL(j,i).*A(2))).^A(3)).*(A(1)))+ ((kL(j,i).^6).*p(1))+((kL(j,i).^5).*p(2))+((kL(j,i).^4).*p(3))+((kL(j,i).^3).*p(4))+((kL(j,i).^2).*p(5))+(kL(j,i).*p(6))+real(p(7)+A(4))+20*log(L(1,i)/Stanlength);
    end
end

TS120_38 = TS(1,:);
for inum = 1:length(TS(1,:))
    TS120_38(inum) = TS(2,inum) - TS(1,inum);
end
TS200_120 = TS(1,:);
for inum = 1:length(TS(1,:))
    TS200_120(inum) = TS(3,inum) - TS(2,inum);
end
