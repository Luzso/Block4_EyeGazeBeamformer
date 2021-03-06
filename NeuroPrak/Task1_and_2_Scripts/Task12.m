clear all;
close all;
clc;

t_rec = 10;
f_s = 44.1e3;
recDuration = t_rec*f_s;

playrec_init(); 

recChanList = 1;
'Player 1, SPEAK'
pageNumber = playrec('rec',recDuration,recChanList);
playrec('block',pageNumber);
recBuffer1RAW = playrec('getRec',pageNumber);
'Player 2, get ready!'
pause(3)

' ' 
'Player 2, SPEAK!'
pageNumber = playrec('rec',recDuration,recChanList);
playrec('block',pageNumber);
recBuffer2RAW = playrec('getRec',pageNumber);
' ' 
'DONE'

%%

%recBuffer(:,1) = recBuffer1RAW;
%recBuffer(:,2) = recBuffer2RAW;

recBuffer(:,1) = recBuffer1;
recBuffer(:,2) = recBuffer2;

RMS1 = rms(recBuffer1,1);
RMS2 = rms(recBuffer2,1);
[maxRMS,indMax] = max([RMS1,RMS2]);
[minRMS,indMin] = min([RMS1,RMS2]);
scaleRMS = maxRMS/minRMS;
recBuffer(:,indMin) = recBuffer(:,indMin)*scaleRMS;
scaleVal = max(max(abs(recBuffer(:,1))),max(abs(recBuffer(:,2))));

recBuffer1 = recBuffer(:,1)/scaleVal;
recBuffer2 = recBuffer(:,2)/scaleVal;

save('Record1.mat','recBuffer1')
save('Record2.mat','recBuffer2')

%%
% Plotting

figure(1)
subplot(2,1,1)
plot(linspace(0,t_rec,recDuration),recBuffer1)
subplot(2,1,2)
plot(linspace(0,t_rec,recDuration),recBuffer2)