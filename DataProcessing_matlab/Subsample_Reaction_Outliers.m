function [xds] = Subsample_Reaction_Outliers(xds)

%% Display the function being used
disp('Subsample Reaction Time Outliers:');

% This script rejects any trials with outlier reaction times

%% Extract the target directions & centers
[target_dirs, target_centers] = Identify_Targets(xds);

%% Settings to loop through every target direction

% Counts the number of directions used
num_dirs = length(target_dirs);

%% Begin the loop through all directions
for jj = 1:num_dirs

    %% Times for rewarded trials
    [rewarded_idxs] = Rewarded_Indexes(xds, target_dirs(jj), target_centers(jj));
    [rewarded_gocue_time] = EventAlignmentTimes(xds, target_dirs(jj), target_centers(jj), 'trial_gocue');
    [Alignment_Times] = EventAlignmentTimes(xds, target_dirs(jj), target_centers(jj), 'task_onset');

    %% Find the difference between times & their outliers
    rxn_times = Alignment_Times - rewarded_gocue_time;

    rxn_median = median(rxn_times);
    rxn_std = std(rxn_times);
    rxn_time_outliers = rxn_times >= (rxn_median + 2*rxn_std);

    outlier_idx = rewarded_idxs(rxn_time_outliers);

    %% Remove the force outliers from xds
    result_idx = find(strcmp(xds.trial_info_table_header, 'result'));
    xds.trial_info_table(outlier_idx, result_idx) = {'F'};
    xds.trial_result(outlier_idx) = 'F';

end % End of target loop
 


