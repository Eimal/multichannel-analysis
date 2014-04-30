%### Erzeugen eines Frequenzraster ###
%### Auswahl Terz oder Oktaveraster mï¿½glich

function [freq_band,freq_band_border] = freq_lineal_erzeugen(resolution,freq_start,freq_end)
%%%% Die Variablen nicht mehr benï¿½tigt, da sie in der Funktion ï¿½bergeben
%%%% werden! 
% Frequenzbereich definieren - Raster erzeugen
% clear all
% close all
% freq_start = 62.5;   % untere Begrenzung des zu analysierenden Spektrums
% freq_end = 16000;    % obere Begrenzung

%%%%wenn "resolution" dieser Funktion hier übergeben wird, brauchen wir das nicht zu überschreiben%%%% 
% resolution = 1;              % 3 für Terzband, 2 für Oktavband


%korrekt = false;

%while korrekt==false;
switch resolution;
   case 1;
%             freq_band = ones(1,10);            % erzeugen des Vektors fï¿½r mid-frequenzen mit korrekter Lï¿½nge
        freq_band_factor = 2;              % Faktor zur Bestimmung der mid-frequenzen fï¿½r oktavband
%             freq_band_border = ones(1,10);
        freq_band_border_factor = sqrt(2); % Faktor zur Bestimmung der grenz-frequenzen fï¿½r oktavband
        %korrekt=true;
    case 2
%             freq_band = ones(1,26);
        freq_band_factor = nthroot(2,3);
%             freq_band_border = ones(1,26);
        freq_band_border_factor = nthroot(2,6);
        %korrekt=true;
end;
%end;

%%% wird hier gar nicht benutzt %%% length_freq_mid = length(freq_mid);         % Lï¿½nge des freq-vektors ï¿½bergeben        

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
freq_band(freq_band_index-1) = []; %lÃ¶sche den letzten Wert, der nur entsteht, weil wir einen Index fÃ¼r freq_band_border mehr brauchen
clear freq_band_index;
save('resolution.mat','resolution');