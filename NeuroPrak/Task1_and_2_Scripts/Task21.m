clear all;
close all;
clc;

'TASK 2.1'

%%
t_noise = 1;
f_s = 44.1e3;
run_time = 3*60; % Seconds
N_buffer = 512;  % 512 is default for playrec_init

% Noise generation and filtering
N_noise = f_s*t_noise;
whiteNoise_temp = randn(N_noise,1);
w1 = 100/(f_s/2);
w2 = 8e3/(f_s/2);
[b,a] = butter(6,[w1,w2]);
whiteNoise_filt = filtfilt(b,a,whiteNoise_temp(:,1));
whiteNoise(:,1) = whiteNoise_filt(:,1);
whiteNoise(:,2) = whiteNoise(:,1);


%%
% Caibrate microphones
playrec_init(N_buffer);
NPlaychannels = playrec('getPlayMaxChannel');

micplayChanList = [1];
micrecDuration = N_noise;
micrecChanList = [1,2];
micpageNumber = playrec('playrec',whiteNoise(:,1),micplayChanList,micrecDuration,micrecChanList);
playrec('block',micpageNumber);
micbuf = playrec('getRec',micpageNumber);

micrms = [rms(micbuf(:,1)) rms(micbuf(:,2)];
[micminRms micminChan] = min(micrms);
[micmaxRms micmaxChan] = max(micrms);
alpha = micminRms/micmaxRms;

disp(['Microphone scaling factor is alpha = ', num2str(alpha)])
disp(['Scaling must be applied to mic channel: ', num2str(micmaxChan)])
mic_scale(micminChan,1) = 1;
mic_sclae(micmaxChan,1) = alpha;

%%
% Equailize speakers
speakrecDuration = N_noise;
speakrecChanList = [1];
speackbuf = zeros(N_noise,2)

for i=1:2
speakplayChanList = [i];
speakpageNumber = playrec('playrec',whiteNoise,speakplayChanList,speakrecDuration,micrecChanlist);
playrec('block',speakpageNumber);
speakbuf(:,i) = payrec('getRec',speakPageNumber);
end

speakrms = [rms(speakbuf(:,1)) rms(speakbuf(:,2)];
[speakminRms speakminChan] = min(speakrms);
[speakmaxRms speakmaxChan] = max(speakrms);
beta = speakminRms/speakmaxRms;

disp(['Speaker equalization scaling factor is beta = ', num2str(beta)])
disp(['Scaling must be applied to speaker channel: ', num2str(speakmaxChan)])
speak_scale(speakminChan,1) = 1;
speak_scale(speakmaxChan,1) = beta;

%%
scale = [mic_scale;speak_scale);
save('mic_scale','mic_scale');
save('speak_scale','speak_scale');


%%


% Check filter output - not that important.
% N_fft = 2^nextpow2(N_noise);
% f_fft = linspace(1,f_s/2,N_fft/2-1);
% Noi_fft = fft(whiteNoise_temp,N_fft);
% Noifil_fft = fft(whiteNoise_filt,N_fft);
% figure(1)
% subplot(2,1,1)
% plot(f_fft,abs(Noi_fft(1:N_fft/2-1)))
% subplot(2,1,2)
% plot(f_fft,abs(Noifil_fft(1:N_fft/2-1)))