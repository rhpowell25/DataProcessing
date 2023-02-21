clc
clear

Monkey_Hand = 'Left';
TgtHold = 0.5;

params = struct( ...
    'monkey_name', 'Pop', ...
    'array_name', 'M1', ...
    'task_name', 'multi_gadget', ... % WS, multi_gadget, FR, WB, etc.
    'ran_by', 'HP', ...
    'lab', 1, ...
    'bin_width', 0.001,...
    'sorted', 1,...
    'requires_raw_emg', 1,...
    'save_waveforms', 1);

file_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20210902\New folder\';
map_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20210902\';
map_name = 'SN 6250-002339';
save_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20210902\New folder\'; 
open_file = strcat(file_dir, '*.nev');
file = dir(open_file);

for ii = 1:length(file)
    file_name = file(ii).name(1:end-4);
    disp(file_name);
    xds = raw_to_xds(file_dir, file_name, map_dir, map_name, params);
    [xds] = CalculateNonLinearEnergy(xds);
    xds.meta.hand = Monkey_Hand;
    xds.meta.TgtHold = TgtHold;
    save_file = strcat(file_name, '.mat');
    save(strcat(save_dir, save_file), 'xds', '-v7.3');
    clear xds
end