
function [xds] = CalculateNonLinearEnergy(xds)

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
    







