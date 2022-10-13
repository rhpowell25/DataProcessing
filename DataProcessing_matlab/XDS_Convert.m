clc
clear
params = struct( ...
    'monkey_name', 'Pop', ...s
    'array_name', 'M1', ...
    'task_name', 'FR', ... % WS /multi_gadget / FR / WB
    'ran_by', 'EG', ...
    'lab', 1, ...
    'bin_width', 0.033,...
    'sorted', 1,...
    'requires_raw_emg', 1,...
    'save_waveforms', 1);

file_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20220309\Trimmed\';
map_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\';
map_name = 'SN 6250-002339';
save_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20220309\Trimmed\'; 
open_file = strcat(file_dir, '*.nev');
file = dir(open_file);

for ii = 1:length(file)
    file_name = file(ii).name(1:end-4);
    disp(file_name);
    xds = raw_to_xds(file_dir, file_name, map_dir, map_name, params);
    save_file = strcat(file_name, '.mat');
    save(strcat(save_dir, save_file), 'xds', '-v7.3');
    clear xds
end