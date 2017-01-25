%% Task 2.1 scaling factor calculation
fs = 44100;


%% initialization
playrec_init();

%% play define
playDuration = 4;
N_samples = fs*playDuration;
% signal define
WhiteNoise = randn(N_samples,1);

lpFilt = designfilt('lowpassiir','FilterOrder',3,'PassbandFrequency',...
                    8e3,'PassbandRipple',0.2,'SampleRate',fs);
hpFilt = designfilt('highpassiir','FilterOrder',3,'PassbandFrequency',...
                    100,'PassbandRipple',0.2,'SampleRate',fs);
data_filtered = filtfilt(lpFilt, WhiteNoise);
signal_filtered = filtfilt(hpFilt, data_filtered);% bandpass filter the noise

playSignal = signal_filtered;
% channel define
playChanList = 1;

%% record define
recDuration = 4;
N_rec = fs*recDuration;
% channel define
recChanList = [1,2];

%% M1&M2 recording while S1 playing
pageNumber = playrec('playrec',playSignal,playChanList,N_rec,recChanList);
block = playrec('block',pageNumber);
recBuffer = playrec('getRec',pageNumber);

%% calculating the scaling factor---------------------microphone
rms1 = rms(recBuffer(:,1));
rms2 = rms(recBuffer(:,2));
mic_scale = [1;rms1/rms2];

%% S1-S2 playing while M1 recording 
recChanList = 1;

playChanList = 1;% S1 playing 
pageNumber1 = playrec('playrec',playSignal,playChanList,N_rec,recChanList);
block = playrec('block',pageNumber1);
recBuffer1 = playrec('getRec',pageNumber1);

playChanList = 2;% S2 playing 
pageNumber2 = playrec('playrec',playSignal,playChanList,N_rec,recChanList);
block = playrec('block',pageNumber2);
recBuffer2 = playrec('getRec',pageNumber2);

%% calculating the scaling factor---------------------speaker
rms11 = rms(recBuffer1);
rms22 = rms(recBuffer2);
speak_scale = [1;rms11/rms22];

% save('mic_scale.mat','mic_scale');
% save('speak_scale.mat','speak_scale');