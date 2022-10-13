function [xds_morn, xds_noon] = Mismatch(xds_morn, xds_noon, Save_XDS)

%% Check if there is a mismatch in the morning and afternoon units
% If the units are the same
if isequal(xds_morn.unit_names, xds_noon.unit_names)
    disp('All Good!');
    return
end

% If the units are different
if ~isequal(xds_morn.unit_names, xds_noon.unit_names)
    disp('You Have A Mismatch In Units');

    % If the extra unit is in the morning
    morn_extra_unit = setdiff(xds_morn.unit_names, xds_noon.unit_names);
    if ~isempty(morn_extra_unit)
        disp('Extra units in the morning:')
        disp(morn_extra_unit);
    end

    % If the extra unit is in the morning
    noon_extra_unit = setdiff(xds_noon.unit_names, xds_morn.unit_names);
    if ~isempty(noon_extra_unit)
        disp('Extra units in the afternoon:')
        disp(noon_extra_unit);
    end

end

%% Remove those extra units and their spike data
if ~isempty(morn_extra_unit)
    for ii = 1:length(morn_extra_unit)
        delete_unit_idx = find(strcmp(xds_morn.unit_names, morn_extra_unit(ii)));
        xds_morn.unit_names(delete_unit_idx) = [];
        xds_morn.spikes(delete_unit_idx) = [];
        xds_morn.spike_waveforms(delete_unit_idx) = [];
        xds_morn.spike_counts(:,delete_unit_idx) = [];
        if isfield(xds_morn, 'nonlin_waveforms')
            xds_morn.nonlin_waveforms(delete_unit_idx) = [];
        end
    end
end

if ~isempty(noon_extra_unit)
    for ii = 1:length(noon_extra_unit)
        delete_unit_idx = find(strcmp(xds_noon.unit_names, noon_extra_unit(ii)));
        xds_noon.unit_names(delete_unit_idx) = [];
        xds_noon.spikes(delete_unit_idx) = [];
        xds_noon.spike_waveforms(delete_unit_idx) = [];
        xds_noon.spike_counts(:,delete_unit_idx) = [];
        if isfield(xds_noon, 'nonlin_waveforms')
            xds_noon.nonlin_waveforms(delete_unit_idx) = [];
        end
    end
end

%% Confirm morning and afternoon files are now identical

if isequal(xds_morn.unit_names, xds_noon.unit_names)
    disp('Units Are Identical Now');
end

if ~isequal(xds_morn.unit_names, xds_noon.unit_names)
    disp('Morning & Noon Units Still Wrong');
end

if isequal(Save_XDS, 1)

    % Date
    file_name = xds_morn.meta.rawFileName;
    xtra_info = extractAfter(file_name, '_');
    Date = erase(file_name, strcat('_', xtra_info)); 
    
    % Monkey
    Monkey = xds_morn.meta.monkey;

    save_dir = strcat('C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\', Monkey, '\', Date, '\');

    disp('Saving XDS:')

    % Morning File
    xds = xds_morn;
    save_file = strcat(xds.meta.rawFileName, '.mat');
    save(strcat(save_dir, save_file), 'xds', '-v7.3');
    clear xds

    % Afternoon File
    xds = xds_noon;
    save_file = strcat(xds.meta.rawFileName, '.mat');
    save(strcat(save_dir, save_file), 'xds', '-v7.3');
    clear xds

end




