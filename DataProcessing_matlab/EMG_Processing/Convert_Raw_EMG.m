function Convert_Raw_EMG

%% Set the path for the files
clear
clc

% Define the file path
XDS_Path = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20210617\';

% Identify all the .mat files in the sorted path
XDS_File_Path = strcat(XDS_Path, '*.mat');
XDS_Files = dir(XDS_File_Path);

Save_XDS = 1;

for xx = 1:length(XDS_Files)

    % Load the xds file
    File_Name = XDS_Files(xx).name;
    disp(File_Name);
    load(strcat(XDS_Path, File_Name), 'xds');

    % Make sure the meta file name and file name match
    if ~isequal(xds.meta.rawFileName, erase(File_Name, '.mat'))
        disp('File names are mismatched')
        return
    end

    %% Extract the raw EMG timeframe and raw EMG

    raw_EMG_timeframe = xds.raw_EMG_time_frame;
    raw_EMG = xds.raw_EMG;
    for ii = 1:width(raw_EMG)
        raw_EMG(:,ii) = xds.raw_EMG(:,ii);
    end

    % Define the sampling frequency (Hz)
    samp_rate = 1 / (raw_EMG_timeframe(end) / length(raw_EMG_timeframe));

    %% Run a Notch filter to remove 60 Hz noise

    disp('Running the notch filter:')

    % Design the notch filer
    notch_filter = designfilt('bandstopiir','FilterOrder',4, ...
        'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
        'DesignMethod','butter','SampleRate',samp_rate);

    % Define the filtered EMG
    notched_EMG = zeros(length(xds.raw_EMG), width(raw_EMG));

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
        rejected_EMG(high_raw_amps,ii) = (mean_raw_EMG(ii,1) - std_raw_EMG(ii,1)) + ... 
            (mean_raw_EMG(ii,1) + std_raw_EMG(ii,1)) .* rand(1,1);
    end

    %% High pass filter, rectify, and low pass filter the EMG

    % Construct filter off 1/2 the sampling frequency (to prevent aliasing)
    nyquist_num = 2;

    disp('Running high pass filter:')

    % High pass 4th order Butterworth band pass filter (50 Hz)
    [b_high, a_high] = butter(4, nyquist_num*50/samp_rate, 'high');
    highpassed_EMG = filtfilt(b_high, a_high, rejected_EMG);

    disp('Rectifying EMG:')

    % Full wave rectification
    rect_EMG = abs(highpassed_EMG);

    disp('Running low pass filter:')

    % Low pass 4th order Butterworth band pass filter (10 Hz)
    [b_low, a_low] = butter(4, nyquist_num*10/samp_rate, 'low');
    lowpassed_EMG = filtfilt(b_low, a_low, rect_EMG);

    %% Bin the EMG

    disp('Binning the EMG:')

    % Find the factor to downsample to
    down_samp_rate = round(length(raw_EMG_timeframe) / length(xds.time_frame));

    EMG = zeros(length(xds.time_frame), width(lowpassed_EMG));
    for ii = 1:width(lowpassed_EMG)
        EMG(:,ii) = decimate(lowpassed_EMG(:,ii), down_samp_rate);
    end

    %% Add the EMG to the file and save

    disp('Adding EMG To XDS:')
    xds.EMG = EMG;

    if isequal(Save_XDS, 1)

        disp('Saving:')
 
        xds.meta.TgtHold = 0.5;
        save_file = strcat(xds.meta.rawFileName, '.mat');
        save(strcat(XDS_Path, save_file), 'xds', '-v7.3');

    end

    disp('Done')

end

%% Things to Google
% Cone Filter



