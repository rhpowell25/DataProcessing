# -*- coding: utf-8 -*-
import numpy as np

class Identify_Targets():    
    
    def __init__(self, xds):
        
        #%% Display the function
        print('Identifying all target directions & target centers:')
        
        #%% Extract the trial directions
        target_dir_idx = xds.trial_target_dir
        unique_target_dirs = np.unique(target_dir_idx)
        
        # Counts the number of directions used
        num_dirs = len(unique_target_dirs)
        
        # Pull the target centers of each succesful trial
        tgt_Center_header = xds.trial_info_table_header.index('TgtDistance')
        tgt_Center_idx = []
        for ii in range(len(xds.trial_info_table[tgt_Center_header][:])):
            tgt_Center_idx.append(xds.trial_info_table[tgt_Center_header][ii][0][0])
        unique_targets = np.unique(tgt_Center_idx)
        
        # Counts the number of targets used
        num_tgts = len(unique_targets)
        
        # Set the loop counter
        cc = 0;   
        
        #%% Begin the loop through all directions
        for jj in range(num_dirs):
        
           #%% Indexes for all rewarded trials
           total_rewarded_idx = np.argwhere(np.logical_and(xds.trial_result == 'R', \
                                                    xds.trial_target_dir == unique_target_dirs[jj])).reshape(-1,)
           rewarded_tgts = []
           for ii in range(len(total_rewarded_idx)):
               rewarded_tgts.append(tgt_Center_idx[total_rewarded_idx[ii]])
               
           #%% Find the number of targets in that particular direction
           
           # Define the output variables
           if jj == 0:
               self.target_centers = np.zeros(num_dirs*num_tgts)
               self.target_dirs = np.zeros(num_dirs*num_tgts)
               
           #%% Loop through the target centers
           for kk in range(num_tgts):

               rewarded_idx = total_rewarded_idx[np.where(rewarded_tgts == unique_targets[kk])]
               
               #%% Skip the function if less than 5 succesful trials in that direction
               
               if len(rewarded_idx) < 5:
                   self.target_dirs = np.delete(self.target_dirs, cc,  0)
                   self.target_centers = np.delete(self.target_centers, cc,  0)
                   continue
               
               # Defining the output variables
               self.target_centers[cc] = round(unique_targets[kk], 2)
               self.target_dirs[cc] = unique_target_dirs[jj]
                   
               # Adding to the loop counter
               cc = cc + 1
               























