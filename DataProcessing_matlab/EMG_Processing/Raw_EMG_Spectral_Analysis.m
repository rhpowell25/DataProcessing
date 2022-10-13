function Raw_EMG_Spectral_Analysis(xds, muscle_groups)

%% Basic Settings, some variable extractions, & definitions

% Font specifications
title_font_size = 15;
label_font_size = 15;

%% Find the EMG index

[M] = EMG_Index(xds, muscle_groups);

%% Pull the timeframe, names, & raw EMG of the selected muscles

raw_EMG_timeframe = xds.raw_EMG_time_frame;
EMG_names = xds.EMG_names(M);
raw_EMG = xds.raw_EMG(:,M);
for ii = 1:width(raw_EMG)
    raw_EMG(:,ii) = xds.raw_EMG(:,M(ii));
end

% Define the sampling frequency (Hz)
samp_freq = 1 / (raw_EMG_timeframe(end) / length(raw_EMG_timeframe));
% Define the number of samples
num_samp = length(raw_EMG_timeframe);
% Define the frequency bins
freq_bins = ((0: 1/num_samp: 1 - 1/num_samp)*samp_freq);

%% Calculate the fast fourier transformation of the raw EMG

raw_EMG_fast_fourier = zeros(length(raw_EMG), width(raw_EMG));
fast_fourier_magnitude = zeros(length(raw_EMG), width(raw_EMG));
for ii = 1:width(raw_EMG)
    raw_EMG_fast_fourier(:, ii) = fft(raw_EMG(:, ii));
    fast_fourier_magnitude(:,  ii) = abs(raw_EMG_fast_fourier(:, 1));
end

%% Calculate the Welch Power Spectral Density of the raw EMG
[raw_EMG_welch_PSD, welch_freq] = pwelch(raw_EMG, [], [], [], samp_freq);

%% Plot the raw EMG, FFT magnitude response, and welch filter

for ii = 1:width(raw_EMG)
    % Raw EMG
    figure
    hold on
    title(sprintf('Raw EMG: %s', strrep(string(EMG_names(ii)),'EMG_',' ')), 'FontSize', title_font_size)
    xlabel('Time (sec)', 'FontSize', label_font_size);
    ylabel('Amplitude', 'FontSize', label_font_size);
    plot(raw_EMG_timeframe, raw_EMG(:, ii), 'Color', 'k')
    x_max = max(raw_EMG_timeframe);
    x_min = min(raw_EMG_timeframe);
    xlim([x_min x_max]);

    % FFT Magnitude
    figure
    hold on
    title(sprintf('FFT Magnitude: %s', strrep(string(EMG_names(ii)),'EMG_',' ')), 'FontSize', title_font_size)
    xlabel('Frequency (Hz)', 'FontSize', label_font_size);
    ylabel('Magnitude', 'FontSize', label_font_size);
    plot(freq_bins, fast_fourier_magnitude(:, ii), 'Color', 'k')
    x_max = max(freq_bins);
    x_min = min(freq_bins);
    xlim([x_min x_max]);

    % Welch Power Spectral Density
    figure
    hold on
    title(sprintf('Welch PSD: %s', strrep(string(EMG_names(ii)),'EMG_',' ')), 'FontSize', title_font_size)
    xlabel('Frequency (Hz)', 'FontSize', label_font_size);
    ylabel('Power / Frequency (dB/Hz)', 'FontSize', label_font_size);
    plot(welch_freq, 10*log10(raw_EMG_welch_PSD(:,ii)), 'Color', 'k')
    x_max = max(welch_freq);
    x_min = min(welch_freq);
    xlim([x_min x_max]);

    % Log Scale Welch Power Spectral Density
    figure
    hold on
    title(sprintf('Log Scale Welch PSD: %s', strrep(string(EMG_names(ii)),'EMG_',' ')), 'FontSize', title_font_size)
    xlabel('Frequency (Hz)', 'FontSize', label_font_size);
    ylabel('Power / Frequency (dB/Hz)', 'FontSize', label_font_size);
    plot(welch_freq, 10*log10(raw_EMG_welch_PSD(:,ii)), 'Color', 'k')
    figure_axes = gca;
    figure_axes.XScale = 'log';

end





