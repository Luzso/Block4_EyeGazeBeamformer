function [recdata,playdata]=realtime_processing(time,algo,initdata,initparam,playChanList,recChanList)
% function [recdata,playdata]=realtime_processing(time,algo,initdata,initparam,playChanList,recChanList)
%
% Realtime framework used in the class Signal Processing for Audio
% Technology at TUM. In this implementation, realtime audio input and
% output based on playrec is used. Other implementations available:
% realtime_sample_processing.m : a sample is used as input
% offline_processing.m         : input and output are samples
%
% Inputs:
% time         number of seconds the algorithm should run
% algo         function handle for algorithm implementation (e.g. @my_algo)
% initdata     data to be passed to algorithm during 'init' phase
% initparam    cell array with initial values for parameters (optional)
% playChanList vector containing the channel numbers for playback  optional?
% recChanList  vector containing the channel numbers for recording optional?
%
% Outputs:
% recdata      recorded data (i.e. input to algorithm)
% playdata     played back data (i.e. output from algorithm)
%
% This function was written for the course Signal Processing for Audio
% Technology. Author: Fritz Menzer, Audio Information Processing, TUM
% v1.1, 15.4.2015: Replaced cell arrays with structs and normal arrays
%                  where suitable; algorithm returns now initial state in
%                  "newstate" rather than "output" (F.M.)


% determine buffer size and sample rate and compute number of buffers
pagesize=playrec('getFramesPerBuffer');
fs=playrec('getSampleRate');
numpages=ceil(time*fs/pagesize); % process at least time seconds
disp(['starting realtime processing (pagesize=' num2str(pagesize) '; fs=' num2str(fs) '; numpages=' num2str(numpages) ')']);

% set up a row vector to distribute mono signal to multiple channels
out_dist=1;

% determine algorithm capabilities
% number of input channels
numinchan=algo('getnuminchan');
if numinchan==-1 % if the algorithm's number of input channels is not fixed
    if nargin>=6 % if input channels were provided, use them to determine number of channels.
        numinchan=length(recChanList);
    else         % otherwise, use mono input from channel 1
        numinchan=1;
        recChanList=1;
    end
else             % otherwise, if the number of input channels is fixed
    if nargin>=6 % raise an error if user provided a different number of channels
        if numinchan~=length(recChanList)
            error(['argument recChanList must have ' num2str(numinchan) ' elements for this algorithm']);
        end
    else         % if no channels were provided, use channels 1 to numinchan.
        recChanList=1:numinchan;
    end
end
% number of output channels
numoutchan=algo('getnumoutchan',numinchan);
if numoutchan==-1 % if the algorithm's number of output channels is not fixed
    if nargin>=5  % if output channels were provided, use them to determine number of channels.
        numoutchan=length(playChanList);
    else          % otherwise, provide mono output on channel 1
        numoutchan=1;
        playChanList=1;
    end
else             % otherwise, if the number of output channels is fixed
    if nargin>=5 % raise an error if user provided a different number of channels
        if numoutchan~=length(playChanList)
            if numoutchan==1
                out_dist=ones(1,length(playChanList));
            else
                error(['argument playChanList must have ' num2str(numoutchan) ' elements for this algorithm']);
            end
        end
    else         % if no channels were provided, use channels 1 to numoutchan.
        playChanList=1:numoutchan;
    end
end

% parameters
pnames=algo('getparamnames');   % get parameter names from algorithm implementation
pranges=algo('getparamranges'); % get parameter ranges
param=zeros(size(pranges));      % initialize param array
if nargin>=4 && numel(initparam)>0,  % initparam is given, use it
    param=initparam;
else                  % otherwise initialize to 0 or closest possible value
    for i=1:length(pranges)
        param(i)=max(min(0,pranges{i}(2)),pranges{i}(1));
    end
end

% initialize initdata if necessary
if nargin<3, initdata=[]; end

% initialize state
info=struct('initdata',initdata,'fs',fs,'pagesize',pagesize,'numinchan',numinchan,'numoutchan',numoutchan);
[~,state]=algo('init',info,param);

% initialize GUI
if ~isempty(pnames)
    % close figure used previously for this algorithm and set up a new one.
    close(findobj('type','figure','name',['realtime_processing: ' func2str(algo)]))
    fignum=figure('name',['realtime_processing: ' func2str(algo)]); % give it a name so it can be found again
    % create vectors for slider and label handles
    paramlabels=zeros(size(pnames));
    sliders=zeros(size(pnames));
    valuelabels=zeros(size(pnames));
    % create the sliders and labels (names and values)
    for i=1:length(pnames)
        paramlabels(i) = uicontrol('Style', 'text', 'String',pnames{i},'Position', [-45+i*60,390,50,20]);
        sliders(i) = uicontrol('Style', 'slider', 'Min',pranges{i}(1),'Max',pranges{i}(2),'Value',param(i),...
            'Position', [-30+i*60,40,20,340]);
        valuelabels(i) = uicontrol('Style', 'text', 'String',num2str(param(i)),'Position', [-45+i*60,10,50,20]);
    end
    % set size of figure window
    pos=get(fignum,'Position');
    pos(3)=length(pnames)*60+20; % width
    pos(4)=420;                  % height
    set(fignum,'Position',pos);
    % make sliders and labels adapt to changing window size
    set(paramlabels,'Units','normalized');
    set(sliders,'Units','normalized');
    set(valuelabels,'Units','normalized');
    drawnow
end

% queue two empty pages
activepages=[0 0];
activepages(1)=playrec('rec',pagesize,recChanList);
activepages(2)=playrec('rec',pagesize,recChanList);

% make a zeros vector for the recorded data if necessary
if nargout>=1
    recdata=zeros(numpages*pagesize,numinchan);
end
% make a zeros vector for the played back (=processed) data if necessary
if nargout>=2
    playdata=zeros(numpages*pagesize,numoutchan);
end

% perform real time processing loop
for i=1:numpages
    % update parameters
    drawnow % update parameter values
    for j=1:length(param)
        param(j)=get(sliders(j),'Value'); % read value from slider
        set(valuelabels(j),'String',num2str(param(j))); % update label
    end
    drawnow % needs to be called again to draw the updated labels
    % wait until next active page finishes
    playrec('block',activepages(1));
    % fetch page that was just recorded
    inbuf=playrec('getRec',activepages(1));
    if nargout>=1
        recdata((i-1)*pagesize+(1:pagesize),:)=inbuf;
    end
    % process this buffer
    [outbuf,state]=algo('process',inbuf,param,state);
    % queue buffer and update active pages list
    activepages=[activepages(2:end),playrec('playrec',outbuf*out_dist,playChanList,-1,recChanList)];
    if nargout>=2
        playdata((i-1)*pagesize+(1:pagesize),:)=outbuf;
    end
end