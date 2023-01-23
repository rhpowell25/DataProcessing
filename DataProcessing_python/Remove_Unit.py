# -*- coding: utf-8 -*-

import numpy as np   

#%% Remove a bad unit from a file
def Remove_Unit(xds, unit_name):
       
    unit_idx = xds.unit_names.index(unit_name)
    del(xds.unit_names[unit_idx])
    del(xds.spikes[unit_idx])
    del(xds.spike_waveforms[unit_idx])
    xds.spike_counts = np.delete(xds.spike_counts, unit_idx, 1)
    del(xds.nonlin_waveforms[unit_idx])

    #%% Return the xds file
    return xds



















        
        
        