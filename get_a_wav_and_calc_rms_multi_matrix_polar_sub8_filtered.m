 
% m-script for visualization of acoustic-radiation pattern in polarplots
% using wav-files recorded with circular-microphone-aray
%
% This m-script needs channelcount input wav-file containing recorded audio using a circular microphone array
% with channelcnt microphones. The recorded instrument or device must be
% located in the center of the circle.
% The user has to specify the number of microphones used in the circle
% array (channelcnt) and the number of samples used for the rms-estimation (rmssegmentlen).
% The script generates a polar-plot using the data from the channelcnt-wav-files for each rmssegment.

% to do :   ECHTE RMS BESTIMMUNG als Funktion (rms_a())
%           AMPLITUDENSKALIERUNG AUF db (z.B. FS = 0 dB)
%           SPEKTRALE ZERLEGUNG MIT FILTERN z.B 15-31-62-125-250-1k-2k-4k-8k-16k-32k  = 10 Filter 
%           SPEKTRALE ZERLEGUNG MIT FFT

clear all; 
close all;

channelcnt = 32;
rmssegmentlen = 4096; 

[FileName,PathName] = uigetfile('*.wav','Select the .wav file','Multiselect','on')
Pathname_and_Filename = char(strcat(PathName,FileName));

[audioin,Fs,bits] = wavread(Pathname_and_Filename(1,:));  % get audio file for 0 degree
%wavplay(audioin,Fs);                                     % play audio file for 0 degree


octavecnt = 10; %(Fs/2-FLow)/
freq_start =20;
k =1;
while freq_start < 11000
    d = fdesign.bandpass('n,f3dB1,f3dB2', 40, freq_start, 2*freq_start, Fs);
    hd(k) = design(d,'butter'); 
    freq_start = 2*freq_start;
    k=k+1;
end         


for i=1:channelcnt                                       % stepping through audio-files
    [audioin,Fs,bits] = wavread(Pathname_and_Filename(i,:)); 
    segmentcount = floor((size(audioin)/rmssegmentlen));
        
    for j = 1:(segmentcount-2)                           %stepping through timesegments
        segmentstart =(((j*rmssegmentlen)+1)-rmssegmentlen);
        segmentend = j*rmssegmentlen;
        segmentaudio = audioin((((j*rmssegmentlen)+1)-rmssegmentlen):j*rmssegmentlen);
        
        subplot(2,1,1); 
        
            % progress_in_percent = 100 *(j/segmentcount)   
             freq_start = 20;
             k = 1;     % index of actual octave
             while freq_start < 11000
             %d = fdesign.bandpass('n,f3dB1,f3dB2', 40, freq_start, 2*freq_start, Fs);
             %hd = design(d,'butter'); 
             %freqz(hd);
             %pause(1);
             filteredsegmentaudio = filter(hd(k),segmentaudio);
             %plot(filteredaudio);
             %wavplay(audioin);
             %wavplay(filteredaudio);
             %pause(0.1)
             %[Y,F,T,P] = spectrogram(filteredaudio,1024,998);%draw filtered spectrogram: noch fehlerhaft
             %surf(T,F,10*log10(abs(P)),'EdgeColor','none');
             %axis xy; axis tight; view(0,90);
             %pause(3);
            
        
             %%plot(segmentaudio);
             %title(FileName(1,i), 'color','r');
             %pause(0.001)
             pseudorms(j,i,k) = mean(abs(filteredsegmentaudio)); 
             pseudorms_dbfs(j,i,k) = 10*log(pseudorms(j,i,k));%calculate rms dB value 
             pseudorms(j,channelcnt+1,k) = pseudorms(j,1,k); % 360degree represented by 0degree
             
             freq_start = 2*freq_start;
             k=k+1;
            
             close all;
             end
        
        
    end
        
end
   
 subplot(2,1,1);
 plot(audioin);  % data of channel 31 is used
 
 %hold on
 %plot(shortaudioin);      %show timesignal
 %hold off
 
 
 
 save('cello_32chan_polar.mat','pseudorms');
 
 %break;
 
 subplot(4,5,[6 10]); % data of channel 31 is used
 [Y,F,T,P] = spectrogram(audioin,1024,998);%draw filtered spectrogram: noch fehlerhaft
 surf(T,F,10*log10(abs(P)),'EdgeColor','none');
 axis xy; axis tight; view(0,90);
 pause(2);
            
 
 
 for j = 1:segmentcount-2       %stepping through matrix containing circular-information
    t = 0:2*pi/32:(2*pi);
   
    %circle(1:channelcnt+1) = 0.00999; % workaround f. outer circle max(pseudorms)
                                        % muss noch mit dynam. Skala f.
                                        % Maxwert (pseudorms) versehen werden
    % 1.graficrow containing five polarplots
    subplot(4,5,11); 
    polar(t,pseudorms(j,:,1));           %Polar visualisation 1.octave
    title(['Oktave=',int2str(1)], 'color','r')
    
    subplot(4,5,12); 
    %polar(t,circle);
    %hold on;
    polar(t,pseudorms(j,:,2));           %Polar visualisation 2.octave
    title(['Octave',int2str(2)], 'color','r')
    %hold off;
    
    subplot(4,5,13); 
    polar(t,pseudorms(j,:,3));           %Polar visualization 3.octave
    title(['Octave',int2str(3)], 'color','r')
    
    subplot(4,5,14); 
    polar(t,pseudorms(j,:,4));           %Polar visualization 4.octave
    title(['Octave',int2str(4)], 'color','r')
    
    subplot(4,5,15); 
    polar(t,pseudorms(j,:,5));           %Polar visualization 5.octave
    title(['Octave',int2str(5)], 'color','r')

    % 2. graficrow containing five polarplots
    subplot(4,5,16); 
    polar(t,pseudorms(j,:,6));           %Polar visualization 6.octave
    title(['Octave',int2str(6)], 'color','r')
    
    subplot(4,5,17); 
    polar(t,pseudorms(j,:,7));           %Polar visualization 7.octave
    title(['Octave',int2str(7)], 'color','r')
    
    subplot(4,5,18); 
    polar(t,pseudorms(j,:,8));           %Polar visualization 8.octave
    title(['Octave',int2str(8)], 'color','r')
    
    subplot(4,5,19); 
    polar(t,pseudorms(j,:,9));           %Polar visualization 9.octave
    title(['Octave',int2str(9)], 'color','r')
    
    subplot(4,5,20); 
    polar(t,pseudorms(j,:,10));           %Polar visualization 10.octave
    title(['Octave',int2str(10)], 'color','r')
    
    
    subplot(4,5,[1 5]);
    plot(audioin,'b');
    %title(FileName(1,1), 'color','r');
    text((length(audioin))/2,0,FileName(1,1),'FontSize',10, 'HorizontalAlignment','center',... 
 'BackgroundColor',[.7 .9 .7])
    hold on;
    
    st = ((j*rmssegmentlen)+1)-rmssegmentlen;
    en = j*rmssegmentlen;
    actaudio = zeros(size(audioin));
    actaudio(st:en) = audioin(st:en);
    plot(actaudio,'r');        %draw red zero line with amplitude at selected segment
    
       
    for m = 1 : rmssegmentlen-1;
            resized_segmentaudio(((m*segmentcount)-segmentcount)+1 : m*segmentcount) = actaudio(st+m);
    end
  
    subplot(4,5,[1 5]);
    plot(resized_segmentaudio,'g');
    
    hold off
    
    pause()
end

break





%Effektivwertbestimmung
rms_interval = 4096; %Zeitdauer für die rms- Bestimmung 
shortaudioin = audioin(1:44100);
rmsinterval_count = size(shortaudioin) / rms_interval %Berechnung der  Intervalle, die ausgewertet werden 
rmsresult_of_interval = ones(1,rmsinterval_count)

for k=1:rmsinterval_count

    audiosegm_for_rmsdetect = (shortaudioin( ((k-1)*rms_interval)+1 : k*rms_interval));
    rectifiedaudio =(audiosegm_for_rmsdetect.*audiosegm_for_rmsdetect);
    plot(rectifiedaudio,'r');
       
    rmsresult_of_interval(k)= sqrt(sum(rectifiedaudio) /  rms_interval);
    
end

hold on;

resize_len_factor = size(audioin)/rmssegmentlen;
for i = 1 : rmssegmentlen;
        for k = 0:round(resize_len_factor);
         resized_shortaudioin(i+k) = shortaudioin(i);
        end
end



        
        
        
plot(shortaudioin);      %show timesignal

wavplay(audioin,Fs);