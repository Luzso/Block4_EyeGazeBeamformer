function [output,state]=gain_ILD(cmd,input,param,state)
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
    output_temp = input*10^(param(1)/10); % Overall gain
    prevData = state.prevData;
    %delay = floor(f_s*param(3));
    delay = floor(44.1e3*param(3)/1000);   % Calculates number of delay samples 
   
    
    if param(3)==0          % No delay
        output_delayed(:,1) = output_temp;      
        output_delayed(:,2) = output_temp;
    
    % Moves a fraction of the early segment to the end, and fills the rest with zeros. Noisy but causal.
        
    elseif param(3) > 0     % Positive delay = right side leads
        output_delayed(:,1) = [prevData(end-delay:end);output_temp(1:end-delay-1)];
        output_delayed(:,2) = output_temp;
        'Positive'
    else                    % Negative delay = left side leads
        output_delayed(:,1) = output_temp;
        output_delayed(:,2) = [prevData(end+delay:end);output_temp(1:end+delay-1)];
        'Negative'
    end
    
    % applies interaural level difference
    output(:,1) = output_delayed(:,1)*10^(-param(2)/10);
    output(:,2) = output_delayed(:,2)*10^(param(2)/10);
    
    state.prevData = output_temp;
    % update state and return it
    % e.g. state.x = state.x+1;
elseif strcmp(cmd,'init')
    % generate a default state and return it
    f_s = input.fs;
    state = [];
    output = []; % necessary to avoid a Matlab error
    state.prevData = zeros(input.pagesize,1);
elseif strcmp(cmd,'getnuminchan')
    % return number of input channels
    output = -1; % arbitrary number of input channels
elseif strcmp(cmd,'getnumoutchan')
    % return number of output channels
    output = input; % same number as input channels
    %output = 2
elseif strcmp(cmd,'getparamnames')
    % return a cell array with parameter names
    output = {'Overall Gain (dB)', 'Interaural Level Difference (dB)' , 'Delay (ms) Positive = left, Negative = right'};
elseif strcmp(cmd,'getparamranges')
    % return a cell array with parameter ranges
    overall_gain = [-15,15];
    ILD = [-3,3];
    ITD = [-3,3];
    output = {overall_gain , ILD , ITD};
end