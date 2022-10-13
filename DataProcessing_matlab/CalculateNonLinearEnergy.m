%% Set the path for the files
clear
clc

% Define the file path
XDS_Path = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20220309\Unsorted\';

% Identify all the .mat files in the sorted path
XDS_File_Path = strcat(XDS_Path, '*.mat');
XDS_Files = dir(XDS_File_Path);

for xx = 1:length(XDS_Files)

    % Load the xds file
    File_Name = XDS_Files(xx).name;
    disp(File_Name);
    load(strcat(XDS_Path, File_Name));

    %% Some variable extraction & definitions

    disp('Extracting the waveforms:')

    % Extracting the spike waveforms of the designated unit
    spike_waveforms = xds.spike_waveforms;

    %% Calculate the nonlinear energy
    
    disp('Calculating waveform nonlinear energy:')

    nonlin_waveforms = struct([]);

    for kk = 1:length(xds.unit_names)
        for jj = 1:height(spike_waveforms{kk})
            for ii = 1:width(spike_waveforms{kk}) - 2
                nonlin_waveforms{1,kk}(jj,ii) = spike_waveforms{kk}(jj,ii+1)^2 - ... 
                    spike_waveforms{kk}(jj,ii)*spike_waveforms{kk}(jj,ii+2);
            end
        end
    end

    %% Save the file

    disp('Adding nonlinear energy To XDS:')

    % Add the nonlinear waveforms to XDS
    xds.nonlin_waveforms = nonlin_waveforms;

    disp('Saving:')

    xds.meta.rawFileName = File_Name;
    save(strcat(XDS_Path, File_Name), 'xds', '-v7.3');

    clear xds

end





