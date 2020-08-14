
%Functionality:
%Open and read xwav where manual picks define start time and end time of HFM

% %Set up filter parameters
Fc1 = 10000;   % First Cutoff Frequency
Fc2 = 60000;  % Second Cutoff Frequency (Chosen because highest peak freq of tonals seemed to be around 4.5 kHz
N = 10;     % Order
fs = 500000; %sampling rate (Hz)
[B,A] = butter(N/2, [Fc1 Fc2]/(fs/2));

hfmwindow = 0.5; %length of spectrogram to analyze (in seconds)

hfmproperties_array=[];

%Open manual picks
% str1 = 'Select Directory containing manual picks of HFM';
% indir = uigetdir();
% cd(indir)
% [Picks] = uigetfile('*.xls',str1,indir);
% [num,txt,raw] = xlsread(Picks);
% 
% startwindow = x2mdate(num(:,1));  %start time of each HFM
% startwindow = startwindow-datenum(0,0,0,0,0,0.1); %give 0.1 second buffer before manual pick time
% startwindow = datevec(startwindow);
% 
% startfile=xlsread('I:\SIO\hfm\Antarc01El_hfm_start_end_array.xls','MetaData','E2');
% startfile=x2mdate(startfile); 
% startfile=datevec(startfile); 
% skip=floor(etime(startwindow(1,:),startfile))*fs;    %number of samples to skip over
% 
% fin=skip+hfmwindow*fs-1;
% 
% DATA=wavread('I:\2014 TA orca\avisoft_2014-02-20 01_22_06.wav',[skip fin],'native');
DATA=wavread('I:\2014 TA orca\avisoft_2014-02-20 01_22_06.wav',[52.5*fs (52.5+hfmwindow)*fs-1],'native');
DATA = double(DATA);

HFMFilt= filtfilt(B,A,DATA); %filter HFM
[dur Fstart Fstop Fpeak Fhalf bw10db sweeprate]= measure_HFM(HFMFilt,fs,5120,4608,5120,10);
 
hfmproperties_array(size(hfmproperties_array,1)+1,:)=[dur Fstart Fstop Fpeak Fhalf bw10db sweeprate];

save I:\SIO\hfm\hfmproperties.mat

%Median and percentiles
load 'I:\SIO\hfm\hfmproperties.mat';
hfmproperties=xlsread('I:\SIO\hfm\hfmproperties.xls');
p=[10 50 90]
values=prctile(hfmproperties,p)
xlswrite ('I:\SIO\hfm\percentiles2.xls',values)
ipi=xlsread('I:\SIO\hfm\ipi.xls');
values=prctile(ipi,p)

a=mean(hfmproperties)
b=std(hfmproperties)
c=min(hfmproperties)
d=max(hfmproperties)

a=mean(ipi)
b=std(ipi)
c=min(ipi)
d=max(ipi)

%Vanesa Reyes 2015