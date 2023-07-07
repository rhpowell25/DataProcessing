
function [xds] = RHD_2_XDS(xds)

%% Load the RHD file

% Set the file path
file_name = xds.meta.rawFileName;

[amplifier_data, amplifier_channels, t_amplifier, rhd_samp_rate, board_dig_in_data] = read_RHD_file(file_name);

%% Find the indices of Pop's matching EMG channels

disp('Matching EMG Channels:')

EMG_names_single = strings;
for ii = 1:length(amplifier_channels)
    EMG_names_single(ii,1) = amplifier_channels(ii).custom_channel_name;
    EMG_names_single(ii,1) = erase(EMG_names_single(ii,1), '_1');
    EMG_names_single(ii,1) = erase(EMG_names_single(ii,1), '_2');
end

unique_EMG_names = unique(EMG_names_single);
unique_EMG_idx = zeros(length(unique_EMG_names),2);
for ii = 1:length(unique_EMG_idx(:,1))
    unique_idx = find(strcmp(EMG_names_single, unique_EMG_names(ii)));
    unique_EMG_idx(ii,1) = unique_idx(1);
    unique_EMG_idx(ii,2) = unique_idx(2);
end

%% Raw Signal Amplification (Differential Mode)

disp('Amplifying the raw EMG:')

raw_rhd_EMG = zeros(length(t_amplifier),length(unique_EMG_names));
for ii = 1:length(unique_EMG_names)
    raw_rhd_EMG(:,ii) = amplifier_data(unique_EMG_idx(ii,1),:) - amplifier_data(unique_EMG_idx(ii,2),:);
end

%% Determine the synchronization lines

disp('Determining the synchronization lines:')

sync_line1 = board_dig_in_data(1,:);
sync_line2 = board_dig_in_data(2,:);

% The start sync lines
sync1_start = find(sync_line1 == 1, 1, 'First');
sync2_start = find(sync_line2 == 1, 1, 'First');

% The end sync lines
sync1_end = find(sync_line1 == 1, 1, 'Last');
sync2_end = find(sync_line2 == 1, 1, 'Last');

% Define the start as the first sync line
sync_start = min(sync1_start, sync2_start);

% Define the end as the first sync line
sync_end = min(sync1_end, sync2_end);

%% Use the synchronized start to trim the timeframe and EMG

disp('Trimming the raw EMG & timeframe')

raw_EMG_time_frame = t_amplifier(sync_start : sync_end)';

% Round the raw EMG time frame
round_raw_EMG_time_frame = round(raw_EMG_time_frame, 3);
raw_EMG = raw_rhd_EMG(sync_start : sync_end, :);

%% Run a Notch filter to remove 60 Hz noise

disp('Running the notch filter:')

% Design the notch filer
notch_filter = designfilt('bandstopiir', 'FilterOrder', 4, ...
           'HalfPowerFrequency1', 59,'HalfPowerFrequency2', 61, ...
           'DesignMethod','butter','SampleRate', rhd_samp_rate);

% Define the filtered EMG
notched_EMG = zeros(length(raw_EMG), width(raw_EMG));

for ii = 1:width(raw_EMG)
    % Apply the Notch Filter
    notched_EMG(:,ii) = filtfilt(notch_filter, raw_EMG(:, ii));
end

%% Reject the high amplitude artifacts

disp('Rejecting high amplitude artifacts:')

% Reject EMG that surpass more than 8 standard deviations
std_limit = 8;

rejected_EMG = notched_EMG;

mean_raw_EMG = zeros(width(notched_EMG),1);
std_raw_EMG = zeros(width(notched_EMG),1);
for ii = 1:width(notched_EMG)
    std_raw_EMG(ii,1) = std(notched_EMG(:,ii));
    mean_raw_EMG(ii,1) = mean(notched_EMG(:,ii));
    high_raw_amps = abs(notched_EMG(:,ii)) > std_limit*std_raw_EMG(ii,1);
    num_reject = length(find(high_raw_amps == 1));
    fprintf("%0.1f Samples Rejected \n", round(num_reject));
    rejected_EMG(high_raw_amps,ii) = (mean_raw_EMG(ii,1) - std_raw_EMG(ii,1)) + ... 
        (mean_raw_EMG(ii,1) + std_raw_EMG(ii,1)) .* rand(1,1);
end

%% High pass filter, rectify, and low pass filter the EMG

% Construct filter off 1/2 the sampling frequency (to prevent aliasing)
nyquist_num = 2;

disp('Running high pass filter:')

% High pass 4th order Butterworth band pass filter (50 Hz)
[b_high, a_high] = butter(4, nyquist_num*50/rhd_samp_rate, 'high');
highpassed_EMG = filtfilt(b_high, a_high, rejected_EMG);

disp('Rectifying EMG:')

% Full wave rectification
rect_EMG = abs(highpassed_EMG);

disp('Running low pass filter:')

% Low pass 4th order Butterworth band pass filter (10 Hz)
[b_low, a_low] = butter(4, nyquist_num*10/rhd_samp_rate, 'low');
lowpassed_EMG = filtfilt(b_low, a_low, rect_EMG);

%% Bin the EMG

% Calculate the mean and std of the lowpassed EMG (in case of dropout)
mean_lowpassed_EMG = zeros(length(unique_EMG_names),1);
std_lowpassed_EMG = zeros(length(unique_EMG_names),1);
for ii = 1:length(unique_EMG_names)
    mean_lowpassed_EMG(ii) = mean(lowpassed_EMG(:,ii));
    std_lowpassed_EMG(ii) = std(lowpassed_EMG(:,ii));
end

disp('Binning the EMG:')

EMG = zeros(height(xds.time_frame),length(unique_EMG_names));
for ii = 1:length(xds.time_frame)
    raw_idx = find(round_raw_EMG_time_frame == xds.time_frame(ii));
    if isempty(raw_idx) % In case of dropout
        for jj = 1:length(unique_EMG_names)
            EMG(ii,jj) = (mean_lowpassed_EMG(jj,1) - std_lowpassed_EMG(jj,1)) + ...
                (mean_lowpassed_EMG(jj,1) + std_lowpassed_EMG(jj,1)) .* rand(1,1);
        end
        continue
    end
    for jj = 1:length(unique_EMG_names)
        EMG(ii,jj) = mean(lowpassed_EMG(raw_idx(1:end),jj));
    end
end

%% Put the new EMG in xds

disp('Adding EMG To XDS:')

xds.EMG_names = cellstr(strcat('EMG_', unique_EMG_names'));
xds.raw_EMG_time_frame = raw_EMG_time_frame;
xds.raw_EMG = raw_EMG;
xds.EMG = EMG;
xds.has_EMG = true;
xds.meta.hasEmg = true;



