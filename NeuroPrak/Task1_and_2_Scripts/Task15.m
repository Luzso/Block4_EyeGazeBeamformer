clear all;
close all;
clc;

'TASK 1.5'

f_s = 44.1e3;
run_time = 3*60; % Seconds
N_buffer = 512;  % 512 is default for playrec_init
playrec_init(N_buffer);

algo = @gain_ILD_ITD;
initdata = [0];
initparam = [0,0,0]; %  zeros for Gain, ILD and ITD
playChanList = [1,2];
recChanList = 1;

[recdata,playdata] = realtime_processing(run_time,algo,initdata,initparam,playChanList,recChanList);
