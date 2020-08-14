%Open manual picks
str1 = 'Select Directory containing manual picks of HFM';
indir = uigetdir();
cd(indir)
[Picks] = uigetfile('*.xls',str1,indir);
[num,txt,raw] = xlsread(Picks);
clear all
num=xlsread('I:\SIO\hfm\tiempos para ipis.xls','encounter 3','a77:a78');

startwindow = x2mdate(num(:,1));  %start time of each HFM
startwindow = datevec(startwindow);
ipi=[];
ipi=etime(startwindow(2,:),startwindow(1,:))
for i=2:size(startwindow,1)
    ipi(end+1)= etime(startwindow(i,:),startwindow(i-1,:));
end
ipi'
xlswrite('I:\SIO\hfm\ipi2.xls','Sheet1','a9',ipi');
