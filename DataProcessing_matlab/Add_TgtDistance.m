function [xds] = Add_TgtDistance(xds)

%% Add the target center header

% Remove the extraneous header labels
if length(xds.trial_info_table_header) ~= width(xds.trial_info_table)
    Variables_idx = contains(xds.trial_info_table_header, 'Variables');
    xds.trial_info_table_header(Variables_idx) = [];
    Row_idx = contains(xds.trial_info_table_header, 'Row');
    xds.trial_info_table_header(Row_idx) = [];
    Properties_idx = contains(xds.trial_info_table_header, 'Properties');
    xds.trial_info_table_header(Properties_idx) = [];
end
% Find the number of targets in that particular direction
tgt_Center_idx = contains(xds.trial_info_table_header, 'tgtCenter');
if ~any(tgt_Center_idx)
    tgt_Center_idx = contains(xds.trial_info_table_header, 'tgtCtr');
    xds.trial_info_table_header{tgt_Center_idx} = 'tgtCenter';
end
% Add an extra header for the polar coordinate target centers
if ~any(strcmp(xds.trial_info_table_header, 'TgtDistance'))
    Dist_idx = length(xds.trial_info_table_header) + 1;
    xds.trial_info_table_header{Dist_idx} = 'TgtDistance';
else
    Dist_idx = find(strcmp(xds.trial_info_table_header, 'TgtDistance'));
end

% Add the polar coordinates to the xds trial info table
xds.trial_info_table(:, Dist_idx) = {[]};
for pp = 1:height(xds.trial_info_table)
    tgt_cntrs = xds.trial_info_table{pp, tgt_Center_idx};
    xds.trial_info_table{pp, Dist_idx} = round(sqrt((tgt_cntrs(1,1))^2 + (tgt_cntrs(1,2))^2), 1);
end















