%% Task 2.2 Recording for offline processing - target and interferer
fs = 44100;

%% initialization
playrec_init();

%% play define
% signal define
% target is the recorded sound in task1.2
load('scaled_record_of_2.mat');
target = recBuffer1;

% interfer is bandlimitted noise
WhiteNoise = randn(length(recBuffer1),1);
lpFilt = designfilt('lowpassiir','FilterOrder',3,'PassbandFrequency',...
                    8e3,'PassbandRipple',0.2,'SampleRate',fs);
hpFilt = designfilt('highpassiir','FilterOrder',3,'PassbandFrequency',...
                    100,'PassbandRipple',0.2,'SampleRate',fs);
data_filtered = filtfilt(lpFilt, WhiteNoise);
interfer = filtfilt(hpFilt, data_filtered);% the interfer

playSignal = [target,interfer];
% channel define
playChanList = 1;

%% record define
recDuration = length(playSignal)/fs+1;
N_rec = fs*recDuration;
% channel define
recChanList = [1,2];

%% M1&M2 recording while S1 playing
pageNumber = playrec('playrec',playSignal,playChanList,N_rec,recChanList);
block = playrec('block',pageNumber);
recBuffer = playrec('getRec',pageNumber);

mic1 = recBuffer(:,1);
mic2 = recBuffer(:,2);
% save('rec_2_2_org.mat','mic1','mic2');

%% calculating the scaling factor---------------------microphone
load('mic_scale.mat');
mic_scaled = mic_scale*recBuffer;
mic1_scaled = mic_scaled(:,1);
mic2_scaled = mic_scaled(:,2);
% save('rec_2_2_scaled.mat','mic1_scaled','mic2_scaled');

% save('mic_scale.mat','mic_scale');
% save('speak_scale.mat','speak_scale');