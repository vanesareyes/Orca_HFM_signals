
%Functionality:
%Open and read xwav where manual picks define start time and end time of HFM

% %Set up filter parameters
Fc1 = 10000;   % First Cutoff Frequency
Fc2 = 60000;  % Second Cutoff Frequency 
N = 10;     % Order
Fs = 200000; %sampling rate (Hz)
[B,A] = butter(N/2, [Fc1 Fc2]/(Fs/2));

hfmwindow = 0.5; %length of spectrogram to analyze (in seconds)

hfmproperties=[];

%Open manual picks
str1 = 'Select Directory containing manual picks of HFM';
indir = uigetdir();
cd(indir)
[Picks] = uigetfile('*.xls',str1,indir);
[num,txt,raw] = xlsread(Picks);

str2= 'Select Directory containing x.wavs'
indir2 =uigetdir('F:','Select directory containing x.wavs');
%gather list of all click param files
SearchFileMask = {'*.wav'};
SearchPathMask = {indir2};
SearchRecursiv = 1;

[PathFileList, FileList, PathList] = ...
    utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);

%compute startdate/time of each file
RegDate = '(?<yr>\d\d)(?<mon>\d\d)(?<day>\d\d)_(?<hr>\d\d)(?<min>\d\d)(?<sec>\d\d)';
dateFile = dateregexp(FileList,RegDate);
% cd(indir2)
% xwav = dir('*.x.wav');

startwindow = x2mdate(num(:,1));  %start time of each HFM
startwindow = startwindow-datenum(0,0,0,0,0,0.1); %give 0.1 second buffer before manual pick time
% start_vec = datevec(startwindow);

for k=1:length(startwindow)-1
    datematch = find(dateFile<startwindow(k,1)&dateFile>1,1,'last');
    
    fullfname = PathFileList{datematch};  
    [rawStart,rawDur,fs] = readxwavhd(PathList{datematch},FileList{datematch}); % start and duration of each chunck in the duty cicle
    
    rawStartTime = datenum(rawStart);
    segmatch = find(rawStartTime < startwindow(k),1,'last');
    
    segTime = sum(rawDur(1:segmatch-1)) + (startwindow(k)-rawStartTime(segmatch))*24*60*60 ;
    
    segSamples = floor(segTime*fs);    %number of samples to skip over
    
    DATA=wavread(fullfname,[segSamples segSamples+hfmwindow*fs-1],'native');
    DATA = double(DATA);

    HFMFilt= filtfilt(B,A,DATA); %filter HFM
   [dur Fstart Fstop Fpeak Fhalf bw10db sweeprate]= measure_HFM(HFMFilt,fs,2048,1843,2048,10);
 
    hfmproperties(size(hfmproperties,1)+1,:)=[dur Fstart Fstop Fpeak Fhalf bw10db sweeprate];

end
save I:\SIO\hfm\hfmproperties.mat
xlswrite('I:\SIO\hfm\hfmproperties.xls',hfmproperties);

%Median and percentiles
hfmproperties=xlsread('I:\SIO\hfm\hfmproperties.xls');
p=[10 50 90]
values=prctile(hfmproperties,p)
xlswrite ('I:\SIO\hfm\percentiles.xls',values)
ipi=xlsread('I:\SIO\hfm\ipis'); 
values=prctile(ipi,p)
x=(0:0.25:5);
hist(ipi,x,'k')
ylabel('counts','fontsize',10,'fontweight','b');
xlabel('Time [s]','fontsize',10,'fontweight','b');

%Vanesa Reyes 2015