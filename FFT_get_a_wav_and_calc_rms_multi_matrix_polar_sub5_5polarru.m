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

% Select Folder and get files
dirName = uigetdir(pwd, 'Select a sound sample folder');
dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);

Pathname_and_Filename = char(fileList);
channelcnt = length(fileList); % Kanalanzahl automatisch ermittlen
resolution = menu('Choose the desired resolution','Octave (-)','Third (+)');

audio_1 = audioread(Pathname_and_Filename(channelcnt,:));       %wir halten nur die letzte der Wave-Dateien im RAM zum Plotten (nicht die erste, weil die RMS-Schleife mit der letzten Wave-Datei aufhört und diese zum Plotten weitergegeben wird. 

break

info = audioinfo(Pathname_and_Filename(channelcnt,:));          %Infos über die Audiodaten lesen
bits = info.BitsPerSample;
Fs = info.SampleRate;
segmentcount = floor(info.TotalSamples/rmssegmentlen);          %Berechnet die Anzahl möglicher Segmente der Audio-Dateien
t = 0:2*pi/31:(2*pi);                                           %wird für die Polarbefehle benötigt
rumfummel_begrenzung = ones(1,32); %Quick&Dirty-Implementierung eines zweiten Polar-Kreises, der die Skalierung für unsere richtungs- und frequenzabhängigen RMS-Werte vorschreibt

for j = 1:segmentcount %%% Segment-Schleife %%%
    clf; %reset aller Plots
    segment_start = ((j*rmssegmentlen)+1)-rmssegmentlen;
    segment_end = j*rmssegmentlen;
    
    for i = 1:channelcnt %%% RMS-Schleife %%%
        [audioin] = audioread(Pathname_and_Filename(i,:),[segment_start,segment_end]); % das aktuelle Audiosegment wird in "audioin" geschrieben
        [fft_rms_multichannel(:,i),freq_band] = fft_band_multiple_rms_analysis(audioin,Fs,resolution,freq_start,freq_end); % audioin wird in mehrere Frequenzbänder zerlegt und für jedes Band der RMS bestimmt
    end
    i = 1;
    
    %%% Plotten %%%
    subplot(4,1,1);                                             %Platzierung der folgenden Zeile an oberster Stelle
    plot(audio_1,'b');                                          %Plottet die letzte der ausgewählten Wave-Dateien
    hold on;
    redplot = zeros(size(audio_1));                             %Erstellt den Vektor für die rote Markierung des aktuellene Segments. Der Vektor muss genau so groß sein wie die erste Wave-Datei
    redplot(segment_start:segment_end) = audioin;               %Schriebt in den Vektor für die rote Markierung die Werte des aktuellen Segments. 
    plot(redplot,'r');                                          %Plottet das aktuelle Segment rot
    title(FileName(1,1), 'color','r','Interpreter','none');
    subplot(4,1,2);                                             %Platziert die folgende Zeile an zweiter Stelle
    plot(audioin);                                              %Plottet das aktuelle Segment
    title(['Segment #',num2str(j)],'color','r','Interpreter','none');
    rumfummel_begrenzung(1,:) = 1.2*max(max(fft_rms_multichannel,[],2));    %findet das Maximum aus jeder Zeile des RMS Arrays und findet davon das Maximum 8-) -> wir legen den äußeren Rumfummelkreis fest
    
    for k = 1:size(fft_rms_multichannel) %%% Polardiagram-Schleife %%%
        subplot(4,5,(10+k)); 
        polar(t,rumfummel_begrenzung(1,:),'-k'); %Dieser Kreis gibt die Skalierung vor. Das ist ein ziemliches Rumgefummel. Unter mit 0.4 und 0.3 funktioniert der Trick nicht. Wir müssen eine bessere Lösung finden. 
        %plot(plot:Polar([1, u], u = 0..2*PI)); %mit MuPad?
        hold on; %Hält den oberen Kreis fest, damit die SKalierung gleich bleibt
        polar(t,fft_rms_multichannel(k,:));           %macht visualisierung
        title([num2str(freq_band(k)),' Hz'],'color','r'); %benennt die einzelnen Polardiagramme nach ihren entsprechenden Mittenfrequenzen 'freq_band'
    end
    k = 1;

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
clear k;
hold on;
plot(shortaudioin);      %show timesignal

wavplay(audioin,Fs);
