%% 1.4 playing,recording and processing in real-time
clear all;
close all;
%% initialization
fs = 44100;
maxN_channel = playrec('getPlayMaxChannel');

playrec_init(1024);


%% play define
playDuration = 8;
N_samples = playDuration*fs;
% signal define
t = (0:11024)';
reptime = N_samples/length(t)/4;
do = 2*pi*[256,512]/fs;
re = 2*pi*[288,576]/fs;
mi = 2*pi*[320,640]/fs;
fa = 2*pi*[341+1/3,682+2/3]/fs;
so = 2*pi*[384,768]/fs;
la = 2*pi*[426+2/3,853+1/3]/fs;
xi = 2*pi*[480,960]/fs;

harmony = [sin(do(1)*t)+sin(do(2)*t);sin(mi(1)*t)+sin(mi(2)*t);...
           sin(so(1)*t)+sin(so(2)*t);sin(la(1)*t)+sin(la(2)*t)];
playBuffer = repmat(harmony,reptime,1);
% channel define
playChanList = 1;
%% record define
recDuration = 8;
N_rec = fs*recDuration;
% channel define
recChanList = 1;
[rec_real,play_real] = realtime_processing(5,@gain_ILD,[],[],playChanList,recChanList);
% playrec('play',playBuffer,playChanList);


%% realtime processing
pageNumber = playrec('playrec',playBuffer,playChanList,N_rec,recChanList);
block = playrec('block',pageNumber);
recBuffer = playrec('getRec',pageNumber);
realtime_processing(10,@gain_ILD,[],[],[],[]);



