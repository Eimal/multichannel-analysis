clear all;
close all;

% Visualierung der Daten

% ##### TODO #### %
% Benennung der Diagramme aus fileList implementieren
% GUI entwickeln - vor und zurueck steppen derzeit nur via prompt in Command
% Window moeglich
% Übergabe der Abtastrate  Fs als  Metadatum  im mat-File

%Definitions

 Fs =  48000;



% Laden der Daten aus dem skript "masterfile....mat"
[analysis_FileName,analysis_PathName] = uigetfile;
analysis_file = strcat(analysis_PathName,analysis_FileName);
load(analysis_file);



channelcnt = length(fileList);                  % Kanalanzahl automatisch ermittlen
t = 0:2*pi/(channelcnt):(2*pi);                 %wird fuer die Polarbefehle benoetigt
polar_scale_fft = ones(1,channelcnt+1);     %zweiter Polar-Kreis, der die Skalierung fuer unsere richtungs- und frequenzabhaengigen RMS-Werte vorschreibt

    %%% Plotten %%%
    
    
    j = 1;
    start = 1;
    polar_scale_fft(1:channelcnt+1) = max(max(max(save_fft_rms_multichannel(:,:,:),[],2)));     %findet das Maximum aus jeder Zeile des RMS Arrays und findet davon das Maximum 8-) -> wir legen den aeusseren Rumfummelkreis fest
    polar_scale_global(1:channelcnt+1) = max(max(save_polar_global));
    
    while j == j
    audioin = audio_1(save_segments(j):save_segments(j+1));
    subplot(4,5,[1 5]);                                         %Platzierung der folgenden Zeile an oberster Stelle, mit einer Breite von 1-4 (von maximal 5)
    plot(audio_1,'b');                                          %Plottet die letzte der ausgewaehlten Wave-Dateien
    title(analysis_FileName);
    hold on;
    redplot = zeros(size(audio_1));                             %Erstellt den Vektor fuer die rote Markierung des aktuellene Segments. Der Vektor muss genau so gross sein wie die erste Wave-Datei
    redplot(save_segments(j):save_segments(j+1)) = audioin;      %Schriebt in den Vektor fuer die rote Markierung die Werte des aktuellen Segments. 
    plot(redplot,'r');                                          %Plottet das aktuelle Segment rot

    
%     title(fileList(1,1), 'color','r','Interpreter','none');
%     subplot(4,1,2);                                             %Platziert die folgende Zeile an zweiter Stelle
%     plot(audioin);                                              %Plottet das aktuelle Segment
%     title(['Segment #',num2str(j)],'color','r','Interpreter','none');

    %Polardiagramm des gesamten Spektrums
    
    %subplot(4,5,5);                     %Bei einer 4x5 Tabelle wird die folgende Grafik auf Zelle #5 geplottet
    %polar(t,polar_scale_global,'-w');   %gibt maximale Skalierung vor
    %hold on;                            %Haelt den oberen Kreis fest, damit die Skalierung gleich bleibt
    %polar(t,save_polar_global(j,:));    %macht visualisierung
    %title(['Global Polar'],'color','r');
    
    %Spektrogramm (von Hobohms Skript%
    subplot(4,1,2); % data of channel 31 is used
    if j == 1
        
        [Y,F,T,P] = spectrogram(audio_1,1024,576,2048, Fs,'yaxis');%draw filtered spectrogram: noch fehlerhaft
        %title(Analysis_FileName);
    end
    %surf(F,T,10*log10(abs(P)),'EdgeColor','none');
    surf(T,F,10*log10(abs(P)),'EdgeColor','none');
    axis xy; axis tight; view(0,90); %Drehung der Zeitachse um 90%
    colorbar('location','eastoutside');
    %%% Polardiagram-Schleife %%%
    for k = 1:size(save_fft_rms_multichannel(:,:,j)) 
        subplot(4,5,(10+k)); %Polardiagramme aller Frequenzbaender 
        polar(t,polar_scale_fft,'-w'); %-dB Dieser Kreis gibt die Skalierung vor. Das ist ein ziemliches Rumgefummel. Unter mit 0.4 und 0.3 funktioniert der Trick nicht. Wir muessen eine bessere Loesung finden. 
        hold on;
        polar(t,save_fft_rms_multichannel(k,:,j));  %-dB macht visualisierung
        title([num2str(freq_band(k)),' Hz'],'color','r'); %benennt die einzelnen Polardiagramme nach ihren entsprechenden Mittenfrequenzen 'freq_band'
        
        subplot(4,5,20);                     %Bei einer 4x5 Tabelle wird die folgende Grafik auf Zelle #5 geplottet
        polar(t,polar_scale_global,'-w');   %gibt maximale Skalierung vor
        hold on;                            %Haelt den oberen Kreis fest, damit die Skalierung gleich bleibt
        polar(t,save_polar_global(j,:));    %macht visualisierung
        title(['Global 20-20k'],'color','b');
    end
    k = 1;
    factor = input('wie viele schritte vor (+1) oder zurueck (-1) ? - keine Eingabe (Enter) = Ende');
    clf;
    j = j + factor;
    end