clear all;
close all;
clc;


t_play = 1;
f_s = 44.1e3;
N_samples = t_play*f_s;

playrec_init(); 
N_channels = playrec('getPlayMaxChannel')

whiteNoise = randn(N_samples,1);
whiteNoise(:,2) = whiteNoise(:,1);
MAX = max(whiteNoise);
playSignal = whiteNoise/MAX;
playChanList = [1,2];

figure(1)
plot(linspace(0,t_play,N_samples),playSignal(:,1))

ok = playrec('play',whiteNoise,playChanList)