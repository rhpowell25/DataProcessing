function [target_dirs, target_centers] = Identify_Targets(xds)

%% Display the function
disp('Identifying all target directions & target centers:')

%% Extract the trial directions
target_dir_idx = xds.trial_target_dir;
unique_target_dirs = unique(target_dir_idx);

% Counts the number of directions used
num_dirs = length(unique_target_dirs);

% Pull the target centers of each succesful trial
tgt_Center_header = contains(xds.trial_info_table_header, 'TgtDistance');
tgt_Center_idx = cell2mat(xds.trial_info_table(:, tgt_Center_header));
unique_targets = unique(tgt_Center_idx);

% Counts the number of targets used
num_tgts = length(unique_targets);

% Set the loop counter
cc = 1;

%% Begin the loop through all directions
for jj = 1:num_dirs

    %% Indexes for all rewarded trials
    total_rewarded_idx = find((xds.trial_result == 'R') & (target_dir_idx == unique_target_dirs(jj)));
    rewarded_tgts = tgt_Center_idx(total_rewarded_idx);

    %% Find the number of targets in that particular direction
   
    % Define the output variables
    if jj == 1
        target_centers = zeros(num_dirs*num_tgts,1);
        target_dirs = zeros(num_dirs*num_tgts,1);
    end

    %% Loop through the target centers
    for kk = 1:num_tgts

        rewarded_idx = total_rewarded_idx(rewarded_tgts == unique_targets(kk));

        %% Skip the function if less than 5 succesful trials in that direction

        if length(rewarded_idx) < 5 || isempty(rewarded_idx)
            target_dirs(cc) = [];
            target_centers(cc) = [];
            continue
        end

        % Defining the output variables
        target_centers(cc) = round(unique_targets(kk), 2);
        target_dirs(cc) = unique_target_dirs(jj);

        % Adding to the loop counter
        cc = cc + 1;

    end % End of target center loop
    
end % End of target direction loop








