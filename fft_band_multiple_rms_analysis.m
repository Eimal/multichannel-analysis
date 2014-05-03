% Audio einlesen, Filtern und Speichern

% clear all;
% close all;

% Audio einlesen

% [filenameWavR,pathnameWavR]=uigetfile('*.wav','Audio-Datei auswählen');
% [audioin,fs,bits]=wavread([pathnameWavR filenameWavR]);

function [fft_bands_section_rms,freq_band] = fft_band_multiple_rms_analysis(audioin,fs,resolution,freq_start,freq_end) %; semicolon not necessary

audio_end = length(audioin);

fft_points = 4096; %%Verbessern!!
fft_bandwith = fs / fft_points;

%%%Durch Übergabe in Funktion auskommentiert%%% 
% resolution = 1; % 1 für Oktav, 2 für Terzband
% freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
% freq_end = 16000;    % obere Begrenzung

[freq_band,freq_band_border] = freq_lineal_erzeugen(resolution,freq_start,freq_end);
length_freq_grenz = length(freq_band_border);
length_freq_mid = length(freq_band);
% Auf Vielfaches Prüfen und falls erforderlich zero padding

rest = mod(audio_end,(fft_points));  % Rest bestimmen
anhang = zeros(fft_points-rest,1);   % Zeros Vektor erzeugen mit Länge = Rest

audio_passend = vertcat(audioin,anhang);          % Zeros an Signal Anhängen

k = 1;
j = 1;
fft_bands_index = 1;
fft_bands_section_rms = ones(1,length_freq_mid);

while k < audio_end;
    fft_in = audio_passend(k:(k+(fft_points-1)));
    k = k + fft_points;
    fft_bands_all = abs(fft(fft_in));
    % magnitude_y = abs(fft_bands_all);
    
    while j < length_freq_grenz;
    freq_sector_grenz = freq_band_border(j+1)-freq_band_border(j);
    fft_bands_index_end = floor(freq_sector_grenz/fft_bandwith);
        %%Unnütze Schritte zusammenfassen%%
        %fft_bands_section = fft_bands_all(fft_bands_index:fft_bands_index_end);
        %fft_bands_section_rms(j) = rms(fft_bands_section);
    
    %%%Die Funktion "rms" aus MATLABs Signal Processing Toolbox ersetzt Jakobs eigene Funktion rms_multiband. 
    %%%RMS wird aus dem Vektor "fft_bands_all" aus dem oben erzeugten Bereich gebildet.
    fft_bands_section_rms(j) = rms(fft_bands_all(fft_bands_index:fft_bands_index_end));
    j = j + 1;
	fft_bands_index = fft_bands_index_end+1;
    end
end
clear j;
clear k;

% semilogx(freq_mid(1:9),rms_value(1:9))

