clear all;
close all;
clc;

t_buffer = 10;
f_s = 44.1e3;
recDuration = t_buffer*f_s;

N_buffer = 512;

playrec_init(N_buffer);

realtime_processing


