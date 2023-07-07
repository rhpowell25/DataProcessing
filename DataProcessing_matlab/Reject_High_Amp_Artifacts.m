
%% Loading selected NEV file
clear
clc

Monkey = 'Tot';
Date = '20230310';

base_dir = strcat('C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\', Monkey, '\', Date, '\');

NEV = openNEV(strcat(base_dir, '20230310_Tot_PG_Pre_Lex_01.nev'), 'nosave');

%% Finding the largest amplitude threshold crossings

% Run through the units and find the maximum threshold
max_thresholds = zeros(128,1);
for ii = 1:length(max_thresholds)
    unit_name = string(NEV.ElectrodesInfo(ii).ElectrodeLabel');

    waveform_idx = NEV.Data.Spikes.TimeStamp;


    unit_name = erase(unit_name, ' ');
    elec_label = blanks(length(unit_name))';
    for jj = 1:length(unit_name)
        elec_label(jj) = unit_name(jj);
    end
    for jj = 1:96
        NEV_unit_idx = contains(string(NEV.ElectrodesInfo(jj).ElectrodeLabel'), elec_label');
        if isequal(NEV_unit_idx, 1)
            thresh_idx = jj;
        end
    end
    morn_thresh = NEV.ElectrodesInfo(thresh_idx).LowThreshold;
    noon_thresh = NEV_noon.ElectrodesInfo(thresh_idx).LowThreshold;
    max_thresholds(ii,1) = min(morn_thresh, noon_thresh);
end

%% Find the waveforms that didnt cross the new threshold
% Morning
morn_excluded_threshold_crossings = struct([]);
for ii = 1:length(xds_morn.unit_names)
    for jj = 1:length(xds_morn.spike_waveforms{ii})
        threshold_crossings = find(xds_morn.spike_waveforms{ii}(jj,:) <= max_thresholds(ii));
        if isempty(threshold_crossings)
            morn_excluded_threshold_crossings{ii,1}(jj,1) = 1;
        end
    end
end

% Afternoon
noon_excluded_threshold_crossings = struct([]);
for ii = 1:length(xds_noon.unit_names)
    for jj = 1:length(xds_noon.spike_waveforms{ii})
        threshold_crossings = find(xds_noon.spike_waveforms{ii}(jj,:) <= max_thresholds(ii));
        if isempty(threshold_crossings)
            noon_excluded_threshold_crossings{ii,1}(jj,1) = 1;
        end
    end
end

%% Remove those waveforms from XDS
% Morning
for ii = 1:length(morn_excluded_threshold_crossings)
    morn_excl_spike_times = xds_morn.spikes{1,ii}(morn_excluded_threshold_crossings{ii} == 1);
    morn_excl_spike_time_idx = zeros(length(morn_excl_spike_times),1);
    for jj = 1:length(morn_excl_spike_times)
        morn_excl_spike_time_idx(jj) = find(xds_morn.time_frame == round(morn_excl_spike_times(jj),3));
    end
    xds_morn.spike_counts(morn_excl_spike_time_idx,ii) = 0;
    morn_spike_idx = find(morn_excluded_threshold_crossings{ii} == 1);
    xds_morn.spikes{ii}(morn_spike_idx) = [];
    xds_morn.spike_waveforms{ii}(morn_spike_idx,:) = [];
    xds_morn.nonlin_waveforms{ii}(morn_spike_idx,:) = [];
end

% Afternoon
for ii = 1:length(noon_excluded_threshold_crossings)
    noon_excl_spike_times = xds_noon.spikes{1,ii}(noon_excluded_threshold_crossings{ii} == 1);
    noon_excl_spike_time_idx = zeros(length(noon_excl_spike_times),1);
    for jj = 1:length(noon_excl_spike_times)
        noon_excl_spike_time_idx(jj) = find(xds_noon.time_frame == round(noon_excl_spike_times(jj),3));
    end
    xds_noon.spike_counts(noon_excl_spike_time_idx,ii) = 0;
    noon_spike_idx = find(noon_excluded_threshold_crossings{ii} == 1);
    xds_noon.spikes{ii}(noon_spike_idx) = [];
    xds_noon.spike_waveforms{ii}(noon_spike_idx,:) = [];
    xds_noon.nonlin_waveforms{ii}(noon_spike_idx,:) = [];
end

%% Save the file
%save('xds', 'xds', '-v7.3');





