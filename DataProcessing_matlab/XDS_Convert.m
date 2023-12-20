clc
clear

Monkey_Hand = 'Left';
TgtHold = 0.5;

params = struct( ...
    'monkey_name', 'Mojito', ...
    'array_name', 'M1', ...
    'task_name', 'multi_gadget', ... % WS, multi_gadget, FR, WB, etc.
    'ran_by', 'HP', ...
    'lab', 6, ...
    'bin_width', 0.001, ...
    'sorted', 1, ...
    'requires_raw_emg', 0, ...
    'save_waveforms', 1);

file_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Mojito\20230902\';
map_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Mojito\';
map_name = 'SN 6250-002658 1780-16';
save_dir = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Mojito\20230902\';
open_file = strcat(file_dir, '*.ccf');
file = dir(open_file);

for ii = 1:length(file)
    file_name = file(ii).name(1:end-4);
    disp(file_name);
    xds = raw_to_xds(file_dir, file_name, map_dir, map_name, params);
    xds.meta.hand = Monkey_Hand;
    xds.meta.TgtHold = TgtHold;
    if params.sorted == 1
        [xds] = CalculateNonLinearEnergy(xds);
        file_name = strcat(file_name, '-s');
        xds.meta.rawFileName = file_name;
    else
        [xds] = Add_TgtDistance(xds);
        %[xds] = RHD_2_XDS(xds);
    end
    save(strcat(save_dir, file_name, '.mat'), 'xds', '-v7.3');
    clear xds
end



