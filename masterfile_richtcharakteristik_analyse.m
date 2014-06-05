% m-script for visualization of acoustic-radiation pattern in polarplots
% using wav-files recorded with circular-microphone-aray
%
% This m-script needs channelcount input wav-file containing recorded audio using a circular microphone array
% with channelcnt microphones. The recorded instrument or device must be
% located in the center of the circle.
% The user has to specify the number of microphones used in the circle
% array (channelcnt) and the number of samples used for the rms-estimation (rmssegmentlen).
% The script generates a polar-plot using the data from the channelcnt-wav-files for each rmssegment.

clear all; 
close all;

rmssegmentlen = 4096; 
freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
freq_end = 16000;    % obere Begrenzung

%%% Variablen fuer die Produkterkennung von Matlab
neural_network_toolbox = 0;
signal_processing_toolbox = 0;
if ver_product('Neural Network Toolbox') == 1
    neural_network_toolbox = 1;
end
if ver_product('Signal Processing Toolbox') == 1
    signal_processing_toolbox = 1;
end

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

%%% Matlab benutzt seit Version 2013 den Befehl 'audioread'
if verLessThan ('matlab','8.1.0.604') %Matlabversionen Vergleich
    [audio_1, Fs, bits] = wavread(Pathname_and_Filename(channelcnt,:));
    segmentcount = floor(length(audio_1)/rmssegmentlen);
else
    audio_1 = audioread(Pathname_and_Filename(channelcnt,:));       %wir halten nur die letzte der Wave-Dateien im RAM zum Plotten (nicht die erste, weil die RMS-Schleife mit der letzten Wave-Datei aufhoert und diese zum Plotten weitergegeben wird. 
        info = audioinfo(Pathname_and_Filename(channelcnt,:));          %Infos ueber die Audiodaten lesen
        bits = info.BitsPerSample;
        Fs = info.SampleRate;
        segmentcount = floor(info.TotalSamples/rmssegmentlen);          %Berechnet die Anzahl moeglicher Segmente der Audio-Dateien
end



t = 0:2*pi/(channelcnt):(2*pi);               %wird fuer die Polarbefehle benoetigt
rumfummel_begrenzung = ones(1,channelcnt+1);      %zweiter Polar-Kreis, der die Skalierung fuer unsere richtungs- und frequenzabhaengigen RMS-Werte vorschreibt

for j = 1:segmentcount %%% Segment-Schleife %%%
    clf; %reset aller Plots
    segment_start = ((j*rmssegmentlen)+1)-rmssegmentlen;
    segment_end = j*rmssegmentlen;
    
    %%% RMS-Schleife %%%
    for i = 1:channelcnt 
        if verLessThan ('matlab','8.1.0.604') %%% Wieder Matlab 2013 vs 2011 // audioread vs. wavread
            [audioin] = wavread(Pathname_and_Filename(i,:),[segment_start,segment_end]); % das aktuelle Audiosegment wird in "audioin" geschrieben
           else
                [audioin] = audioread(Pathname_and_Filename(i,:),[segment_start,segment_end]); % das aktuelle Audiosegment wird in "audioin" geschrieben
        end
        [fft_rms_multichannel(:,i),freq_band] = fft_band_multiple_rms_analysis(audioin,Fs,resolution,freq_start,freq_end); % audioin wird in mehrere Frequenzbaender zerlegt und fuer jedes Band der RMS bestimmt
        if neural_network_toolbox == 1 %%% Je nachdem, welche Tools installiert sind, wird RMS ueber die folgenden Befehle ermittelt %%%
            [rms_global(:,i)] = rms_multiband(audioin); % benoetigt MATLAB neural network toolbox
        elseif signal_processing_toolbox == 1
            [rms_global(:,i)] = rms(audioin);
        end
    end
    if i == channelcnt %die Werte  von 0 Grad = 360 Grad. Damt die polar-Funktion das kapiert, muessen wir den Wert von 0 Grad nach 360 Grad kopieren, d.h. einen neuen letzten Wert in die Arrays vom jeweiligen ersten kopieren
        fft_rms_multichannel(:,i+1) = fft_rms_multichannel(:,1);
        rms_global(:,i+1) = rms_global(:,1);
    end
    i = 1;
    
    %%% Plotten %%%
    subplot(4,5,[1 4]);                                         %Platzierung der folgenden Zeile an oberster Stelle, mit einer Breite von 1-4 (von maximal 5)
    plot(audio_1,'b');                                          %Plottet die letzte der ausgewaehlten Wave-Dateien
    hold on;
    redplot = zeros(size(audio_1));                             %Erstellt den Vektor fuer die rote Markierung des aktuellene Segments. Der Vektor muss genau so gross sein wie die erste Wave-Datei
    redplot(segment_start:segment_end) = audioin;               %Schriebt in den Vektor fuer die rote Markierung die Werte des aktuellen Segments. 
    plot(redplot,'r');                                          %Plottet das aktuelle Segment rot
    title(fileList(1,1), 'color','r','Interpreter','none');
%     subplot(4,1,2);                                             %Platziert die folgende Zeile an zweiter Stelle
%     plot(audioin);                                              %Plottet das aktuelle Segment
%     title(['Segment #',num2str(j)],'color','r','Interpreter','none');

    %Polardiagramm des gesamten Spektrums
    subplot(4,5,5);                     %Bei einer 4x5 Tabelle wird die folgende Grafik auf Zelle #5 geplottet
    polar(t,rms_global(1,:));           %macht visualisierung
    hold on;                            %Haelt den oberen Kreis fest, damit die Skalierung gleich bleibt
    title(['Global Polar'],'color','r');
    
    %Spektrogramm (von Hobohms Skript%
    subplot(4,1,2); % data of channel 31 is used
    if j == 1
        [Y,F,T,P] = spectrogram(audio_1,1024,576);%draw filtered spectrogram: noch fehlerhaft
    end
    surf(T,F,10*log10(abs(P)),'EdgeColor','none');
    axis xy; axis tight; view(0,90); %Drehung der Zeitachse um 90%
    colorbar('location','eastoutside');
    rumfummel_begrenzung(1,:) = 1.2*max(max(fft_rms_multichannel,[],2));    %findet das Maximum aus jeder Zeile des RMS Arrays und findet davon das Maximum 8-) -> wir legen den aeusseren Rumfummelkreis fest
    
    %%% Polardiagram-Schleife %%%
    for k = 1:size(fft_rms_multichannel) 
        subplot(4,5,(10+k)); %Polardiagramme aller Frequenzbaender 
        polar(t,rumfummel_begrenzung(1,:),'-r'); %-dB Dieser Kreis gibt die Skalierung vor. Das ist ein ziemliches Rumgefummel. Unter mit 0.4 und 0.3 funktioniert der Trick nicht. Wir muessen eine bessere Loesung finden. 
        polar(t,fft_rms_multichannel(k,:));  %-dB macht visualisierung
        title([num2str(freq_band(k)),' Hz'],'color','r'); %benennt die einzelnen Polardiagramme nach ihren entsprechenden Mittenfrequenzen 'freq_band'
    end
    k = 1;

pause()
end
break