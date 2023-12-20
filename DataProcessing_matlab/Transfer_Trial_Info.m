%% Set the Path of the files
clc
clear
xds_path = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Mojito\20230902\';

%% Identify all the unsorted .mat files in the unsorted path
xds_files = strcat(xds_path, '*.mat');
unsorted_files = {dir(xds_files).name};
% Remove any sorted files from the list
sorted_idxs = ~contains(unsorted_files, '-s');
unsorted_files = unsorted_files(sorted_idxs);

%% Identify all the sorted .mat files in the sorted path
xds_sorted = strcat(xds_path, '*-s.mat');
sorted_file = {dir(xds_sorted).name};

%% Transfer the info from the unsorted to sorted files

for ii = 1:length(unsorted_files)
    % Load the unsorted file
    file_name_in_list = unsorted_files{ii};
    disp('*******************************');
    disp('Unsorted:');
    disp(file_name_in_list);
    load(strcat(xds_path, file_name_in_list));
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
    file_name_in_list = sorted_file{ii};
    disp('Sorted:');
    disp(file_name_in_list);
    load(strcat(xds_path, file_name_in_list));
    % Save the unsorted variables in the sorted file
    if isequal(xds.meta.task, 'WS')
        xds.curs_p = curs_p;
        xds.curs_v = curs_v;
        xds.curs_a = curs_a;
    end
    if exist('EMG', 'var')
        xds.has_EMG = true;
        xds.mea.hasEmg = true;
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
    
    %% Save the updated xds
    Save_XDS(xds);
    disp('*******Done*********');
end

