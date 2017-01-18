clear all;
close all;
clc;

N_buffer = [512,2048];

t_play = 1;
f_s = 44.1e3;
N_samples = t_play*f_s;

recBufferRaw = zeros(N_samples,2);

for i = 1:2
playrec_init(N_buffer(i)); 
N_channels = playrec('getPlayMaxChannel')

click = zeros(N_samples,1);
click(N_samples/2:N_samples,1) = ones(N_samples/2+1,1);

pageNumber = playrec('playrec',click(:,1),[1],N_samples,[1])
playrec('block',pageNumber)
recBufferRaw(:,i) = playrec('getRec',pageNumber)
playrec('reset')
end 
%%
time = linspace(0,1,N_samples);

figure(1)
plot(time,click,time,recBufferRaw(:,1))
figure(2)
plot(time,click,time,recBufferRaw(:,2))

