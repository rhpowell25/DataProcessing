
%% Define the experiments that will be examined 
clear
clc

% Define the file path
XDS_Path = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pancake\20220921\XDS\Unsorted\';

% Identify all the .mat files in the sorted path
XDS_File_Path = strcat(XDS_Path, '*.mat');
XDS_Files = dir(XDS_File_Path);

% Do you want to convert to degrees? ('Yes' or 'No')
conv_deg = 'No';

%% Loop through the different experiments

for xx = 1:length(XDS_Files)

    %% Load the xds file
    File_Name = XDS_Files(xx).name;
    disp(File_Name);
    load(strcat(XDS_Path, File_Name));

    %% Remove the extraneous header labels
    if length(xds.trial_info_table_header) ~= width(xds.trial_info_table)
        Variables_idx = contains(xds.trial_info_table_header, 'Variables');
        xds.trial_info_table_header(Variables_idx) = [];
        Row_idx = contains(xds.trial_info_table_header, 'Row');
        xds.trial_info_table_header(Row_idx) = [];
        Properties_idx = contains(xds.trial_info_table_header, 'Properties');
        xds.trial_info_table_header(Properties_idx) = [];
    end

    %% Find the number of targets
    tgt_Center_idx = contains(xds.trial_info_table_header, 'tgtCenter');
    if ~any(tgt_Center_idx)
        tgt_Center_idx = contains(xds.trial_info_table_header, 'tgtCtr');
        xds.trial_info_table_header{tgt_Center_idx} = 'tgtCenter';
    end

    %% Convert radians to degrees
    if strcmp(conv_deg, 'Yes')
        tgt_dir_idx = find(contains(xds.trial_info_table_header, 'tgtDir'));
        for ii = 1:height(xds.trial_info_table)
            xds.trial_target_dir(ii) = rad2deg(xds.trial_info_table{ii, tgt_dir_idx});
            xds.trial_info_table{ii, tgt_dir_idx} = rad2deg(xds.trial_info_table{ii, tgt_dir_idx});
        end
    end

    %% Add an extra header for the polar coordinate target centers
    if ~any(strcmp(xds.trial_info_table_header, 'TgtDistance'))
        Dist_idx = length(xds.trial_info_table_header) + 1;
        xds.trial_info_table_header{Dist_idx} = 'TgtDistance';
    else
        Dist_idx = find(strcmp(xds.trial_info_table_header, 'TgtDistance'));
    end

    %% Add the polar coordinates to the xds trial info table
    xds.trial_info_table(:, Dist_idx) = {[]};
    for ii = 1:height(xds.trial_info_table)
        tgt_cntrs = xds.trial_info_table{ii, tgt_Center_idx};
        xds.trial_info_table{ii, Dist_idx} = round(sqrt((tgt_cntrs(1,1))^2 + (tgt_cntrs(1,2))^2), 1);
    end

    disp('Saving:')
    save_file = strcat(XDS_Files(xx).name);
    save(strcat(XDS_Path, save_file), 'xds', '-v7.3');

    clear xds

end % End the xds loop













