%% 1.3
clear all;
close all;
%% initialization
fs = 44100;
maxN_channel = playrec('getPlayMaxChannel');

playrec_init(2048);
%% play define
playDuration = 4;
% signal define
N_play = fs*playDuration;
clickSignal = [ones(N_play/2,1);zeros(N_play/2,1)];
playBuffer = [clickSignal;clickSignal];
% channel define
playChanList = 1;

% playrec('play',playBuffer,playChanList);
%% record define
recDuration = 8;
N_rec = fs*recDuration;
% channel define
recChanList = 1;

%% recording while playing

pageNumber = playrec('playrec',playBuffer,playChanList,N_rec,recChanList);
block = playrec('block',pageNumber);
recBuffer = playrec('getRec',pageNumber);

%playrec('playrec',playBuffer,playChanlist,N_rec,recChanlist);
%% plot
figure(1);
hold on;
plot(linspace(0,2*playDuration,2*N_play),playBuffer(:,1));
plot(linspace(0,recDuration,N_rec),recBuffer);
grid on;
legend('play','record');