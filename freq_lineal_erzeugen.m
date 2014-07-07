%### Erzeugen eines Frequenzraster ###
%### Auswahl Terz oder Oktaveraster moeglich

function [freq_band,freq_band_border] = freq_lineal_erzeugen(resolution,freq_start,freq_end)
%%%% Die Variablen nicht mehr benoetigt, da sie in der Funktion uebergeben
%%%% werden! 
% Frequenzbereich definieren - Raster erzeugen
% clear all
% close all
% freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
% freq_end = 16000;    % obere Begrenzung

%%%%wenn "resolution" dieser Funktion hier uebergeben wird, brauchen wir das nicht zu ueberschreiben%%%% 
% resolution = 1;              % 2 fuer Terzband, 1 fuer Oktavband

switch resolution;
	case 1;
        freq_band_factor = 2;              % Faktor zur Bestimmung der mid-frequenzen fuer oktavband
        freq_band_border_factor = sqrt(2); % Faktor zur Bestimmung der grenz-frequenzen fuer Oktavband
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
freq_band(freq_band_index-1) = []; %loesche den letzten Wert, der nur entsteht, weil wir einen Index fuer freq_band_border mehr brauchen
clear freq_band_index;
clear resolution;