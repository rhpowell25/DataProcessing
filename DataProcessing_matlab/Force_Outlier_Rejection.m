function [xds_morn, xds_noon] = Force_Outlier_Rejection(xds_morn, xds_noon)

%% Display the function being used
disp('Force Outlier Rejection:');

% This script rejects any trials whose 
% force scatter exceeds the 75% error ellipse

%% Basic Settings, some variable extractions, & definitions

% The percent of points covered by the errpr ellipse
err_percent = .75;

% Define the window for the baseline phase
TgtHold_time = xds_morn.meta.TgtHold;

% Save the figures to desktop? ('pdf', 'png', 'fig', 0 = No)
Save_Figs = 0;

% Plot the before & after to confirm the script works?
Plot_Figs = 0;

% Save Counter
if ~isequal(Save_Figs, 0)
    close all
end
ss = 1;

%% Removing non-numbers in the trial target directions
% Extract the trial directions
target_dir_idx_morn = xds_morn.trial_target_dir;
target_dir_idx_noon = xds_noon.trial_target_dir;

%% Settings to loop through every target direction
% Select the first direction (Start with the minimum direction value)
target_dir_morn = unique(target_dir_idx_morn);
target_dir_noon = unique(target_dir_idx_noon);

% Counts the number of directions used
num_dir_morn = length(unique(target_dir_idx_morn));
num_dir_noon = length(unique(target_dir_idx_noon));

if ~isequal(num_dir_morn, num_dir_noon)
    disp('The number of directions changes from morning to noon!')
    return
end

%% Begin the loop through all directions
for jj = 1:num_dir_morn

    %% Index for rewarded trials
    total_rewarded_idx_morn = find((xds_morn.trial_result == 'R' & xds_morn.trial_target_dir == target_dir_morn(jj)));
    total_rewarded_idx_noon = find((xds_noon.trial_result == 'R' & xds_noon.trial_target_dir == target_dir_noon(jj)));
    
    %% Find the number of targets in that particular direction
    % Find which column holds the target centers
    tgt_Center_idx_morn = contains(xds_morn.trial_info_table_header, 'tgtCenter');
    if ~any(tgt_Center_idx_morn)
        tgt_Center_idx_morn = contains(xds_morn.trial_info_table_header, 'tgtCtr');
    end

    tgt_Center_idx_noon = contains(xds_noon.trial_info_table_header, 'tgtCenter');
    if ~any(tgt_Center_idx_noon)
        tgt_Center_idx_noon = contains(xds_noon.trial_info_table_header, 'tgtCtr');
    end
    
    % Pull the target center coordinates of each succesful trial   
    tgt_cntrs_morn = struct([]);
    for ii = 1:height(total_rewarded_idx_morn)
        tgt_cntrs_morn{ii,1} = xds_morn.trial_info_table{total_rewarded_idx_morn(ii), tgt_Center_idx_morn};
    end
    tgt_cntrs_noon = struct([]);
    for ii = 1:height(total_rewarded_idx_noon)
        tgt_cntrs_noon{ii,1} = xds_noon.trial_info_table{total_rewarded_idx_noon(ii), tgt_Center_idx_noon};
    end

    % Convert the cartesian coordinates into polar coordinates
    target_cntrs_morn = zeros(height(total_rewarded_idx_morn), 1);
    for ii = 1:height(total_rewarded_idx_morn)
        target_cntrs_morn(ii) = sqrt((tgt_cntrs_morn{ii,1}(1,1))^2 + (tgt_cntrs_morn{ii,1}(1,2))^2);
    end
    target_cntrs_noon = zeros(height(total_rewarded_idx_noon), 1);
    for ii = 1:height(total_rewarded_idx_noon)
        target_cntrs_noon(ii) = sqrt((tgt_cntrs_noon{ii,1}(1,1))^2 + (tgt_cntrs_noon{ii,1}(1,2))^2);
    end
    
    % Confirm both sessions use consistent target centers
    unique_targets_morn = unique(target_cntrs_morn);
    unique_targets_noon = unique(target_cntrs_noon);

    if ~isequal(unique_targets_morn, unique_targets_noon)
        disp('Targets are unequal between morning and noon')
        return
    end
    
    %% Define the output variables
    if jj == 1

        per_trial_avg_First_Force_morn = struct([]);
        per_trial_avg_Second_Force_morn = struct([]);
        per_trial_avg_First_Force_noon = struct([]);
        per_trial_avg_Second_Force_noon = struct([]);

        X_ellipse = struct([]);
        Y_ellipse = struct([]);

        theta_ellipse = struct([]);
        ellipse_distance = struct([]);

        theta_force = struct([]);
        theta_idx = struct([]);
        force_distance = struct([]);

        outlier_idx = struct([]);
        outlier_idx_morn = struct([]);
        outlier_idx_noon = struct([]);

        Best_First_Force_morn = struct([]);
        Best_Second_Force_morn = struct([]);
        Best_First_Force_noon = struct([]);
        Best_Second_Force_noon = struct([]);

        inlier_idx_morn = struct([]);
        rewarded_outlier_idx_morn = struct([]);
        inlier_idx_noon = struct([]);
        rewarded_outlier_idx_noon = struct([]);

    end

    %% Redifine the rewarded_idx according to the target center
    for kk = 1:length(unique_targets_morn)

        rewarded_idx_morn = total_rewarded_idx_morn(target_cntrs_morn == unique_targets_morn(kk));
        rewarded_idx_noon = total_rewarded_idx_noon(target_cntrs_noon == unique_targets_noon(kk));

        %% Loop to extract only rewarded trials 
        % Rewarded go-cues
        rewarded_gocue_time_morn = zeros(length(rewarded_idx_morn),1);
        for ii = 1:length(rewarded_idx_morn)
            rewarded_gocue_time_morn(ii) = xds_morn.trial_gocue_time(rewarded_idx_morn(ii));
        end
        rewarded_gocue_time_noon = zeros(length(rewarded_idx_noon),1);
        for ii = 1:length(rewarded_idx_noon)
            rewarded_gocue_time_noon(ii) = xds_noon.trial_gocue_time(rewarded_idx_noon(ii));
        end
           
        % Rewarded end times
        rewarded_end_time_morn = zeros(length(rewarded_idx_morn),1);
        for ii = 1:length(rewarded_idx_morn)
            rewarded_end_time_morn(ii) = xds_morn.trial_end_time(rewarded_idx_morn(ii));
        end
        rewarded_end_time_noon = zeros(length(rewarded_idx_noon),1);
        for ii = 1:length(rewarded_idx_noon)
            rewarded_end_time_noon(ii) = xds_noon.trial_end_time(rewarded_idx_noon(ii));
        end

        %% Force and time aligned to specified event
        % Find the rewarded times in the whole trial time frame
        rewarded_end_idx_morn = zeros(height(rewarded_idx_morn),1);
        for ii = 1:length(rewarded_idx_morn)
            rewarded_end_idx_morn(ii) = find(xds_morn.time_frame == rewarded_end_time_morn(ii));
        end

        rewarded_end_idx_noon = zeros(height(rewarded_idx_noon),1);
        for ii = 1:length(rewarded_idx_noon)
            rewarded_end_idx_noon(ii) = find(xds_noon.time_frame == rewarded_end_time_noon(ii));
        end
        
        First_Force_morn = struct([]); % Force during each successful trial
        Second_Force_morn = struct([]);
        for ii = 1:length(rewarded_idx_morn)
            First_Force_morn{ii, 1} = xds_morn.force((rewarded_end_idx_morn(ii) - (TgtHold_time / xds_morn.bin_width) : ...
                rewarded_end_idx_morn(ii)), 1);
            Second_Force_morn{ii, 1} = xds_morn.force((rewarded_end_idx_morn(ii) - (TgtHold_time / xds_morn.bin_width) : ...
                rewarded_end_idx_morn(ii)), 2);
        end

        First_Force_noon = struct([]); % Force during each successful trial
        Second_Force_noon = struct([]);
        for ii = 1:length(rewarded_idx_noon)
            First_Force_noon{ii, 1} = xds_noon.force((rewarded_end_idx_noon(ii) - (TgtHold_time / xds_noon.bin_width) : ...
                rewarded_end_idx_noon(ii)), 1);
            Second_Force_noon{ii, 1} = xds_noon.force((rewarded_end_idx_noon(ii) - (TgtHold_time / xds_noon.bin_width) : ...
                rewarded_end_idx_noon(ii)), 2);
        end

        %% Putting all succesful trials in one array
        
        all_trials_First_Force_morn = zeros(length(First_Force_morn{1,1}), length(rewarded_idx_morn));
        all_trials_Second_Force_morn = zeros(length(Second_Force_morn{1,1}), length(rewarded_idx_morn));
        for ii = 1:length(rewarded_idx_morn)
            all_trials_First_Force_morn(:,ii) = First_Force_morn{ii, 1};
            all_trials_Second_Force_morn(:,ii) = Second_Force_morn{ii, 1};
        end

        all_trials_First_Force_noon = zeros(length(First_Force_noon{1,1}), length(rewarded_idx_noon));
        all_trials_Second_Force_noon = zeros(length(Second_Force_noon{1,1}), length(rewarded_idx_noon));
        for ii = 1:length(rewarded_idx_noon)
            all_trials_First_Force_noon(:,ii) = First_Force_noon{ii, 1};
            all_trials_Second_Force_noon(:,ii) = Second_Force_noon{ii, 1};
        end

        %% Calculating average Force (Average per trial)
        per_trial_avg_First_Force_morn{ss,1} = zeros(length(First_Force_morn), 1);
        per_trial_avg_Second_Force_morn{ss,1} = zeros(length(Second_Force_morn), 1);
        per_trial_avg_First_Force_noon{ss,1} = zeros(length(First_Force_noon), 1);
        per_trial_avg_Second_Force_noon{ss,1} = zeros(length(Second_Force_noon), 1);
        for ii = 1:length(First_Force_morn)
            per_trial_avg_First_Force_morn{ss,1}(ii,1) = mean(all_trials_First_Force_morn(:,ii));
            per_trial_avg_Second_Force_morn{ss,1}(ii,1) = mean(all_trials_Second_Force_morn(:,ii));
        end
        for ii = 1:length(First_Force_noon)
            per_trial_avg_First_Force_noon{ss,1}(ii,1) = mean(all_trials_First_Force_noon(:,ii));
            per_trial_avg_Second_Force_noon{ss,1}(ii,1) = mean(all_trials_Second_Force_noon(:,ii));
        end

        %% Calculate the elliptical error probable
        cat_First_Force = cat(1, per_trial_avg_First_Force_morn{ss,1}, per_trial_avg_First_Force_noon{ss,1})';
        cat_Second_Force = cat(1, per_trial_avg_Second_Force_morn{ss,1}, per_trial_avg_Second_Force_noon{ss,1})';
        
        % Run the elliptical error probability function
        [center_x, center_y, ~, ~, ~, X_ellipse{ss,1}, Y_ellipse{ss,1}] = ...
            Ellip_Err_Prob(cat_First_Force, cat_Second_Force, err_percent);

        %% Find the angle and distance of each ellipse point to the ellipse's center
        theta_ellipse{ss,1} = zeros(length(X_ellipse{ss,1}), 1);
        ellipse_distance{ss, 1} = zeros(length(X_ellipse{ss,1}), 1);
        for ii = 1:length(X_ellipse{ss,1})
            % Angle
            theta_ellipse{ss,1}(ii,1) = atan2d(Y_ellipse{ss,1}(ii) - center_y, ...
                X_ellipse{ss,1}(ii) - center_x);
            % Distance
            ellipse_distance{ss, 1}(ii,1) = sqrt((Y_ellipse{ss,1}(ii) - center_y)^2 + ...
                (X_ellipse{ss,1}(ii) - center_x)^2);
        end

        %% Find the angle, index, and distance of each force point to the ellipse's center
        theta_force{ss,1} = zeros(length(cat_First_Force), 1);
        theta_idx{ss,1} = zeros(length(cat_First_Force), 1);
        force_distance{ss,1} = zeros(length(cat_First_Force), 1);
        for ii = 1:length(cat_First_Force)
            % Angle
            theta_force{ss,1}(ii,1) = atan2d(cat_Second_Force(ii) - center_y, ...
                cat_First_Force(ii) - center_x);
            % Index
            theta_idx{ss,1}(ii,1) = find(min(abs(theta_ellipse{ss,1} - theta_force{ss,1}(ii,1))) == ...
                abs(theta_ellipse{ss,1} - theta_force{ss,1}(ii,1)));
            % Distance
            force_distance{ss,1}(ii,1) = sqrt((cat_Second_Force(ii) - center_y)^2 + ...
                (cat_First_Force(ii) - center_x)^2);
        end

        %% Find the force points outside the error ellipse
        outlier_idx{ss,1} = zeros(length(cat_First_Force), 1);
        for ii = 1:length(cat_First_Force)
            if force_distance{ss,1}(ii,1) > ellipse_distance{ss, 1}(theta_idx{ss,1}(ii,1),1)
                outlier_idx{ss,1}(ii,1) = 0;
            else
                outlier_idx{ss,1}(ii,1) = 1;
            end
        end

        %% Seperate the outlier index into morning and afternoon
        outlier_idx_morn{ss,1} = outlier_idx{ss,1}(1:length(per_trial_avg_First_Force_morn{ss,1}),1);
        outlier_idx_noon{ss,1} = outlier_idx{ss,1}(length(per_trial_avg_First_Force_morn{ss,1}) + 1:end);

        %% Remove the outliers from the force points
        % Morning
        Best_First_Force_morn{ss,1} = per_trial_avg_First_Force_morn{ss,1};
        Best_First_Force_morn{ss,1}(~outlier_idx_morn{ss,1}) = [];
        Best_Second_Force_morn{ss,1} = per_trial_avg_Second_Force_morn{ss,1};
        Best_Second_Force_morn{ss,1}(~outlier_idx_morn{ss,1}) = [];

        % Afternoon
        Best_First_Force_noon{ss,1} = per_trial_avg_First_Force_noon{ss,1};
        Best_First_Force_noon{ss,1}(~outlier_idx_noon{ss,1}) = [];
        Best_Second_Force_noon{ss,1} = per_trial_avg_Second_Force_noon{ss,1};
        Best_Second_Force_noon{ss,1}(~outlier_idx_noon{ss,1}) = [];

        %% Find the index of the force outliers in xds
        % Morning
        rewarded_inlier_idx_morn = rewarded_idx_morn;
        rewarded_outlier_idx_morn{ss,1} = rewarded_idx_morn;
        rewarded_inlier_idx_morn(~outlier_idx_morn{ss,1}) = [];
        inlier_idx_morn{ss,1} = ~ismember(rewarded_idx_morn, rewarded_inlier_idx_morn);
        rewarded_outlier_idx_morn{ss,1}(~inlier_idx_morn{ss,1}) = [];

        % Afternoon
        rewarded_inlier_idx_noon = rewarded_idx_noon;
        rewarded_outlier_idx_noon{ss,1} = rewarded_idx_noon;
        rewarded_inlier_idx_noon(~outlier_idx_noon{ss,1}) = [];
        inlier_idx_noon{ss,1} = ~ismember(rewarded_idx_noon, rewarded_inlier_idx_noon);
        rewarded_outlier_idx_noon{ss,1}(~inlier_idx_noon{ss,1}) = [];

        %% Remove the force outliers from xds
        % Morning
        result_idx = find(strcmp(xds_morn.trial_info_table_header, 'result'));
        xds_morn.trial_info_table(rewarded_outlier_idx_morn{ss,1}, result_idx) = {'F'};
        xds_morn.trial_result(rewarded_outlier_idx_morn{ss,1}) = 'F';

        % Afternoon
        result_idx = find(strcmp(xds_noon.trial_info_table_header, 'result'));
        xds_noon.trial_info_table(rewarded_outlier_idx_noon{ss,1}, result_idx) = {'F'};
        xds_noon.trial_result(rewarded_outlier_idx_noon{ss,1}) = 'F';
  
        % Add to the counter
        ss = ss + 1;
       
    end % End of target center loop

end % End of target direction loop

if ~isequal(Plot_Figs, 0)
    %% Plot the force scatter (All Points)

    figure
    hold on

    % Label the axis
    xlabel('Force Sensor 1');
    ylabel('Force Sensor 2');

    % Date
    File_Name = xds_noon.meta.rawFileName;
    nondate_info = extractAfter(File_Name, '_');
    Date = erase(File_Name, strcat('_', nondate_info));
    % Monkey
    nonmonkey_info = extractAfter(nondate_info, '_');
    % Task
    nontask_info = extractAfter(nonmonkey_info, '_');
    Task = erase(nonmonkey_info, strcat('_', nontask_info));
    % Drug
    if contains(nontask_info, 'Caff')
        Drug = 'Caffeine';
    end
    if contains(nontask_info, 'Lex')
        Drug = 'Escitalopram';
    end
    if contains(nontask_info, 'Cyp')
        Drug = 'Cypro';
    end
    if contains(nontask_info, 'Con')
        Drug = 'Control';
    end

    % Set the title
    title_string = strcat(Date, {' '}, Task, ',', {' '}, Drug, ': Force');
    title(title_string)

    % Force marker shape & marker size
    decom_marker_metric ='.';
    decom_sz = 100;

    for jj = 1:length(per_trial_avg_First_Force_morn)

        % Plot the normalized TgtHold Force
        scatter(per_trial_avg_First_Force_morn{jj}, per_trial_avg_Second_Force_morn{jj}, decom_sz, decom_marker_metric, 'MarkerEdgeColor', ...
            [0.9290, 0.6940, 0.1250], 'MarkerFaceColor', [0.9290, 0.6940, 0.1250]);
        scatter(per_trial_avg_First_Force_noon{jj}, per_trial_avg_Second_Force_noon{jj}, decom_sz, decom_marker_metric, 'MarkerEdgeColor', ...
            [0.5 0 0.5], 'MarkerFaceColor', [0.5 0 0.5]);
        % Plot the ellipital error
     plot(X_ellipse{jj}, Y_ellipse{jj}, 'Color', 'k');
    end

    % Calculate the axis limits
    curr_axis = gca;
    min_x = curr_axis.XLim(1);
    min_y = curr_axis.YLim(1);
    axis_min = round(min(min_x, min_y)/5)*5;
    max_x = curr_axis.XLim(2);
    max_y = curr_axis.YLim(2);
    axis_max = round(max(max_x, max_y)/5)*5;
    
    % Draw the identity line 
    line([axis_min, axis_max],[axis_min, axis_max], ...
        'Color', 'k', 'Linestyle','--')

    %% Plot the force scatter (without the outliers)

    figure
    hold on

    % Label the axis
    xlabel('Force Sensor 1');
    ylabel('Force Sensor 2');
    
    % Set the title
    title_string = strcat(Date, {' '}, Task, ',', {' '}, Drug, ': Force (Outliers Removed)');
    title(title_string)

    for jj = 1:length(per_trial_avg_First_Force_morn)

        % Plot the normalized TgtHold Force
        scatter(Best_First_Force_morn{jj}, Best_Second_Force_morn{jj}, decom_sz, decom_marker_metric, ...
            'MarkerEdgeColor', [0.9290, 0.6940, 0.1250], 'MarkerFaceColor', [0.9290, 0.6940, 0.1250]);
        scatter(Best_First_Force_noon{jj}, Best_Second_Force_noon{jj}, decom_sz, decom_marker_metric, ...
            'MarkerEdgeColor', [0.5 0 0.5], 'MarkerFaceColor', [0.5 0 0.5]);
        % Plot the ellipital error
        plot(X_ellipse{jj}, Y_ellipse{jj}, 'Color', 'k');
    end

    % Calculate the axis limits
    curr_axis = gca;
    min_x = curr_axis.XLim(1);
    min_y = curr_axis.YLim(1);
    axis_min = round(min(min_x, min_y)/5)*5;
    max_x = curr_axis.XLim(2);
    max_y = curr_axis.YLim(2);
    axis_max = round(max(max_x, max_y)/5)*5;

    % Draw the identity line 
    line([axis_min, axis_max],[axis_min, axis_max], ...
        'Color', 'k', 'Linestyle','--')

end

%% Define the save directory & save the figures
if ~isequal(Save_Figs, 0) && ~isequal(Plot_Figs, 0)
    save_dir = 'C:\Users\rhpow\Desktop\';
    for ii = numel(findobj('type','figure')):-1:1
        fig_info = get(gca,'title');
        save_title = get(fig_info, 'string');
        save_title = strrep(save_title, ':', '');
        save_title = strrep(save_title, 'vs.', 'vs');
        save_title = strrep(save_title, 'mg.', 'mg');
        save_title = strrep(save_title, 'kg.', 'kg');
        save_title = strrep(save_title, '.', '_');
        save_title = strrep(save_title, '/', '_');
        if ~strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), Save_Figs)
        end
        if strcmp(Save_Figs, 'All')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'png')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'pdf')
            saveas(gcf, fullfile(save_dir, char(save_title)), 'fig')
        end
        close gcf
    end
end


