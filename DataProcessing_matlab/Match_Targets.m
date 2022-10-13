function [Matching_Idxs_Morn, Matching_Idxs_Noon] = ...
    Match_Targets(target_dirs_morn, target_dirs_noon, target_centers_morn, target_centers_noon)

%% Find the matching morning indices
Matching_Idxs_Morn = false(length(target_dirs_morn),1);
for ii = 1:length(target_dirs_morn)
    for jj = 1:length(target_dirs_noon)
        if target_dirs_morn(ii) == target_dirs_noon(jj) && target_centers_morn(ii) == target_centers_noon(jj)
            Matching_Idxs_Morn(ii) = true;
        end
    end
end

%% Find the matching afternoon indices
Matching_Idxs_Noon = false(length(target_dirs_noon),1);
for ii = 1:length(target_dirs_noon)
    for jj = 1:length(target_dirs_morn)
        if target_dirs_noon(ii) == target_dirs_morn(jj) && target_centers_noon(ii) == target_centers_morn(jj)
            Matching_Idxs_Noon(ii) = true;
        end
    end
end
