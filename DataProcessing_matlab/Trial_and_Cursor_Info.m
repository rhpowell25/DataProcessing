%% Set the Path of the files
clc
clear
xds_path_unsorted = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pancake\20221102\';
xds_path_sorted = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pancake\20221102\Sorted\';

%% Identify all the .mat files in the unsorted path
xds_unsorted = strcat(xds_path_unsorted, '*.mat');
unsorted_file = dir(xds_unsorted);

%% Identify all the .mat files in the sorted path
xds_sorted = strcat(xds_path_sorted, '*.mat');
sorted_file = dir(xds_sorted);

%% Transfer the info from the unsorted to sorted files

for ii = 1:length(unsorted_file)
    % Load the unsorted file
    file_name_in_list = unsorted_file(ii).name;
    disp('*******************************');
    disp('Unsorted:');
    disp(file_name_in_list);
    load(strcat(xds_path_unsorted, file_name_in_list));
    % Extract the variables from the unsorted file
    if isequal(xds.meta.task, 'WS')
        curs_p = xds.curs_p;
        curs_v = xds.curs_v;
        curs_a = xds.curs_a;
    end
    if isequal(xds.has_EMG, 1)
        raw_EMG_time_frame = xds.raw_EMG_time_frame;
        EMG_names = xds.EMG_names;
        raw_EMG = xds.raw_EMG;
        EMG = xds.EMG;
    end
    trial_info_table_header = xds.trial_info_table_header;
    trial_info_table = xds.trial_info_table;
    trial_gocue_time = xds.trial_gocue_time;
    trial_start_time = xds.trial_start_time;
    trial_end_time = xds.trial_end_time;
    trial_result = xds.trial_result;
    trial_target_dir = xds.trial_target_dir;
    trial_target_corners = xds.trial_target_corners;
    clear xds
    % Load the sorted file
    file_name_in_list = sorted_file(ii).name;
    disp('Sorted:');
    disp(file_name_in_list);
    load(strcat(xds_path_sorted, file_name_in_list));
    % Save the unsorted variables in the sorted file
    if isequal(xds.meta.task, 'WS')
        xds.curs_p = curs_p;
        xds.curs_v = curs_v;
        xds.curs_a = curs_a;
    end
    if isequal(xds.has_EMG, 1)
        xds.raw_EMG_time_frame = raw_EMG_time_frame;
        xds.EMG_names = EMG_names;
        xds.raw_EMG = raw_EMG;
        xds.EMG = EMG;
    end
    xds.trial_info_table_header = trial_info_table_header;
    xds.trial_info_table = trial_info_table;
    xds.trial_gocue_time = trial_gocue_time;
    xds.trial_start_time = trial_start_time;
    xds.trial_end_time = trial_end_time;
    xds.trial_result = trial_result;
    xds.trial_target_dir = round(trial_target_dir);
    xds.trial_target_corners = trial_target_corners;
    %% Add the target center header
    % Exclude nan's
    target_dir_idx = round(xds.trial_target_dir);
    nan_idx_dir = isnan(target_dir_idx);
    target_dir_idx(nan_idx_dir) = [];
    clear nan_idx_dir

    % Remove the extraneous header labels
    if length(xds.trial_info_table_header) ~= width(xds.trial_info_table)
        Variables_idx = contains(xds.trial_info_table_header, 'Variables');
        xds.trial_info_table_header(Variables_idx) = [];
        Row_idx = contains(xds.trial_info_table_header, 'Row');
        xds.trial_info_table_header(Row_idx) = [];
        Properties_idx = contains(xds.trial_info_table_header, 'Properties');
        xds.trial_info_table_header(Properties_idx) = [];
    end
    % Find the number of targets in that particular direction
    tgt_Center_idx = contains(xds.trial_info_table_header, 'tgtCenter');
    if ~any(tgt_Center_idx)
        tgt_Center_idx = contains(xds.trial_info_table_header, 'tgtCtr');
        xds.trial_info_table_header{tgt_Center_idx} = 'tgtCenter';
    end
    % Add an extra header for the polar coordinate target centers
    if ~any(strcmp(xds.trial_info_table_header, 'TgtDistance'))
        Dist_idx = length(xds.trial_info_table_header) + 1;
        xds.trial_info_table_header{Dist_idx} = 'TgtDistance';
    else
        Dist_idx = find(strcmp(xds.trial_info_table_header, 'TgtDistance'));
    end

    % Add the polar coordinates to the xds trial info table
    xds.trial_info_table(:, Dist_idx) = {[]};
    for pp = 1:height(xds.trial_info_table)
        tgt_cntrs = xds.trial_info_table{pp, tgt_Center_idx};
        xds.trial_info_table{pp, Dist_idx} = round(sqrt((tgt_cntrs(1,1))^2 + (tgt_cntrs(1,2))^2), 1);
    end
    
    %% Save the updated xds
    save(strcat(xds_path_sorted, file_name_in_list), 'xds', '-v7.3');
    disp('*******Done*********');
end

