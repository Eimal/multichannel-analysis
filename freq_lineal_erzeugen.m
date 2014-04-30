%### Erzeugen eines Frequenzraster ###
%### Auswahl Terz oder Oktaveraster m�glich

function [freq_band,freq_band_border] = freq_lineal_erzeugen(resolution,freq_start,freq_end)
%%%% Die Variablen nicht mehr ben�tigt, da sie in der Funktion �bergeben
%%%% werden! 
% Frequenzbereich definieren - Raster erzeugen
% clear all
% close all
% freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
% freq_end = 16000;    % obere Begrenzung

%%%%wenn "resolution" dieser Funktion hier �bergeben wird, brauchen wir das nicht zu �berschreiben%%%% 
% resolution = 1;              % 3 f�r Terzband, 2 f�r Oktavband


%korrekt = false;

%while korrekt==false;
switch resolution;
   case 1;
%             freq_band = ones(1,10);            % erzeugen des Vektors f�r mid-frequenzen mit korrekter L�nge
        freq_band_factor = 2;              % Faktor zur Bestimmung der mid-frequenzen f�r oktavband
%             freq_band_border = ones(1,10);
        freq_band_border_factor = sqrt(2); % Faktor zur Bestimmung der grenz-frequenzen f�r oktavband
        %korrekt=true;
    case 2
%             freq_band = ones(1,26);
        freq_band_factor = nthroot(2,3);
%             freq_band_border = ones(1,26);
        freq_band_border_factor = nthroot(2,6);
        %korrekt=true;
end;
%end;

%%% wird hier gar nicht benutzt %%% length_freq_mid = length(freq_mid);         % L�nge des freq-vektors �bergeben        

freq_band_index = 1;
freq_end_border = (freq_end*freq_band_border_factor);

while freq_start < freq_end_border;
%     freq_band = ones(1,l);
%     freq_band_border = ones(1,l);
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
save('resolution.mat','resolution');