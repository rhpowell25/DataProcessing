
function [cat_amplifier_data, amplifier_channels, cat_t_amplifier, sample_rate, cat_board_dig_in_data] = Concat_RHD_files(File_Basename)

%% Basic Settings 

% Define the output variables
cat_amplifier_data = [];
cat_t_amplifier = [];
cat_board_dig_in_data = [];

% Define the number of rhd files to concatenate
file_num = 11;

for xx = 1:file_num

    % Define the file name
    File_Name = strcat(File_Basename, num2str(xx));
    
    %% Load the RHD file
    [amplifier_data, amplifier_channels, t_amplifier, sample_rate, board_dig_in_data] = ...
        read_RHD_file(File_Name);

    %% Concatenate with the previous loop

    % EMG data
    cat_amplifier_data = cat(2, cat_amplifier_data, amplifier_data);

    % Digital data
    cat_board_dig_in_data = cat(2, cat_board_dig_in_data, board_dig_in_data);

    % Timeframe
    cat_t_amplifier = cat(2, cat_t_amplifier, t_amplifier);
    
end