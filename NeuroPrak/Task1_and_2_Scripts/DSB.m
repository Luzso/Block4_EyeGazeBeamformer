function [output,state]=dummy_algorithm(cmd,input,param,state)
% function [output,state]=dummy_algorithm(cmd,input,param,state)
%
% A dummy implementation of an audio signal processing algorithm written
% for the realtime framework used in the class Signal Processing for Audio
% Technology at TUM.
%
% Inputs:
% cmd    command passed to the algorithm. One of: 'process', 'init',
%        'getnuminchan', 'getnumoutchan', 'getparamnames', 'getparamranges'
% input  for 'process': audio data to be processed
%        for 'getnumoutchan': number of input channels
%        for 'init': {initdata,fs,pagesize,numinchan,numoutchan}, where
%        initdata is provided by the user to the realtime processing
%        framwork, fs is the sample rate in Hz, pagesize is the size in
%        samples of the input and output buffers, and numinchan and
%        numoutchan are the numbers of input and output channels.
% param  cell array of parameter values within the ranges provided by the
%        algorithm.
% state  permanent storage (as returned by the last call to this function)
%
% Outputs:
% output    audio data processed by the algorithm
% state     permanent storage (to be provided in the next call to this
%           function)
%
% This function was written for the course Signal Processing for Audio
% Technology. Author: Fritz Menzer, Audio Information Processing, TUM

if strcmp(cmd,'process')
    % calculate output from input, state, and param
    output_gain = input*10^(param(1)/10)*state.scale;
    prevData = state.prevData;
    
    output_temp(:,1) = filtfilt(state.b_pass,state.a_pass,output_gain(:,1));
    output_temp(:,2) = filtfilt(state.b_pass,state.a_pass,output_gain(:,2));
    
%     output_temp = output_gain;
    
    
    angle_rad = param(2)*pi/180;
    T_delay = (state.d/state.c)*sin(angle_rad);
    delay = floor(T_delay*state.fs);
    
    if param(2)==0          % No delay
        output_delayed(:,1) = output_temp(:,1);      
        output_delayed(:,2) = output_temp(:,2);
    
    % Moves a fraction of the early segment to the end, and fills the rest with zeros. Noisy but causal
    elseif param(2) > 0     % Positive delay = right side leads
        output_delayed(:,1) = [prevData(end-delay:end,1);output_temp(1:end-delay-1,1)];
        output_delayed(:,2) = output_temp(:,2);
    else                    % Negative delay = left side leads
        output_delayed(:,1) = output_temp(:,1);
        output_delayed(:,2) = [prevData(end+delay:end,2);output_temp(1:end+delay-1,2)];
    end
    
    
    output = output_delayed(:,1)*(1/state.nInC)-output_delayed(:,2)*(1/state.nInC);
    output(:,2) = output(:,1);
    
    state.prevData = output_temp;
elseif strcmp(cmd,'init')
    % generate a default state and return it
    state = [];
    output = []; % necessary to avoid a Matlab error
    f_s = input.fs;
    N_sample = input.pagesize;
    state.nInC = input.numinchan;
    state.d = 0.15;
    state.c = 344;
    state.fs = f_s;
    
    w1 = 1.5e3/(f_s/2);
    w2 = 4e3/(f_s/2);
    
    [b_low a_low] = butter(6,w1,'low');
    state.b_low = b_low;
    state.a_low = a_low; 
    
    [b_high a_high] = butter(6,w2,'high');
    state.b_high = b_high;
    state.a_high = a_high;
    
    [b_pass a_pass] = butter(6,[w1 w2]);
    state.b_pass = b_pass;
    state.a_pass = a_pass;
    
    scale = load('Example Stimuli/mic_gains_example.mat');
    state.scale = scale.g;
    
    state.prevData = zeros(N_sample,input.numinchan);
    
elseif strcmp(cmd,'getnuminchan')
    % return number of input channels
    output = -1; % arbitrary number of input channels
elseif strcmp(cmd,'getnumoutchan')
    % return number of output channels
    output = input; % same number as input channels
elseif strcmp(cmd,'getparamnames')
    % return a cell array with parameter names
    output = {'Gain', 'Angle'};
elseif strcmp(cmd,'getparamranges')
    % return a cell array with parameter ranges
    output = {[-15,15], [-90,90]};
end