%function ProcessKrillEupSDWBATS_mlength(start,count)
% ProcessKrillEupSDWBATS.m
% Program to process the SDWBA model for
% Antartic Krill.
% 
% Stephane Conti
% 2005/06/03
%
% JPRO 30/03/2010 Run multiple iterations via paramaters array
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the realisations of the noise
%if ~(exist('p','var')&exist('A','var'))
%    clear all
%end
warning off;
currentdir=pwd;
path(path,'Bin/');

%for mlength_it = start:(start+count)
    ActualLength = 38.35*1e-3;
    dirname=pwd;
    file2save='SDWBATS_res0_';
    fileshape='GenericEsuperba_McGehee1998_cor';
    frequency=[5:5:350]*1e3;
    c=1456;
    theta=[-90:1:269];
    stdphase0=sqrt(2)/2;
    freq0=120e3;
    N0=14;
    noise_realisations=100;
    g0=1.0357;
    h0=1.0279;
    fatness=1.4;

    resampleqSDWBA(file2save,dirname,ActualLength,fileshape,fatness,frequency,theta,stdphase0,freq0,N0,g0,h0,c,noise_realisations);
%end
  
    
