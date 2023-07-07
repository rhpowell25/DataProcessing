function [xds] = NaN_Remover(xds)

if ~strcmp(xds.meta.task, 'FR')
    %% Display the function
    disp('Removing any NaNs:')
    
    %% Removing non-numbers in the trial go cue times
    nan_idx = isnan(xds.trial_gocue_time);
    xds.trial_info_table(nan_idx,:) = [];
    xds.trial_gocue_time(nan_idx) = [];
    xds.trial_start_time(nan_idx) = [];
    xds.trial_end_time(nan_idx) = [];
    xds.trial_result(nan_idx) = [];
    xds.trial_target_dir(nan_idx) = [];
    xds.trial_target_corners(nan_idx,:) = [];
    clear nan_idx
    
    %% Removing non-numbers in the trial start times
    nan_idx = isnan(xds.trial_start_time);
    xds.trial_info_table(nan_idx,:) = [];
    xds.trial_gocue_time(nan_idx) = [];
    xds.trial_start_time(nan_idx) = [];
    xds.trial_end_time(nan_idx) = [];
    xds.trial_result(nan_idx) = [];
    xds.trial_target_dir(nan_idx) = [];
    xds.trial_target_corners(nan_idx,:) = [];
    clear nan_idx
    
    %% Removing non-numbers in the trial end times
    nan_idx = isnan(xds.trial_end_time);
    xds.trial_info_table(nan_idx,:) = [];
    xds.trial_gocue_time(nan_idx) = [];
    xds.trial_start_time(nan_idx) = [];
    xds.trial_end_time(nan_idx) = [];
    xds.trial_result(nan_idx) = [];
    xds.trial_target_dir(nan_idx) = [];
    xds.trial_target_corners(nan_idx,:) = [];
    clear nan_idx
    
    %% Removing non-numbers in the trial target dirs
    nan_idx = isnan(xds.trial_target_dir);
    xds.trial_info_table(nan_idx,:) = [];
    xds.trial_gocue_time(nan_idx) = [];
    xds.trial_start_time(nan_idx) = [];
    xds.trial_end_time(nan_idx) = [];
    xds.trial_result(nan_idx) = [];
    xds.trial_target_dir(nan_idx) = [];
    xds.trial_target_corners(nan_idx,:) = [];
    clear nan_idx

    %% Fix changes in the number of trials
    num_trials = length(xds.trial_info_table);
    trial_num_idx = find(strcmp(xds.trial_info_table_header, 'number'));
    for ii = 1:num_trials
        xds.trial_info_table(ii,trial_num_idx) = {ii};
    end

end












