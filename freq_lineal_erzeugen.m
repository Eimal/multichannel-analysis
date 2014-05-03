%### Erzeugen eines Frequenzraster ###
%### Auswahl Terz oder Oktaveraster möglich

function [freq_band,freq_band_border] = freq_lineal_erzeugen(resolution,freq_start,freq_end)
%%%% Die Variablen nicht mehr benötigt, da sie in der Funktion übergeben
%%%% werden! 
% Frequenzbereich definieren - Raster erzeugen
% clear all
% close all
% freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
% freq_end = 16000;    % obere Begrenzung

%%%%wenn "resolution" dieser Funktion hier übergeben wird, brauchen wir das nicht zu überschreiben%%%% 
% resolution = 1;              % 3 für Terzband, 2 für Oktavband

switch resolution;
	case 1;
        freq_band_factor = 2;              % Faktor zur Bestimmung der mid-frequenzen für oktavband
        freq_band_border_factor = sqrt(2); % Faktor zur Bestimmung der grenz-frequenzen für Oktavband
	case 2
        freq_band_factor = nthroot(2,3);
        freq_band_border_factor = nthroot(2,6);
end;

freq_band_index = 1;
freq_end_border = (freq_end*freq_band_border_factor);

while freq_start < freq_end_border;
    if freq_band_index == 1;
        freq_band(1) = freq_start;
    else
        freq_band(freq_band_index) = freq_band_factor*freq_start;
    end
    freq_band_border(freq_band_index) = freq_band(freq_band_index)/freq_band_border_factor;
    freq_start = freq_band(freq_band_index);
    freq_band_index = freq_band_index + 1;
end
freq_band(freq_band_index-1) = []; %lösche den letzten Wert, der nur entsteht, weil wir einen Index für freq_band_border mehr brauchen
clear freq_band_index;
clear resolution;