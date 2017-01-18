function[output,state] = RT_EOG(cmd,state)

% RT_EOG
% To be adapted by students of the Ringpraktikum Neuro-Signale course. When
% called, this function should retreive the next availabe EOG acquisition
% buffer from the Biopac MP36 system, process that buffer and estimate the
% angle of the users gaze in real-time. The function is designed to be
% called repeatedly within a real-time loop of EOG_RT_Framework.m.
%
% Input/Output Variables:
%
% cmd:      Input string used to choose which phase of the function is excuted.
%           'init' executes the intialization phase of the function used to
%           compute initial conditions of variables, filter coefficients,
%           etc that should be computed before the real-time loop commences.
%           'process' executes the main processing phases that should be
%           called within the real-time processing loop
%
% state:    Input/Output structure used to store any variables that need to
%           be stored and passed between subsequent calls of RT_EOG. You
%           are free to add any fields to this structure as you see fit,
%           which can be initialized and set within this function. However,
%           the following fields must be included and must be initiliazed
%           OUTSIDE this function.
%
%           state.fs: Sampling rate of EOG acquisition with BIOPAC.
%
%           state.Nacq_buff: Length of EOG acquisition buffer in samples.
%
%           state.is_online: If 1, the function retreives buffers from the
%           BIOPAC system. If 0, function loads in a pre-recorded EOG
%           signal and processes it as if it was being read from the BIOPAC
%
%           state.fr_idx: Tracks how many buffers have been retrieved and
%           processed since the start of execution. Can be used to avoid
%           computing gaze angles while the EOG signal is fluctuating due
%           to system switch-on artefacts.
%
% output:   Output structure comprising an variable you would like to have
%           accessible once the function returns. You can add any fields to
%           this structure you desired, however the following must be
%           included for correct operation of with EOG_RT_Framework
%
%           output.V_raw: the raw EOG data retrieved from the acquistion
%           buffer
%
%           output.V_LP: lowpass filtered version of EOG buffer
%
%           output.V_BP: bandpass version of EOG buffer
%
%           output.edge_idx: vector that is same length as EOG buffer that
%           has contains +1 and -1 on samples where a saccade start and end
%           have respectively been detected, and 0 on others.
%
%           output.V_est: (scaler) the artefact-free estimate of EOG signal

%           output.ang_est: (scaler) the estimated angle of the user's gaze
%           as of the end of the EOG buffer

if strcmpi(cmd,'process')
    %% Read in next available EOG buffer
    [~, output.V_raw] = biopacAPI(state.is_online,'receiveMPData',state.Nacq_buff); % pull eog data frame
    
    %% Apply filtering to Acq Buffer (Task 3.3)

    output.V_LP = 0;
    output.V_BP = 0;
    
    if state.fr_idx > 20 % Don't perform the following computations of first few EOG acquisition frames
        
        %% Detect Saccade Edges (Task 3.4)

        output.dV_LP = 0;
        output.edge_idx = 0;
        
        %% Determine saccade start & end voltages, and compute artefact free EOG estimate (Task 3.5) 
        
        for buff_idx = 1:length(output.edge_idx)
            switch output.edge_idx(buff_idx)
                case 1 % Start of a saccade
                    
                    % if *sloppy saccade detected*
                    
                    % elseif *rapid eye movement detected*                        
                        
                        % Compute edge voltages accordingly
                        
                    % else *normal saccade start detected*
                    
                    % end

                case -1 % End of a saccade
                    

                    
                case 0  % Neither type of edge was detected on this sample
                    
                    % Increment timers if active.
                    % Check if it is time to compute saccade edge voltage
                    % Update artefact-free estimate if needed
            end
        end
    else
        % Do NOT change this
        output.edge_idx = zeros(size(output.V_raw));
    end
    
    %% Auto recalibration (Task 3.7)

    
    %% Convert from EOG Voltage to Gaze Angle (Task 3.6)
    output.V_est = state.V_est;
    output.ang = 0;
    
    %% Update Save Buffers HERE (All Tasks) %%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmpi(cmd,'init')
    %% Fitler Coefficients & Filter State Variables for EOG Filtering (Task 3.3)
    
    
    %% Parameters, Coefficients and Save Variables for Saccade Edge Detection (Task 3.4)

    % dV Threshold
    
    % Moving-average filter coefficients and save variables
    
    

    %%  Parameters and Save Variables for Saccade Initial and Final Level Estimation (Task 3.5)
    % (Hint) Variables you should include (adjust values as needed)
    state.N_sloppy = 0;         % Min samples the eye has to be stationary to not be considered a momentary pause due to sloppy saccade
    state.Navg = 0;             % samples to average over to estimate start/end level of saccade
    state.N_rapid = 0;          % Min samples the eye must be stationary before moving to not be considerd a rapid succession saccade
    
    state.timer_end = 0;         % Timer triggered once end of saccade detected
    state.V_start = 0;          % Start V of current saccade
    state.V_end = 0;            % End V of current saccade
    
    state.V_est = 0;            % Current (scaler) estimate of artefact-free EOG signal
    
    % Any other parameters, save buffers, etc, needed
    
    
    %% Add Calibration Gradient (Task 3.6)
    
    load(state.calib_file);
    state.calib_grad = calib_grad;  % Save calibration gradient to state structure
    
    %% Initialize Parameters for Auto-Recalibration (Task 3.7)
    
    
    %% Initialization Biopac (Do NOT alter)
    if state.is_online
        dirpath = 'C:\Program Files (x86)\BIOPAC Systems, Inc\BIOPAC Hardware API 2.2 Education'; % path of mpdev header file
        biopacAPI(state.is_online,'initMPDevCom',dirpath); % initialize libraries
    else       
        biopacAPI(state.is_online,'initMPDevCom',state.EOG_file);% initialize libraries
    end
    
    biopacAPI(state.is_online, 'help');                     % print available dll functions
    biopacAPI(state.is_online, 'connectMPDev');             % Connect with MP unit
    biopacAPI(state.is_online, 'setSampleRate', state.fs);     % Set sampling rate to 500 Hz
    biopacAPI(state.is_online, 'setAcqChannels',[1 0 0 0]); % Set acquisition channels
    biopacAPI(state.is_online, 'startMPAcqDaemon');         % Start acquisition daemon
    % --> MP device is now ready to record
    biopacAPI(state.is_online, 'startAcquisition');         % called in the end to reduce delaytime upon first buffer pull
    
    output = [];
else
    error('cmd not recognized')
end