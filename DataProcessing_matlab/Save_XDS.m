function Save_XDS(xds)

%% Find the save directory

file_name = xds.meta.rawFileName;
xtra_info = extractAfter(file_name, '_');

% Date
Date = erase(file_name, strcat('_', xtra_info));

% Monkey
Monkey = xds.meta.monkey;

save_dir = strcat('C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\', Monkey, '\', Date, '\');

% Save the file
sprintf('Saving: %s', file_name);
save(strcat(save_dir, file_name), 'xds', '-v7.3');
disp('*******Done*********');