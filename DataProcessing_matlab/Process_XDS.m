function [xds_morn, xds_noon] = Process_XDS(xds_morn, xds_noon, Match_The_Targets)

%% Remove all the NaN's

[xds_morn] = NaN_Remover(xds_morn);
[xds_noon] = NaN_Remover(xds_noon);

%% Find the basic indices
result_idx = find(strcmp(xds_morn.trial_info_table_header, 'result'));
tgtDir_idx = find(strcmp(xds_morn.trial_info_table_header, 'tgtDir'));
TgtDistance_idx = contains(xds_morn.trial_info_table_header, 'TgtDistance');

%% Check for mismatches in targets

if Match_The_Targets == 1

    % Find target centers & directions
    [target_dirs_morn, target_centers_morn] = Identify_Targets(xds_morn);
    [target_dirs_noon, target_centers_noon] = Identify_Targets(xds_noon);

    [Matching_Idxs_Morn, Matching_Idxs_Noon] = ...
        Match_Targets(target_dirs_morn, target_dirs_noon, target_centers_morn, target_centers_noon);

    % Only use the info of targets conserved between morning & noon
    if ~all(Matching_Idxs_Morn) || ~all(Matching_Idxs_Noon)
    
        disp('Uneven Targets Between Morning & Afternoon');
        Mismatched_Idxs_Morn = ~Matching_Idxs_Morn;
        Mismatched_Idxs_Noon = ~Matching_Idxs_Noon;
    
        % Clean the morning file
        tgt_Center_idx = cell2mat(xds_morn.trial_info_table(:, TgtDistance_idx));
        morn_removal_target_dirs = target_dirs_morn(Mismatched_Idxs_Morn);
        morn_removal_target_centers = target_centers_morn(Mismatched_Idxs_Morn);
        for jj = 1:length(morn_removal_target_dirs)
            % Indexes for rewarded trials
            rewarded_idx = find((xds_morn.trial_result == 'R') & (xds_morn.trial_target_dir == morn_removal_target_dirs(jj)) & ...
                (tgt_Center_idx == morn_removal_target_centers(jj)));
    
            % Mark those trials as failures
            xds_morn.trial_info_table(rewarded_idx, result_idx) = {'F'};
            xds_morn.trial_result(rewarded_idx) = 'F';
        end
    
        % Clean the afternoon file
        tgt_Center_idx = cell2mat(xds_noon.trial_info_table(:, TgtDistance_idx));
        noon_removal_target_dirs = target_dirs_noon(Mismatched_Idxs_Noon);
        noon_removal_target_centers = target_centers_noon(Mismatched_Idxs_Noon);
        for jj = 1:length(noon_removal_target_dirs)
            % Indexes for rewarded trials
            rewarded_idx = find((xds_noon.trial_result == 'R') & (xds_noon.trial_target_dir == noon_removal_target_dirs(jj)) & ...
                (tgt_Center_idx == noon_removal_target_centers(jj)));
    
            % Mark those trials as failures
            xds_noon.trial_info_table(rewarded_idx, result_idx) = {'F'};
            xds_noon.trial_result(rewarded_idx) = 'F';
        end
    
    end

end

%% Process problems with specific XDS files

% Date
file_name = xds_morn.meta.rawFileName;
xtra_info = extractAfter(file_name, '_');
Date = erase(file_name, strcat('_', xtra_info));

% Task
if strcmp(xds_morn.meta.task, 'multi_gadget')
    Task = 'PG';
else
    Task = xds_morn.meta.task;
end

if strcmp(Date, '20220907')

    % Remove a bad unit
    unit_name = 'elec63_1';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

    if strcmp(Task, 'WS')

        % In the morning experiment 4/6 ulnar deviation trials had trial lengths faster than 0.2 sec
        % Remove all trials in the -135 degree direction
        % Find the target directions at -135
        ext_idx = find(cell2mat(xds_morn.trial_info_table(:,tgtDir_idx)) == -135);
        % Mark those trials as failures
        xds_morn.trial_info_table(ext_idx, result_idx) = {'F'};
        xds_morn.trial_result(ext_idx) = 'F';
        ext_idx = find(cell2mat(xds_noon.trial_info_table(:,tgtDir_idx)) == -135);
        % Mark those trials as failures
        xds_noon.trial_info_table(ext_idx, result_idx) = {'F'};
        xds_noon.trial_result(ext_idx) = 'F';

    end

end

if strcmp(Date, '20210304') && strcmp(Task, 'PG')

    % Remove a bad unit
    unit_name = 'elec10_1';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

end

if strcmp(Date, '20210922') && strcmp(Task, 'PG')

    % Remove a bad unit
    unit_name = 'elec79_2';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

    % Remove a bad unit
    unit_name = 'elec86_1';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

end

if strcmp(Date, '20210917') && strcmp(Task, 'PG')

    % Remove a bad unit
    unit_name = 'elec72_1';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

end

if strcmp(Date, '20210902') && strcmp(Task, 'PG')

    % In this experiment there were too few succesful trials at 15
    % Remove all trials with a target center of 15
    % Pull the target center distances of each succesful trial  
    tgt_cntrs = zeros(length(xds_morn.trial_info_table), 1);
    for ii = 1:height(xds_morn.trial_info_table)
        tgt_cntrs(ii,1) = xds_morn.trial_info_table{ii, TgtDistance_idx};
    end
    % Find the target centers at 15
    center_idx = find(tgt_cntrs == 15);
    % Mark those trials as failures
    xds_morn.trial_info_table(center_idx, result_idx) = {'F'};
    xds_morn.trial_result(center_idx) = 'F';
    
    tgt_cntrs = zeros(length(xds_noon.trial_info_table), 1);
    for ii = 1:height(xds_noon.trial_info_table)
        tgt_cntrs(ii,1) = xds_noon.trial_info_table{ii, TgtDistance_idx};
    end
    % Find the target centers at 15
    center_idx = find(tgt_cntrs == 15);
    % Mark those trials as failures
    xds_noon.trial_info_table(center_idx, result_idx) = {'F'};
    xds_noon.trial_result(center_idx) = 'F';

end

if strcmp(Date, '20210722') && strcmp(Task, 'PG')

    % Remove a bad unit
    unit_name = 'elec57_1';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

    % Remove the poor EMG
    muscle_name = strings;
    muscle_name(1) = 'FDS1';
    muscle_name(2) = 'FDS2';
    muscle_name(3) = 'FDP1';
    % Remove the EMG
    for ii = 1:length(muscle_name)
        % Find the indices of the muscles of interest
        M = find(contains(xds_morn.EMG_names, muscle_name(ii)));
        xds_morn.EMG_names(M) = [];
        xds_morn.EMG(:, M) = [];
        xds_morn.raw_EMG(:, M) = [];
        M = find(contains(xds_noon.EMG_names, muscle_name(ii)));
        xds_noon.EMG_names(M) = [];
        xds_noon.EMG(:, M) = [];
        xds_noon.raw_EMG(:, M) = [];
    end

end

if strcmp(Date, '20210722') && strcmp(Task, 'WS')

    % Remove a bad unit
    unit_name = 'elec42_1';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

    % Remove the poor EMG
    muscle_name = strings;
    muscle_name(1) = 'FCR2';
    % Remove the EMG
    for ii = 1:length(muscle_name)
        % Find the indices of the muscles of interest
        M = find(contains(xds_morn.EMG_names, muscle_name(ii)));
        xds_morn.EMG_names(M) = [];
        xds_morn.EMG(:, M) = [];
        xds_morn.raw_EMG(:, M) = [];
        M = find(contains(xds_noon.EMG_names, muscle_name(ii)));
        xds_noon.EMG_names(M) = [];
        xds_noon.EMG(:, M) = [];
        xds_noon.raw_EMG(:, M) = [];
    end

end

if strcmp(Date, '20210713') && strcmp(Task, 'PG')

    % Remove a bad unit
    unit_name = 'elec86_2';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

end

if strcmp(Date, '20210623') && strcmp(Task, 'WS')

    % Remove a bad unit
    unit_name = 'elec36_1';
    [xds_morn] = Remove_Unit(xds_morn, unit_name);
    [xds_noon] = Remove_Unit(xds_noon, unit_name);

end

if strcmp(Date, '20210617') && strcmp(Task, 'WS')

    % In this experiment the wrist extension target distance was too small
    % Remove all trials in the 180 degree direction
    % Find the target directions at 180
    ext_idx = find(cell2mat(xds_morn.trial_info_table(:,tgtDir_idx)) == 180);
    % Mark those trials as failures
    xds_morn.trial_info_table(ext_idx, result_idx) = {'F'};
    xds_morn.trial_result(ext_idx) = 'F';
    ext_idx = find(cell2mat(xds_noon.trial_info_table(:,tgtDir_idx)) == 180);
    % Mark those trials as failures
    xds_noon.trial_info_table(ext_idx, result_idx) = {'F'};
    xds_noon.trial_result(ext_idx) = 'F';

end

if strcmp(Date, '20210610') && strcmp(Task, 'WS')

    % In this experiment the wrist extension target distance was too small
    % Remove all trials in the 180 degree direction
    % Find the target directions at 180
    ext_idx = find(cell2mat(xds_morn.trial_info_table(:,tgtDir_idx)) == 180);
    % Mark those trials as failures
    xds_morn.trial_info_table(ext_idx, result_idx) = {'F'};
    xds_morn.trial_result(ext_idx) = 'F';
    ext_idx = find(cell2mat(xds_noon.trial_info_table(:,tgtDir_idx)) == 180);
    % Mark those trials as failures
    xds_noon.trial_info_table(ext_idx, result_idx) = {'F'};
    xds_noon.trial_result(ext_idx) = 'F';
    
end

%% Zero the force if using the WB task
if strcmp(xds_morn.meta.task, 'WB')
    base_force_x_morn = zeros(length(xds_morn.trial_start_time),1);
    base_force_y_morn = zeros(length(xds_morn.trial_start_time),1);
    base_force_x_noon = zeros(length(xds_noon.trial_start_time),1);
    base_force_y_noon = zeros(length(xds_noon.trial_start_time),1);
    for ii = 1:length(xds_morn.trial_start_time)
        idx_morn = find(xds_morn.time_frame > xds_morn.trial_start_time(ii) & ...
            xds_morn.time_frame < xds_morn.trial_gocue_time(ii)); 
        base_force_x_morn(ii,1) = mean(xds_morn.force(idx_morn, 1));
        base_force_y_morn(ii,1) = mean(xds_morn.force(idx_morn, 2));
    end
    for ii = 1:length(xds_noon.trial_start_time)
        idx_noon = find(xds_noon.time_frame > xds_noon.trial_start_time(ii) & ...
            xds_noon.time_frame < xds_noon.trial_gocue_time(ii)); 
        base_force_x_noon(ii,1) = mean(xds_noon.force(idx_noon, 1));
        base_force_y_noon(ii,1) = mean(xds_noon.force(idx_noon, 2));
    end
    xds_morn.force(:,1) = xds_morn.force(:,1) - mean(base_force_x_morn);
    xds_morn.force(:,2) = xds_morn.force(:,2) - mean(base_force_y_morn);
    xds_noon.force(:,1) = xds_noon.force(:,1) - mean(base_force_x_noon);
    xds_noon.force(:,2) = xds_noon.force(:,2) - mean(base_force_y_noon);
end












