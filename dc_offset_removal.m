%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DC Offset Removal %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% Das Entfernen des DC Offsets sollte nicht in den einzelnen Segmenten
% gemacht werden, sondern vorher. D.h., alle geladenen Wave-Files müssen
% komplett gespeichert werden (unnötige Last und Speicherbedarf). Aus
% diesem Grund 

clear all;
close all;

[FileName,PathName] = uigetfile('*.wav','Select the .wav file','Multiselect','on');
Pathname_and_Filename = char(strcat(PathName,FileName));
channelcnt = length(FileName); % Kanalanzahl automatisch ermittlen
% save('FileName.mat','FileName');
% save('Pathname_and_Filename.mat','Pathname_and_Filename');

[audioin,Fs] = audioread(Pathname_and_Filename(1,:));
dc_offset_filter_objects = fdesign.highpass('N,F3db',40,10/Fs);
dc_offset_filter = design(dc_offset_filter_objects,'butter');

for i=1:channelcnt                                              % stepping through audio-files
    [audioin,Fs,bits] = wavread(Pathname_and_Filename(i,:)); 
    % entfernt den DC Offset aus dem audioin
    audioin = filter(dc_offset_filter,audioin);
    audiowrite(char(strcat('dc_removed\',FileName(i))),audioin,Fs,'BitsPerSample',24);
end