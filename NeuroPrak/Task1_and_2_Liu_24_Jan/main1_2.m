 %% 1.2 recording the sound
clear all;
close all;

recDuration = 10;
fs = 44100;
N_samples = fs*recDuration;
maxN_channel = playrec('getPlayMaxChannel');

playrec_init();

recChanList = 1;
playChanList = recChanList;
%% record 1
'record 1'
pageNumber1 = playrec('rec',N_samples,recChanList); 
block = playrec('block',pageNumber1);
recBuffer1 = playrec('getRec',pageNumber1);
pause;
%% record 2
'record 2'
pageNumber2 = playrec('rec',N_samples,recChanList); 
block = playrec('block',pageNumber2);
recBuffer2 = playrec('getRec',pageNumber2);

%playrec('play',recBuffer,playChanList);

%% plot the recorded audio
figure(1);
hold on;
plot(linspace(0,recDuration,N_samples),recBuffer1);
plot(linspace(0,recDuration,N_samples),recBuffer2);
legend('record 1','record 2');
title('Original recording');
grid;


%% scaling
rms1 = rms(recBuffer1)
rms2 = rms(recBuffer2)

scaled_rec1 = recBuffer1*rms2/rms1;% make them have same RMS

figure(2)
hold on;
plot(linspace(0,recDuration,N_samples),scaled_rec1);
plot(linspace(0,recDuration,N_samples),recBuffer2);
legend('record 1','record 2');
title('Scaled recording');
grid;

save('record_of_2.mat','recBuffer1','recBuffer2');
save('scaled_record_of_2.mat','scaled_rec1','recBuffer2');
