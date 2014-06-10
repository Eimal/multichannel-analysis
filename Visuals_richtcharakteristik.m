clear all;
close all;

% Visualierung der Daten

% ##### TODO #### %
% Benennung der Diagramme aus fileList implementieren
% GUI entwickeln - vor und zurück steppen derzeit nur via prompt in Command
% Window möglich



% Laden der Daten aus dem skript "masterfile....mat"
load('saved_files/audio_ref.mat')
load('saved_files/polar_band.mat')
load('saved_files/polar_global.mat')
load('saved_files/segments.mat')
load('saved_files/fileList.mat')


channelcnt = length(fileList);                  % Kanalanzahl automatisch ermittlen
t = 0:2*pi/(channelcnt):(2*pi);                 %wird fuer die Polarbefehle benoetigt
rumfummel_begrenzung = ones(1,channelcnt+1);     %zweiter Polar-Kreis, der die Skalierung fuer unsere richtungs- und frequenzabhaengigen RMS-Werte vorschreibt

    %%% Plotten %%%
    
    
    j = 1
    start = 1
    
    while j == j
    audioin = audio_1(save_segments(j):save_segments(j+1));
    subplot(4,5,[1 4]);                                         %Platzierung der folgenden Zeile an oberster Stelle, mit einer Breite von 1-4 (von maximal 5)
    plot(audio_1,'b');                                          %Plottet die letzte der ausgewaehlten Wave-Dateien
    hold on;
    redplot = zeros(size(audio_1));                             %Erstellt den Vektor fuer die rote Markierung des aktuellene Segments. Der Vektor muss genau so gross sein wie die erste Wave-Datei
    redplot(save_segments(j):save_segments(j+1)) = audioin;      %Schriebt in den Vektor fuer die rote Markierung die Werte des aktuellen Segments. 
    plot(redplot,'r');                                          %Plottet das aktuelle Segment rot

    
%     title(fileList(1,1), 'color','r','Interpreter','none');
%     subplot(4,1,2);                                             %Platziert die folgende Zeile an zweiter Stelle
%     plot(audioin);                                              %Plottet das aktuelle Segment
%     title(['Segment #',num2str(j)],'color','r','Interpreter','none');

    %Polardiagramm des gesamten Spektrums
    subplot(4,5,5);                     %Bei einer 4x5 Tabelle wird die folgende Grafik auf Zelle #5 geplottet
    polar(t,save_polar_global(1,:));           %macht visualisierung
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
        % title([num2str(freq_band(k)),' Hz'],'color','r'); %benennt die einzelnen Polardiagramme nach ihren entsprechenden Mittenfrequenzen 'freq_band'
    end
    k = 1;
    factor = input('wie viele schritte vor (+1) oder zurück (-1) ? - keine Eingabe (Enter) = Ende')
    
   j = j + factor
    end