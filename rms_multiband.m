%%%%%%%%%%%%%%%%%%
%%%RMS-Calculation
%%%%%%%%%%%%%%%%%%
function [vector_out_rms] = rms_multiband(vector_in_peaks)
[squaresum, numberofelements] = sumsqr(vector_in_peaks); %sumsqr (MATLAB neural network toolbox) quadriert jeden Wert des Vektors/Zeile und summiert alles zusammen ("squaresum"). Außerdem wird die Anzahl aller Werte angegeben ("numberofelements").
vector_out_rms = sqrt(squaresum./numberofelements);