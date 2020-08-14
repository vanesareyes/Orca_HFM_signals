function [dur, Fstart, Fstop,Fpeak,Fhalf, bw10db,sweeprate] = measure_HFM(y,fs,window,overlap,nfft,thr)


t=0:(length(y)/(fs/1000))/(length(y)-1):length(y)/(fs/1000);


%spectrogram(y,window,overlap,nfft,fs)
[Y,F,T,P] = spectrogram(y,window,overlap,nfft,fs);
%[Y,F,T,P] = spectrogram(HFMFilt,512,210,512,fs);

T = T*1000; %ms
F = F/1000; %kHz
figure(1);
subplot(2,1,1), plot(t,y,'k');
ylabel('Amplitude [counts]','fontsize',10,'fontweight','b');

subplot(2,1,2), surf(T,F,10*log10(abs(P)),'EdgeColor','none');
axis xy; axis tight; colormap(blue); view(0,90);
xlabel('Time [ms]','fontsize',10,'fontweight','b');
ylabel('Frequency [kHz]','fontsize',10,'fontweight','b');


[x z] = max(P); %finds maximum values of each column, z are index
xLog = 10*log10(x); %converts energy into dB
%thr dB bandwidth  
low=max(xLog)-thr;
[xMax zMax] = max(xLog);
slopeup=fliplr(xLog(1:zMax));
slopedown=xLog(zMax:end);

for start=1:length(slopeup)
   if slopeup(start)<low %stop at value < -thr
       break
   end
end


for stop=1:length(slopedown)
   if slopedown(stop)<low %stop at value < -thr
       break
   end
end

zTrace = z(zMax-start+1:zMax+stop-1);
%dur = ((zMax+stop-1)-(zMax-start+1))/fs*1000*1000;
dur = ((zMax+stop-1)-(zMax-start+1)); %ms
Fstart = z(zMax-start+1)*F(2); %kHz
Fstop = z(zMax+stop-1)*F(2); %kHz
Fpeak = z(zMax)*F(2); %kHz
halftime=round(length(zTrace)/2); %kHz
Fhalf = z(halftime)*F(2); %kHz
bw10db= Fstart-Fstop; %kHz
sweeprate=bw10db/dur; %kHz/ms


tTrace = T(1:length(zTrace));

zTrace = (zTrace*F(2));

figure(2);
plot(tTrace,zTrace);
xlabel('Time [ms]');
ylabel('Frequency [kHz]');
ylim([F(1) F(end)]);
xlim([T(1) T(end)]);

%Pecu 2015