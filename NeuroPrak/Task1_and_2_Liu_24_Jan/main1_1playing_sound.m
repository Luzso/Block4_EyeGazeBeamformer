%% 1.1 playing noise

%% initialization
fs = 44100;
t_sound = 3;%second
N_samples = fs*t_sound;
maxN_channel = playrec('getPlayMaxChannel');

playrec_init(11025);
playChanList = [1,2];

%% generation noise
WhiteNoise = randn(N_samples,1);
playSignal = [WhiteNoise,WhiteNoise];

%tones 
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
           sin(so(1)*t)+sin(so(2)*t);sin(la(1)*t)+sin(la(2)*t)];%+sin(tone(3)*t);
playBuffer = repmat(harmony,reptime,2);


playrec('play',playBuffer,playChanList);