function [xds] = Baseline_EMG_Rejection(xds, muscle_groups)

%% Display the function being used
disp('Baseline_EMG_Rejection:');

% This script rejects any trials whose baseline EMG exceeds 4 standard
% deviations of the mean baseline EMG

%% Define the muscles 

muscle_names = strings;

if strcmp(muscle_groups, 'Flex')
    muscle_names(1) = 'FCR';
    muscle_names(2) = 'FCU';
end

if strcmp(muscle_groups, 'Exten')
    muscle_names(1) = 'ECR';
    muscle_names(2) = 'ECU';
end

if strcmp(muscle_groups, 'Both')
    muscle_names(1) = 'FCR';
    muscle_names(2) = 'FCU';
    muscle_names(3) = 'ECR';
    muscle_names(4) = 'ECU';
end

if strcmp(muscle_groups, 'Grasp')
    muscle_names(1) = 'FDS';
    muscle_names(2) = 'FDP';
end

if strcmp(muscle_groups, 'Custom')
    muscle_names(1) = 'FCR';
end

% Find the indices of the muscles of interest
muscle_idx = struct([]);
cc = 0;
for ii = 1:length(muscle_names)
    muscle_idx{ii,1} = find(contains(xds.EMG_names, muscle_names(ii)));
    % Find how many muscles there are
    cc = cc + length(muscle_idx{ii,1});
end

% Concatenate the indices
M = zeros(cc,1);
cc = 1;
for ii = 1:length(muscle_idx)
    for jj = 1:length(muscle_idx{ii})
        M(cc) = muscle_idx{ii,1}(jj);
        cc = cc + 1;
    end
end

if strcmp(muscle_groups, 'All')
    M = (1:12);
end

%% Basic Settings, some variable extractions, & definitions

% Define the window for the baseline phase
time_before_gocue = 0.4;

%% Index for rewarded trials

total_rewarded_idx = find((xds.trial_result == 'R'));

%% Loop to extract only rewarded trials 

% Rewarded go-cues
rewarded_gocue_time = zeros(length(total_rewarded_idx),1);
for ii = 1:length(total_rewarded_idx)
    rewarded_gocue_time(ii) = xds.trial_gocue_time(total_rewarded_idx(ii));
end

%% Removing non-numbers
% Go-cue NaN's
nan_idx_gocue = find(isnan(rewarded_gocue_time));
rewarded_gocue_time(nan_idx_gocue) = [];
total_rewarded_idx(nan_idx_gocue) = [];
clear nan_idx_gocue

%% Round the trial data down to match the time frame
rewarded_gocue_time = round(rewarded_gocue_time, abs(floor(log10(xds.bin_width))));
        
%% EMG and time aligned to specified event
% Find the rewarded times in the whole trial time frame
rewarded_gocue_idx = zeros(height(total_rewarded_idx),1);
for ii = 1:length(total_rewarded_idx)
    rewarded_gocue_idx(ii) = find(xds.time_frame == rewarded_gocue_time(ii));
end

aligned_baseline_EMG = struct([]); % EMG during each successful trial
aligned_baseline_EMG_timing = struct([]); % Time points during each succesful trial
for ii = 1:length(total_rewarded_idx)
    aligned_baseline_EMG{ii, 1} = xds.EMG((rewarded_gocue_idx(ii) - ...
        (time_before_gocue / xds.bin_width) : rewarded_gocue_idx(ii)), :);
    aligned_baseline_EMG_timing{ii, 1} = xds.time_frame((rewarded_gocue_idx(ii) - ... 
        (time_before_gocue / xds.bin_width) : rewarded_gocue_idx(ii)));
end

%% Putting all succesful trials in one array

all_trials_baseline_EMG = struct([]);
for ii = 1:length(M)
    all_trials_baseline_EMG{ii,1} = zeros(length(aligned_baseline_EMG{1,1}),length(total_rewarded_idx));
    for jj = 1:length(total_rewarded_idx)
        all_trials_baseline_EMG{ii,1}(:,jj) = aligned_baseline_EMG{jj, 1}(:, M(ii));
    end
end

%% Calculating average EMG (Average per trial)

per_trial_avg_baseline_EMG = zeros(length(aligned_baseline_EMG),length(M));
for ii = 1:length(M)
    for jj = 1:length(aligned_baseline_EMG)
        per_trial_avg_baseline_EMG(jj,ii) = mean(all_trials_baseline_EMG{ii,1}(:,jj));
    end
end

%% Calculate the mean and standard deviation

Baseline_EMG_mean = zeros(length(M), 1);
Baseline_EMG_std = zeros(length(M), 1);
for ii = 1:length(M)
    Baseline_EMG_mean(ii) = mean(per_trial_avg_baseline_EMG(:,ii));
    Baseline_EMG_std(ii) = std(per_trial_avg_baseline_EMG(:,ii));
end

%% Find and reject trials whose baseline EMG exceed 4 standard deviations from the mean

xds_result_idx = find(strcmp(xds.trial_info_table_header, 'result'));
for ii = 1:length(M)
    EMG_reject_idx = per_trial_avg_baseline_EMG(:,ii) >= (Baseline_EMG_mean(ii) + 4*Baseline_EMG_std(ii));
    xds_reject_idx  = total_rewarded_idx(EMG_reject_idx);
    xds.trial_info_table(xds_reject_idx, xds_result_idx) = {'F'};
    xds.trial_result(xds_reject_idx) = 'F';
end


