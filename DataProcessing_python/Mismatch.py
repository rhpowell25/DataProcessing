# -*- coding: utf-8 -*-

from Remove_Unit import Remove_Unit

def Mismatch(xds_morn, xds_noon):
    
    #%% Check if there is a mismatch in the morning & afternoon units
    
    # If the units are the same
    if xds_morn.unit_names == xds_noon.unit_names:
        print('All Good!')
        return xds_morn, xds_noon
    
    # if the units are different
    if xds_morn.unit_names != xds_noon.unit_names:
        print('You Have A Mismatch In Units!')
        
        # If the extra unit is in the morning
        morn_extra_unit = [ii for ii in xds_morn.unit_names if ii not in set(xds_noon.unit_names)]
        if morn_extra_unit:
            print('Extra units in the morning:')
            print(morn_extra_unit)
        
        # If the extra unit is in the afternoon
        noon_extra_unit = [ii for ii in xds_noon.unit_names if ii not in set(xds_morn.unit_names)]
        if noon_extra_unit:
            print('Extra units in the afternoon:')
            print(noon_extra_unit)
            
    #%% Remove those extra units & their spike data
    
    if morn_extra_unit:
        for ii in range(len(morn_extra_unit)):
            unit_name = morn_extra_unit[ii]
            xds_morn = Remove_Unit(xds_morn, unit_name)
            
    if noon_extra_unit:
        for ii in range(len(noon_extra_unit)):
            unit_name = noon_extra_unit[ii]
            xds_noon = Remove_Unit(xds_noon, unit_name)

    #%% Confirm the morning & afternoon files are now identical
    if xds_morn.unit_names == xds_noon.unit_names:
        print('Units Are Identical Now')
        
    if xds_morn.unit_names != xds_noon.unit_names:
        print('Morning & Noon Units Still Wrong')
    
    #%% Return the xds file
    
    return xds_morn, xds_noon



















        
        
        