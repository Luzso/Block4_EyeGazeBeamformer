%% 1.5 playing,recording and processing in real-time
clear;
close all;
%% initialization
fs = 44100;
playrec_init();
maxN_channel = playrec('getPlayMaxChannel');
% 
% playrec_init(1024);
%% play define
playDuration = 8;
% channel define
playChanList = [1,2];
%% record define
recDuration = 8;
% channel define
recChanList = 1;

%% realtime processing
[rec_real,play_real] = realtime_processing(300,@gain_ILD_ITD);
% playrec('play',playBuffer,playChanList);