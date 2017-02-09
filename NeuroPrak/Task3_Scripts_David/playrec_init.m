function playrec_init(buffersize)
% function playrec_init(buffersize)
%
% Obtains the list of audio devices and initializes the first C400 device
% whose hostAPI is ASIO or ALSA. 2 playback and 2 recording channels are
% set up, at a sampling rate of 44.1 kHz.
%
% Input:
% buffersize   number of samples per audio buffer (optional, default: 512)
%
% This function was written for the course Signal Processing for Audio
% Technology. Author: Fritz Menzer, Audio Information Processing, TUM
%
% Changes: Nicolas Scheiner 11.01.2016 - Modified device selection process to either run offline using ASIO4ALL or Soundcard with fixed ID (14)


% default buffer size: 512 samples
if nargin<1, buffersize=512; end

% reset playrec if it was already initialised
if playrec('isInitialised')
    playrec('reset');
end

% get device info
dev=playrec('getDevices');

% find first device that fits our criteria (ASIO or ALSA, C400)
id=-1;
name='';
for i=1:length(dev)
    if (strcmp(dev(i).hostAPI,'ASIO') || strcmp(dev(i).hostAPI,'ALSA')) && isempty(strfind(dev(i).name,'C400')) % ASIO4ALL driver
        id=dev(i).deviceID;
        name=dev(i).name;
    end
    
    if (strcmp(dev(i).hostAPI,'ASIO') || strcmp(dev(i).hostAPI,'ALSA')) && ~isempty(strfind(dev(i).name,'C400')) % Fast Track C400
        id=dev(i).deviceID;
        name=dev(i).name;
        break;
    end

end

% initialize device
if id<0 % use fixed id if nothing is found soundcard
    fixedID = 13; % <-- change here to select manually
    id = dev(fixedID).deviceID;
    name = dev(fixedID).name;
else
    disp(['Setting up ' name ' (deviceID=' num2str(id) ')']);
    if id < 13
        disp('2 out channels');
        playrec('init',44100,id,id,2,2,buffersize,0.001,0.001);
    else
        playrec('init',44100,id,id,6,2,buffersize,0.001,0.001);
    end
end