<<<<<<< HEAD
clear
load([pwd,'\stimu_idx_side.mat']);
load([pwd,'\whisker_side\timestamps_side_aligned.mat']);
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\stimu_idx_2p.mat']);
% stimu_idx = stimu_idx_side;

non_stimu_time_mean = 55;
stimu_time_mean = 5;
FrameRate_2p = 1/mean(diff(NeuronActivity.timestamps));
FrameRate_behav = 1/mean(diff(timestamps_side_aligned))


files = dir('whisker_side/*_filtered.csv');
paw_data = cell(1, 10);
for i = 1:length(files)
    
    filename = fullfile('whisker_side', files(i).name);
    
   
    data = readtable(filename);
    data(:,1) = [];

    for j = 1:10
     
        
%         paw_data{j} = [data{:, 2*(j-1)+1}, data{:, 2*(j-1)+2}, data{:, 2*(j-1)+3}];
        paw_data{j}=[data{:, 3*j-2}, data{:, 3*j-1}, data{:, 3*j}];
        
    end
end

Paw_x = paw_data{3}(:,1);
Paw_y = paw_data{3}(:,2);
likelihood = paw_data{3}(:,3);
valid_idx = likelihood > 0.9; 
Paw_x(~valid_idx) = NaN;
Paw_y(~valid_idx) = NaN;
Paw_x = fillmissing(Paw_x, 'linear');
Paw_y = fillmissing(Paw_y, 'linear');

% plot(Paw_x);
% hold on;
% plot(Paw_y);
% pawX_smooth = smoothdata(Paw_x,'gaussian',100);
% pawX_change  = abs(diff(pawX_smooth));
pawX_change  = abs(diff(Paw_x));
pawX_change  = [pawX_change;pawX_change(end)];
pawX_change = pawX_change*FrameRate_behav;
% plot(pawX_change)

%%

num_trials = size(stimu_idx_side, 1);  % 
% stim_duration = round(mean(stimu_idx_side(:,end) - stimu_idx_side(:,1)));  % 刺激开始到结束对应的帧数
Paw_move = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx_side(i,1):stimu_idx_side(i,end);
        non_stimu_duration = stimu_idx_side(i,end)+1:stimu_idx_side(i+1,1)-1
    else
        stimu_duration = stimu_idx_side(i,1):stimu_idx_side(i,end);
       max_idx = min(stimu_idx_side(i,end)+round(non_stimu_time_mean*FrameRate_behav),length(timestamps_side_aligned));
        non_stimu_duration = stimu_idx_side(i,end)+1:max_idx;
    end
        duration = [stimu_duration,non_stimu_duration];
    
    Paw_move(i,1) = sum(pawX_change(stimu_duration))/length(stimu_duration);
     Paw_move(i,2) = sum(pawX_change(non_stimu_duration))/length(non_stimu_duration);
      Paw_move(i,3) = sum(pawX_change(duration))/length(duration);
     
end
Paw_move_mean = mean(Paw_move,1);
%% Paw movement 2p
timestamps = NeuronActivity.timestamps;
behav_time = timestamps_side_aligned;
min_indices = zeros(size(timestamps));  
Paw_movement = zeros(size(timestamps));
for i = 1:length(timestamps)  
    diffs = behav_time - timestamps(i);     
    [~, min_index] = min(abs(diffs));  
   % 
   
    if abs(diffs(min_index)) > 0.1
        min_indices(i) = NaN;
    else
        min_indices(i) = min_index;
    end
end



for j = 1:length(min_indices)
    if ~isnan(min_indices(j))
    Paw_movement(j) = pawX_change(min_indices(j));
    else
        Paw_movement(j) = NaN;
    end    
end

Paw_move_2p = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i+1,1)-1
    else
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i,end)+round(non_stimu_time_mean*FrameRate_2p);
    end
        duration = [stimu_duration,non_stimu_duration];
    
    Paw_move_2p(i,1) = nanmean(Paw_movement(stimu_duration));
     Paw_move_2p(i,2) = nanmean(Paw_movement(non_stimu_duration));
      Paw_move_2p(i,3) = nanmean(Paw_movement(duration));
     
end

%% 
start_idx_2p = find(~isnan(Paw_movement), 1, 'first'); 
end_idx_2p = find(~isnan(Paw_movement), 1, 'last'); 

cellNum = NeuronActivity.CellNum;
detaF_F_denoised = NeuronActivity.detaF_F_denoised(start_idx_2p:end_idx_2p,:);
detaF_F_raw = NeuronActivity.detaF_F_raw(start_idx_2p:end_idx_2p,:);
Event_raw = NeuronActivity.Event_raw_exp2(start_idx_2p:end_idx_2p,:);
Event_filtered = NeuronActivity.Event_filtered_exp2(start_idx_2p:end_idx_2p,:);

Paw_move_mean_2p = mean(Paw_move_2p,1);
start_idx_2p = find(~isnan(Paw_movement), 1, 'first'); 
end_idx_2p = find(~isnan(Paw_movement), 1, 'last'); 


Paw_movement = Paw_movement(start_idx_2p:end_idx_2p);
Paw_movement_denoised = smoothdata(Paw_movement,'gaussian',10);
Paw_movement_denoised(isnan(Paw_movement_denoised)) = 0;

correlation_paw = zeros(cellNum,4);  %四列分别为detaf_f_raw;deta_f_f_denoised;event_raw;event_filtered;
for i = 1:cellNum
    correlation_paw(i,1) = corr(Paw_movement_denoised,detaF_F_raw(:,i));
    correlation_paw(i,2) = corr(Paw_movement_denoised,detaF_F_denoised(:,i));
    correlation_paw(i,3) = corr(Paw_movement_denoised,Event_raw(:,i));
    correlation_paw(i,4) = corr(Paw_movement_denoised,Event_filtered(:,i));
end

 save([pwd,'\Paw_movement_filtered.mat'],'Paw_move','Paw_move_mean','Paw_move_2p','Paw_move_mean_2p',...
    'pawX_change','Paw_movement','Paw_movement_denoised','correlation_paw');

=======
clear
load([pwd,'\stimu_idx_side.mat']);
load([pwd,'\whisker_side\timestamps_side_aligned.mat']);
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\stimu_idx_2p.mat']);
% stimu_idx = stimu_idx_side;

non_stimu_time_mean = 55;
stimu_time_mean = 5;
FrameRate_2p = 1/mean(diff(NeuronActivity.timestamps));
FrameRate_behav = 1/mean(diff(timestamps_side_aligned))


files = dir('whisker_side/*_filtered.csv');
paw_data = cell(1, 10);
for i = 1:length(files)
    
    filename = fullfile('whisker_side', files(i).name);
    
   
    data = readtable(filename);
    data(:,1) = [];

    for j = 1:10
     
        
%         paw_data{j} = [data{:, 2*(j-1)+1}, data{:, 2*(j-1)+2}, data{:, 2*(j-1)+3}];
        paw_data{j}=[data{:, 3*j-2}, data{:, 3*j-1}, data{:, 3*j}];
        
    end
end

Paw_x = paw_data{3}(:,1);
Paw_y = paw_data{3}(:,2);
likelihood = paw_data{3}(:,3);
valid_idx = likelihood > 0.9; 
Paw_x(~valid_idx) = NaN;
Paw_y(~valid_idx) = NaN;
Paw_x = fillmissing(Paw_x, 'linear');
Paw_y = fillmissing(Paw_y, 'linear');

% plot(Paw_x);
% hold on;
% plot(Paw_y);
% pawX_smooth = smoothdata(Paw_x,'gaussian',100);
% pawX_change  = abs(diff(pawX_smooth));
pawX_change  = abs(diff(Paw_x));
pawX_change  = [pawX_change;pawX_change(end)];
pawX_change = pawX_change*FrameRate_behav;
% plot(pawX_change)

%%

num_trials = size(stimu_idx_side, 1);  % 
% stim_duration = round(mean(stimu_idx_side(:,end) - stimu_idx_side(:,1)));  % 刺激开始到结束对应的帧数
Paw_move = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx_side(i,1):stimu_idx_side(i,end);
        non_stimu_duration = stimu_idx_side(i,end)+1:stimu_idx_side(i+1,1)-1
    else
        stimu_duration = stimu_idx_side(i,1):stimu_idx_side(i,end);
       max_idx = min(stimu_idx_side(i,end)+round(non_stimu_time_mean*FrameRate_behav),length(timestamps_side_aligned));
        non_stimu_duration = stimu_idx_side(i,end)+1:max_idx;
    end
        duration = [stimu_duration,non_stimu_duration];
    
    Paw_move(i,1) = sum(pawX_change(stimu_duration))/length(stimu_duration);
     Paw_move(i,2) = sum(pawX_change(non_stimu_duration))/length(non_stimu_duration);
      Paw_move(i,3) = sum(pawX_change(duration))/length(duration);
     
end
Paw_move_mean = mean(Paw_move,1);
%% Paw movement 2p
timestamps = NeuronActivity.timestamps;
behav_time = timestamps_side_aligned;
min_indices = zeros(size(timestamps));  
Paw_movement = zeros(size(timestamps));
for i = 1:length(timestamps)  
    diffs = behav_time - timestamps(i);     
    [~, min_index] = min(abs(diffs));  
   % 
   
    if abs(diffs(min_index)) > 0.1
        min_indices(i) = NaN;
    else
        min_indices(i) = min_index;
    end
end



for j = 1:length(min_indices)
    if ~isnan(min_indices(j))
    Paw_movement(j) = pawX_change(min_indices(j));
    else
        Paw_movement(j) = NaN;
    end    
end

Paw_move_2p = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i+1,1)-1
    else
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i,end)+round(non_stimu_time_mean*FrameRate_2p);
    end
        duration = [stimu_duration,non_stimu_duration];
    
    Paw_move_2p(i,1) = nanmean(Paw_movement(stimu_duration));
     Paw_move_2p(i,2) = nanmean(Paw_movement(non_stimu_duration));
      Paw_move_2p(i,3) = nanmean(Paw_movement(duration));
     
end

%% 
start_idx_2p = find(~isnan(Paw_movement), 1, 'first'); 
end_idx_2p = find(~isnan(Paw_movement), 1, 'last'); 

cellNum = NeuronActivity.CellNum;
detaF_F_denoised = NeuronActivity.detaF_F_denoised(start_idx_2p:end_idx_2p,:);
detaF_F_raw = NeuronActivity.detaF_F_raw(start_idx_2p:end_idx_2p,:);
Event_raw = NeuronActivity.Event_raw_exp2(start_idx_2p:end_idx_2p,:);
Event_filtered = NeuronActivity.Event_filtered_exp2(start_idx_2p:end_idx_2p,:);

Paw_move_mean_2p = mean(Paw_move_2p,1);
start_idx_2p = find(~isnan(Paw_movement), 1, 'first'); 
end_idx_2p = find(~isnan(Paw_movement), 1, 'last'); 


Paw_movement = Paw_movement(start_idx_2p:end_idx_2p);
Paw_movement_denoised = smoothdata(Paw_movement,'gaussian',10);
Paw_movement_denoised(isnan(Paw_movement_denoised)) = 0;

correlation_paw = zeros(cellNum,4);  %四列分别为detaf_f_raw;deta_f_f_denoised;event_raw;event_filtered;
for i = 1:cellNum
    correlation_paw(i,1) = corr(Paw_movement_denoised,detaF_F_raw(:,i));
    correlation_paw(i,2) = corr(Paw_movement_denoised,detaF_F_denoised(:,i));
    correlation_paw(i,3) = corr(Paw_movement_denoised,Event_raw(:,i));
    correlation_paw(i,4) = corr(Paw_movement_denoised,Event_filtered(:,i));
end

 save([pwd,'\Paw_movement_filtered.mat'],'Paw_move','Paw_move_mean','Paw_move_2p','Paw_move_mean_2p',...
    'pawX_change','Paw_movement','Paw_movement_denoised','correlation_paw');

>>>>>>> 342f783 (Include MINI2P_toolbox as a regular foloder)
