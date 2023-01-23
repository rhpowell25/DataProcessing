clc
clear
file_path = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pancake\20221102\';
open_file = strcat(file_path, '*.mat');
file = dir(open_file);
for ii = 1:length(file)
    file_name_in_list = file(ii).name;
    disp(file_name_in_list);
    load(strcat(file_path, file_name_in_list));
    save_name = strcat(file_name_in_list(1:end-4), '.nev');
    saveNEVSpikesLimblab(NEV, file_path, save_name);
    clear NEV
end