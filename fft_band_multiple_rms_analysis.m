% Audio einlesen, Filtern und Speichern

%%%%%%%%%%%%%%
%Einkommentieren, falls eigenstaendiges Skript
%%%%%%%%%%%%%%
%clear all;
%close all;
%[filenameWavR,pathnameWavR]=uigetfile('*.wav','Audio-Datei auswaehlen');
%[audioin,fs,bits]=wavread([pathnameWavR filenameWavR]);
%resolution = 2; % Terzauflösung
%freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
%freq_end = 16000;    % obere Begrenzung

%%%%%%%%%%%%%%
%Programmbeginn
%%%%%%%%%%%%%%
function [fft_bands_section_rms,freq_band] = fft_band_multiple_rms_analysis(audioin,fs,resolution,freq_start,freq_end) %; semicolon not necessary
str=0;
audio_end = length(audioin);

fft_points = 4096; %%Verbessern!!
fft_bandwith = fs / fft_points;
%%% Variablen fuer die Produkterkennung von Matlab
neural_network_toolbox = 0;
signal_processing_toolbox = 0;
if ver_product('Neural Network Toolbox') == 1
    neural_network_toolbox = 1;
end
if ver_product('Signal Processing Toolbox') == 1
    signal_processing_toolbox = 1;
end

[freq_band,freq_band_border] = freq_lineal_erzeugen(resolution,freq_start,freq_end);
length_freq_grenz = length(freq_band_border);
length_freq_mid = length(freq_band);
% Auf Vielfaches Pruefen und falls erforderlich zero padding

rest = mod(audio_end,(fft_points));  % Rest bestimmen
anhang = zeros(fft_points-rest,1);   % Zeros Vektor erzeugen mit Laenge = Rest

audio_passend = vertcat(audioin,anhang);          % Zeros an Signal Anhaengen

k = 1;
j = 1;
fft_bands_index = 1;
fft_bands_section_rms = ones(1,length_freq_mid);
        
% if str == 0                         %%%%%
%      fftw('planner', 'hybrid');     %Optimierung der FFT-Geschwindigkeit
%      str = fftw('dwisdom');         %%%%%
%      
%      else
%          
%      end
   
while k < audio_end;
    fft_in = audio_passend(k:(k+(fft_points-1)));
    k = k + fft_points;
    fft_bands_all = (1/fft_points).*abs(fft(fft_in)); 
    % magnitude_y = abs(fft_bands_all);
    
%     if str==0				%%%%%%%%%%%%%
%         str = fftw('dwisdom');	%Optimierung der FFT-Geschwindigkeit
%     else				%%%%%%%%%%%%%
%     end
    
    while j < length_freq_grenz;
    freq_sector_grenz = freq_band_border(j+1)-freq_band_border(j);
    fft_bands_index_end = floor(freq_sector_grenz/fft_bandwith);
        %%Unnuetze Schritte zusammenfassen%%
        %fft_bands_section = fft_bands_all(fft_bands_index:fft_bands_index_end);
        %fft_bands_section_rms(j) = rms(fft_bands_section);
    
    %%%Die Funktion "rms" aus MATLABs Signal Processing Toolbox ersetzt Jakobs eigene Funktion rms_multiband. 
    %%%RMS wird aus dem Vektor "fft_bands_all" aus dem oben erzeugten Bereich gebildet.
%dB     fft_bands_section_rms(j) = 10*log(rms_multiband(fft_bands_all(fft_bands_index:fft_bands_index_end))); %10*log = Umrechnung in dBFS
    if neural_network_toolbox == 1 %-dB %%% Je nachdem, welche Tools installiert sind, wird RMS ueber die folgenden Befehle ermittelt %%%
        fft_bands_section_rms(j) = rms_multiband(fft_bands_all(fft_bands_index:fft_bands_index_end)); 
    elseif signal_processing_toolbox == 1
        fft_bands_section_rms(j) = rms(fft_bands_all(fft_bands_index:fft_bands_index_end)); 
    end
    j = j + 1;
	fft_bands_index = fft_bands_index_end+1;
    end
end

clear j;
clear k;

% semilogx(freq_mid(1:9),rms_value(1:9))

