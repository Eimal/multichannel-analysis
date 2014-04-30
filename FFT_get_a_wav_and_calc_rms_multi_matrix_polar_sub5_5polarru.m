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

rmssegmentlen = 4096; 
freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
freq_end = 16000;    % obere Begrenzung

[FileName,PathName] = uigetfile('*.wav','Select the .wav file','Multiselect','on');
Pathname_and_Filename = char(strcat(PathName,FileName));
channelcnt = length(FileName) % Kanalanzahl automatisch ermittlen

break

resolution = menu('Choose the desired resolution','Octave (-)','Third (+)');

% fft_rms_multichannel = ones(9,channelcnt); %channelcnt verbessern! 

% for i=1:channelcnt                                       % stepping through audio-files
%     [audioin,Fs,bits] = wavread(Pathname_and_Filename(i,:)); 
%     segmentcount =floor((size(audioin)/rmssegmentlen));
%         
%     for j = 1:(segmentcount-2)                           %stepping through timesements
%         segmentstart =(((j*rmssegmentlen)+1)-rmssegmentlen);
%         segmentend = j*rmssegmentlen;
%         segmentaudio = audioin((((j*rmssegmentlen)+1)-rmssegmentlen):j*rmssegmentlen);
%         subplot(2,1,1); 
%         plot(segmentaudio);
%         title(FileName(1,i), 'color','r');
%         %pause(0.001)
%         pseudorms(j,i) = mean(abs(segmentaudio)); 
%         pseudorms_dbfs(j,i) = rms_to_dbfs(pseudorms(j,i)); 
%         pseudorms_dbfs(j,channelcnt+1) = pseudormsfs(j,1) % 360degree  represented by 0degree
%     
%     end
%         
% end

% Filter zum Entfernen des DC Offsets
    [audioin,Fs] = audioread(Pathname_and_Filename(1,:));
    dc_offset_filter_objects = fdesign.highpass('N,F3db',40,10/Fs);
    dc_offset_filter = design(dc_offset_filter_objects,'butter');
    
    
    
for i=1:channelcnt                                       % stepping through audio-files
    [audioin,Fs,bits] = wavread(Pathname_and_Filename(i,:)); 
    segmentcount = floor((size(audioin)/rmssegmentlen));
    % entfernt den DC Offset aus dem audioin
    audioin = filter(dc_offset_filter,audioin);

    
    %%%% Unnötige Schritte zusammenfassen %%%%
    %%rms_value_channel = fft_band_multiple_rms_analysis(audioin,Fs,resolution);
    %%fft_rms_multichannel(:,i) = rms_value_channel;
    fft_rms_multichannel(:,i) = fft_band_multiple_rms_analysis(audioin,Fs,resolution,freq_start,freq_end);
end
load('resolution.mat');
clear i;

%rms_value_storage_switched = fft_rms_multichannel';

%%% Hobohms Schleife. Erst später machen! %%% for k = 1: segmentcount-2       %stepping through matrix containing circular-information
for k = 1:size(fft_rms_multichannel)
    t = 0:2*pi/31:(2*pi);
    
    % 1.Polarplotzeile mit füönf plots
    subplot(4,5,(10+k)); 
    polar(t,fft_rms_multichannel(k,:));           %macht visualisierung
    title(['Oktave=',int2str(k)], 'color','r')
    
    k = k+1;
    
    
    
%     subplot(4,5,[1 5]);
%     plot(audioin,'b');
%     title(FileName(1,1), 'color','r');
%     
%     hold on;
%     
%     st = ((k*rmssegmentlen)+1)-rmssegmentlen;
%     en = k*rmssegmentlen;
%     actaudio = zeros(size(audioin));
%     actaudio(st:en) = audioin(st:en);
%     plot(actaudio,'r');        %draw red zero line with amlitude at selected segment
%     
%     subplot(4,5,[6 10]);
%     plot(audioin(st:en),'b');
%     
%     hold off;
%     pause()
end
clear k;
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
clear k;
hold on;
plot(shortaudioin);      %show timesignal

wavplay(audioin,Fs);
