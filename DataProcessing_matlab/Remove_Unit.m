function [xds] = Remove_Unit(xds, unit_name)

%% Remove a bad unit from a file
unit_idx = find(strcmp(xds.unit_names, unit_name));
xds.unit_names(unit_idx) = [];
xds.spikes(unit_idx) = [];
xds.spike_waveforms(unit_idx) = [];
xds.spike_counts(:,unit_idx) = [];
xds.nonlin_waveforms(unit_idx) = [];
