clear all;
close all;
clc; 

N_buffer = 512;

playrec_init(N_buffer);
NPlaychannels = playrec('getPlayMaxChannel');

algo = @DSB;
initdata = [];
initparam = []; %  zeros for Gain, ILD and ITD
playChanList = [1 2];

scale = load('Example Stimuli/mic_gains_example.mat');
example = load('Example Stimuli/mic_recording_example.mat');
sample = [example.y;example.y;example.y];

realtime_sample_processing(sample,algo,initdata,initparam,playChanList);