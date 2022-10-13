%% Load the file
clear
clc

% Select the date & task to analyze (YYYYMMDD)
Date = '20210610';
Task = 'WS';
% Do you want to process the XDS file? (1 = yes; 0 = no)
Process_XDS = 1;

[xds_sorted, ~, ~] = Load_XDS(Date, Task, Process_XDS);

load('C:\Users\rhpow\Documents\Work\Northwestern\Pop\20210610\XDS\Unsorted\Pop_20210610_Pre_Caffeine_WS001.mat')
xds_unsorted = xds;
clear xds

%% Variable definitions & extraction

%Select the unit of interest
sorted_unit_name = 'elec86_1';
unsorted_unit_name = 'elec86';

% Find the index of the unit
sorted_N = find(strcmp(xds_sorted.unit_names, sorted_unit_name));
unsorted_N = find(strcmp(xds_unsorted.unit_names, unsorted_unit_name));

% Select EMG of interest
muscle_name = 'EMG_FCR1';
sorted_M = find(strcmp(xds_sorted.EMG_names, muscle_name));
unsorted_M = find(strcmp(xds_unsorted.EMG_names, muscle_name));

% Bin size
bin_size = 0.001;

% Pulling variables from the sorted file
sorted_waves = xds_sorted.spike_waveforms{sorted_N};
sorted_time_frame = xds_sorted.time_frame;
sorted_spikes = xds_sorted.spikes{1,sorted_N};
sorted_spike_counts = xds_sorted.spike_counts(:,sorted_N);
sorted_EMG = xds_sorted.EMG(:,sorted_M);

unsorted_waves = xds_unsorted.spike_waveforms{unsorted_N};
unsorted_time_frame = xds_unsorted.time_frame;
unsorted_spikes = xds_unsorted.spikes{1,unsorted_N};
unsorted_spike_counts = xds_unsorted.spike_counts(:,unsorted_N);
unsorted_EMG = xds_unsorted.EMG(:,unsorted_M);

% Number of bins
n_bins = round((t_end - t_start)/bin_size);

% Define the time period in question
t_start = 0;
t_end = 10;
sorted_start_time = sorted_time_frame(1:20000);
unsorted_start_time = unsorted_time_frame(1:20000);
sorted_end_time = sorted_time_frame((length(sorted_time_frame)-19999):length(sorted_time_frame));
unsorted_end_time = unsorted_time_frame((length(unsorted_time_frame)-19999):length(unsorted_time_frame));

%% Firing rate during period in question

% Number of spikes during that period
sorted_firing_rate = length(find((sorted_spikes > t_start & ...
    sorted_spikes < t_end)));
unsorted_firing_rate = length(find((unsorted_spikes > t_start & ...
    unsorted_spikes < t_end)));

% Calculate the average firing rate
avg_sorted_firing_rate = sorted_firing_rate / (t_end-t_start);
avg_unsorted_firing_rate = unsorted_firing_rate / (t_end-t_start);

%Print the average firing rate
fprintf("The average sorted firing rate of %s is %.1f Hz \n", ...
    string(xds_sorted.unit_names{sorted_N}), avg_sorted_firing_rate);

fprintf("The average unsorted firing rate of %s is %.1f Hz \n", ...
    string(xds_unsorted.unit_names{unsorted_N}), avg_unsorted_firing_rate);


%% Extracting EMG and time during period in question

sorted_EMG_idx = find((sorted_time_frame >= t_start) & (sorted_time_frame <= t_end));
unsorted_EMG_idx = find((unsorted_time_frame >= t_start) & (unsorted_time_frame <= t_end));

figure
plot(unsorted_start_time,unsorted_EMG(1:20000));
figure
plot(sorted_start_time,sorted_EMG(1:20000));

figure
plot(unsorted_end_time,unsorted_EMG((length(unsorted_EMG)-19999):length(unsorted_EMG)));
figure
plot(sorted_end_time,sorted_EMG((length(sorted_EMG)-19999):length(sorted_EMG)));





