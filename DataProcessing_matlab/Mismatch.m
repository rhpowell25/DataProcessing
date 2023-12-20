function [xds_one, xds_two] = Mismatch(xds_one, xds_two, Save_XDS)

%% If the units already match
if isequal(xds_one.unit_names, xds_two.unit_names)
    disp('All Good!');
    return
end

%% Confirm that there are no repeats in unit names

[~, one_unique_names] = unique(xds_one.unit_names, 'stable');
one_duplicate_indices = setdiff(1:numel(xds_one.unit_names), one_unique_names);
% Append the duplicate units with '_2'
for ii = 1:length(one_duplicate_indices)
    xds_one.unit_names{one_duplicate_indices(ii)} = ...
        strcat(xds_one.unit_names{one_duplicate_indices(ii)}, '_2');
end

[~, two_unique_names] = unique(xds_two.unit_names, 'stable');
two_duplicate_indices = setdiff(1:numel(xds_two.unit_names), two_unique_names);
% Append the duplicate units with '_2'
for ii = 1:length(two_duplicate_indices)
    xds_two.unit_names{two_duplicate_indices(ii)} = ...
        strcat(xds_two.unit_names{two_duplicate_indices(ii)}, '_2');
end

%% Check if there is a mismatch in the two files

% If the units are different
if ~isequal(xds_one.unit_names, xds_two.unit_names)
    disp('You Have A Mismatch In Units');

    % If the extra unit(s) are in the first file
    one_extra_units = setdiff(xds_one.unit_names, xds_two.unit_names);
    if ~isempty(one_extra_units)
        disp('Extra units in the first file:')
        disp(one_extra_units);
    end

    % If the extra unit(s) are in the second file
    two_extra_units = setdiff(xds_two.unit_names, xds_one.unit_names);
    if ~isempty(two_extra_units)
        disp('Extra units in the second file:')
        disp(two_extra_units);
    end

end

%% Remove those extra units & their spike data
% First file
if ~isempty(one_extra_units)
    for ii = 1:length(one_extra_units)
        delete_unit_idx = find(strcmp(xds_one.unit_names, one_extra_units(ii)));
        xds_one.unit_names(delete_unit_idx) = [];
        xds_one.spikes(delete_unit_idx) = [];
        xds_one.spike_waveforms(delete_unit_idx) = [];
        xds_one.spike_counts(:,delete_unit_idx) = [];
        if isfield(xds_one, 'nonlin_waveforms')
            xds_one.nonlin_waveforms(delete_unit_idx) = [];
        end
    end
end
% Second file
if ~isempty(two_extra_units)
    for ii = 1:length(two_extra_units)
        delete_unit_idx = find(strcmp(xds_two.unit_names, two_extra_units(ii)));
        xds_two.unit_names(delete_unit_idx) = [];
        xds_two.spikes(delete_unit_idx) = [];
        xds_two.spike_waveforms(delete_unit_idx) = [];
        xds_two.spike_counts(:,delete_unit_idx) = [];
        if isfield(xds_two, 'nonlin_waveforms')
            xds_two.nonlin_waveforms(delete_unit_idx) = [];
        end
    end
end

%% Check if there is a difference in order between the files
if ~isequal(xds_one.unit_names, xds_two.unit_names)
    if isequal(unique(xds_one.unit_names), unique(xds_two.unit_names))
        % First file
        [xds_one.unit_names, unit_order] = sort(xds_one.unit_names);
        xds_one.spikes = xds_one.spikes(unit_order);
        xds_one.spike_waveforms = xds_one.spike_waveforms(unit_order);
        xds_one.spike_counts = xds_one.spike_counts(:,unit_order);
        if isfield(xds_one, 'nonlin_waveforms')
            xds_one.nonlin_waveforms = xds_one.nonlin_waveforms(unit_order);
        end
        % Second File
        [xds_two.unit_names, unit_order] = sort(xds_two.unit_names);
        xds_two.spikes = xds_two.spikes(unit_order);
        xds_two.spike_waveforms = xds_two.spike_waveforms(unit_order);
        xds_two.spike_counts = xds_two.spike_counts(:,unit_order);
        if isfield(xds_two, 'nonlin_waveforms')
            xds_two.nonlin_waveforms = xds_two.nonlin_waveforms(unit_order);
        end
    end
end

%% Confirm the files are now identical

if isequal(xds_one.unit_names, xds_two.unit_names)
    disp('Units Are Identical Now');
end

if ~isequal(xds_one.unit_names, xds_two.unit_names)
    disp('Units Still Wrong');
end

if isequal(Save_XDS, 1)

    disp('Saving XDS:')

    % First file
    xds = xds_one;
    Save_XDS(xds)
    clear xds

    % Second file
    xds = xds_two;
    Save_XDS(xds)
    clear xds

end




