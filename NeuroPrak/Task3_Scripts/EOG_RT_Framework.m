% clear the workspace
% close all;
% clear all
clc;

%% General Intialization Parameters (ADJUST VALUES HERE ONLY) %%%%%%%%%%%%%%
% fixed variables
runtime = 25;               % runtime of processing loop
fs_acq = 500;               % sampling frequency [Hz]
Nbuff_acq = 6;              % EOG acquisition buffer size

plot_flag = 1;                % plot on = 1; off = 0;
plot_freq = 100;             % Frequency of plotting, expressed in acq buffers

is_online = 0;              % online = 1; offline = 0;

offline_EOG_file = 'Y:\teaching\Praktikum_Neuro\Matlab_Scripts_Solutions\EOG_Scripts_Solutions\EOG_Data\Example_S1.mat';
calib_file = 'Y:\teaching\Praktikum_Neuro\Matlab_Scripts_Solutions\EOG_Scripts_Solutions\grad_calib';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize save buffers

state.fs = fs_acq;                
state.Nacq_buff = Nbuff_acq;              
state.is_online = is_online;
state.EOG_file = offline_EOG_file;
state.calib_file = calib_file;
[~,state] = RT_EOG('init',state);

EOG_Vraw = zeros(ceil(state.fs*runtime/state.Nacq_buff)*state.Nacq_buff,1);
EOG_VLP = zeros(ceil(state.fs*runtime/state.Nacq_buff)*state.Nacq_buff,1);
EOG_VBP = zeros(ceil(state.fs*runtime/state.Nacq_buff)*state.Nacq_buff,1);
EOG_Vest = zeros(ceil(state.fs*runtime/state.Nacq_buff)*state.Nacq_buff,1);
Edge_idx = zeros(ceil(state.fs*runtime/state.Nacq_buff)*state.Nacq_buff,1);
EOG_Ang = zeros(ceil(state.fs*runtime/state.Nacq_buff)*state.Nacq_buff,1);

%% Real-Time Processing Loop
% here you define you long you loop runs, e.g. how many samples to retrieve
% of how long the duration is (depeding on you loop implementation)
if plot_flag
    figure
    xlabel('Time (s)')
%     set(gca,'Xlim',[0,runtime],'Ylim',[-1.2 1.2])
    hold on
end

for fr_idx = 1:ceil(state.fs*runtime/state.Nacq_buff) % runtime in terms of loop cycles
    tic
    state.fr_idx = fr_idx;
    [output,state] = RT_EOG('process',state);
    toc
    EOG_Vraw((fr_idx-1)*state.Nacq_buff + (1:state.Nacq_buff)) = output.V_raw;
    EOG_VLP((fr_idx-1)*state.Nacq_buff + (1:state.Nacq_buff)) = output.V_LP;
    EOG_VBP((fr_idx-1)*state.Nacq_buff + (1:state.Nacq_buff)) = output.V_BP;
    EOG_Vest((fr_idx-1)*state.Nacq_buff + (1:state.Nacq_buff)) = output.V_est;
    Edge_idx((fr_idx-1)*state.Nacq_buff + (1:state.Nacq_buff)) = output.edge_idx;
    EOG_Ang((fr_idx-1)*state.Nacq_buff + (1:state.Nacq_buff)) = output.ang;
    
    %% Plotting Routine
    
    if plot_flag
        
        if ~mod(fr_idx,plot_freq)
            idx_offset = (fr_idx-plot_freq)*state.Nacq_buff;
            plot_range = idx_offset +(1:plot_freq*state.Nacq_buff);
            plot(plot_range/state.fs,EOG_VLP(plot_range),'b')
            plot(plot_range/state.fs,EOG_VBP(plot_range),'r')
            plot(plot_range/state.fs,EOG_Vest(plot_range),'g')
            plot(plot_range/state.fs,EOG_Ang(plot_range),'m')
%             st_idx_tmp = find(Edge_idx(plot_range)==1);
%             scatter((st_idx_tmp+idx_offset)/state.fs,EOG_LP(st_idx_tmp+idx_offset),'r')
%             
%             end_idx_tmp = find(Edge_idx(plot_range)==-1);
%             scatter((end_idx_tmp+idx_offset)/state.fs,EOG_LP(end_idx_tmp+idx_offset),'g')
            
        end        
    end
    
    pause_time = state.Nacq_buff/state.fs-toc;
    pause(pause_time)
%     pause(0.03)
    toc
end

% Mark detected saccade starts
sacc_st_idx = find(Edge_idx==1)-1;
scatter(sacc_st_idx/state.fs,EOG_VLP(sacc_st_idx))

% Mark detected saccade ends
sacc_fin_idx = find(Edge_idx==-1)-1;
scatter(sacc_fin_idx/state.fs,EOG_VLP(sacc_fin_idx))

%% Stop BIOPAC
biopacAPI(state.is_online,'stopAcquisition')
biopacAPI(state.is_online,'disconnectMPDev')