<<<<<<< HEAD
clear
addpath(genpath('D:\Test_code\whisker'));
path = pwd;

load([pwd,'\stimu_idx.mat']);
load([pwd,'\whisker_above\timestamps_above_aligned.mat']);
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\stimu_idx_2p.mat']);
% stimu_idx = stimu_idx;

non_stimu_time_mean = 55;
stimu_time_mean = 5;
FrameRate_2p = 1/mean(diff(NeuronActivity.timestamps));
FrameRate_behav = 1/mean(diff(timestamps_above_aligned))

files = dir('whisker_above/*_filtered.csv');

behav = struct;
behav.position = cell(1, 2);
behav.time = timestamps_above_aligned;
 
for i = 1:length(files)
  
    filename = fullfile('whisker_above', files(i).name);
    
    data = readtable(filename);
    data(:,1) = [];
    
    for j = 1:2
        
        behav.position{1,j} = [data{:, 3*j-2}, data{:, 3*j-1}, data{:, 3*j}];
        
    end
end


[root,tail,theta] = frequency_tuning(behav, NeuronActivity);


x_coordinates = tail(:,1);
y_coordinates = tail(:,2);

% theta_smooth = smoothdata(theta,'gaussian',5);
theta_change  = diff(theta);

theta_change  = abs(theta_change);
theta_change  = [theta_change;theta_change(end)];
theta_change = theta_change * FrameRate_behav;
% plot(theta_change)
%%

num_trials = size(stimu_idx, 1);  % 
% stim_duration = round(mean(stimu_idx(:,end) - stimu_idx(:,1)));  % 刺激开始到结束对应的帧数
whisker_move = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx(i,1):stimu_idx(i,end);
        non_stimu_duration = stimu_idx(i,end)+1:stimu_idx(i+1,1)-1
    else
        stimu_duration = stimu_idx(i,1):stimu_idx(i,end);
       max_idx = min(stimu_idx(i,end)+round(non_stimu_time_mean*FrameRate_behav),length(timestamps_above_aligned));
        non_stimu_duration = stimu_idx(i,end)+1:max_idx;
    end
        duration = [stimu_duration,non_stimu_duration];
    
    whisker_move(i,1) = sum(theta_change(stimu_duration))/length(stimu_duration) ;
     whisker_move(i,2) = sum(theta_change(non_stimu_duration))/length(non_stimu_duration) ;
      whisker_move(i,3) = sum(theta_change(duration))/length(duration) ;
     
end
whisker_move_mean = mean(whisker_move,1);
%% whisker movement 2p
timestamps = NeuronActivity.timestamps;
behav_time = timestamps_above_aligned;
min_indices = zeros(size(timestamps));  
whisker_energy = zeros(size(timestamps));
for i = 1:length(timestamps)  
    diffs = behav_time - timestamps(i);     
    [~, min_index] = min(abs(diffs));  
     if abs(diffs(min_index)) > 0.1
        min_indices(i) = NaN;
    else
    min_indices(i) = min_index; 
     end
end


for j = 1:length(min_indices)
     if ~isnan(min_indices(j))
    whisker_energy(j) = theta_change(min_indices(j));
     else
          whisker_energy(j) = NaN;
     end
end


whisker_move_2p = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i+1,1)-1
    else
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i,end)+round(non_stimu_time_mean*FrameRate_2p);
    end
        duration = [stimu_duration,non_stimu_duration];
    
    whisker_move_2p(i,1) = nanmean(whisker_energy(stimu_duration));
     whisker_move_2p(i,2) = nanmean(whisker_energy(non_stimu_duration));
      whisker_move_2p(i,3) = nanmean(whisker_energy(duration));
     
end
whisker_move_mean_2p = mean(whisker_move_2p,1);
 
start_idx_2p = find(~isnan(whisker_energy), 1, 'first'); 
end_idx_2p = find(~isnan(whisker_energy), 1, 'last'); 

whisker_energy = whisker_energy(start_idx_2p:end_idx_2p);
whisker_energy_denoised = smoothdata(whisker_energy,'gaussian',20);
whisker_energy_denoised(isnan(whisker_energy_denoised)) = 0;
set(gcf,'position',[50 50 600 100])
plot(whisker_energy_denoised)
saveas(gcf,[pwd, '\whisker_energy.jpg']);

cellNum = NeuronActivity.CellNum;
detaF_F_denoised = NeuronActivity.detaF_F_denoised(start_idx_2p:end_idx_2p,:);
detaF_F_raw = NeuronActivity.detaF_F_raw(start_idx_2p:end_idx_2p,:);
Event_raw = NeuronActivity.Event_raw_exp2(start_idx_2p:end_idx_2p,:);
Event_filtered = NeuronActivity.Event_filtered_exp2(start_idx_2p:end_idx_2p,:);
correlation_whisker = zeros(cellNum,4);  %四列分别为detaf_f_raw;deta_f_f_denoised;event_raw;event_filtered;
for i = 1:cellNum
    correlation_whisker(i,1) = corr(whisker_energy_denoised,detaF_F_raw(:,i));
    correlation_whisker(i,2) = corr(whisker_energy_denoised,detaF_F_denoised(:,i));
    correlation_whisker(i,3) = corr(whisker_energy_denoised,Event_raw(:,i));
    correlation_whisker(i,4) = corr(whisker_energy_denoised,Event_filtered(:,i));
end


save([pwd,'\whisker_energy.mat'],'whisker_move','whisker_move_mean',...
    'whisker_move_2p','whisker_move_mean_2p','root','tail','theta',...
    'theta_change','whisker_energy','start_idx_2p','end_idx_2p',...
    'correlation_whisker');
%% shuffle_whisker

% [root,tail,theta] = frequency_tuning(behav, NeuronActivity);
% 
% x_coordinates = tail(:,1);
% y_corrdinates = tail(:,2);
iteration = 1000;
correlation_shuffle_whisker = cell(1,4);
correlation_shuffle_whisker{1} =  zeros(iteration+3,4);
correlation_shuffle_whisker{2} =  zeros(iteration+3,4);
correlation_shuffle_whisker{3} =  zeros(iteration+3,4);
correlation_shuffle_whisker{4} =  zeros(iteration+3,4);
randindex = randi(length(behav_time)-1,[iteration,1]);

for i = 1:cellNum
   
    for n = 1:iteration
        theta_shuffle(:,1)=[theta((randindex(n)+1):end,1);theta(1:randindex(n),1)];
%         theta_smooth_shuffle = smoothdata(theta_shuffle,'gaussian',100);
         theta_change_shuffle  = diff(theta_shuffle);
           theta_change_shuffle = abs(theta_change_shuffle);
          
           theta_change_shuffle = [theta_change_shuffle;theta_change_shuffle(end)];
            theta_change_shuffle = abs(theta_change_shuffle)*FrameRate_behav;
            whisker_energy_shuffle = zeros(size(timestamps));
      
      
        for j = 1:length(min_indices)
            if ~isnan(min_indices(j))
             whisker_energy_shuffle(j) = theta_change_shuffle(min_indices(j));
            else
                whisker_energy_shuffle(j) = 0;
            end
        end
        
        
        whisker_energy_shuffle = whisker_energy_shuffle(start_idx_2p:end_idx_2p);
        
        whisker_energy_denoised_shuffle = smoothdata(whisker_energy_shuffle,'gaussian',20);
        whisker_energy_denoised_shuffle(isnan(whisker_energy_denoised_shuffle)) = 0;
        correlation_shuffle_whisker{1}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_raw(:,i));
        correlation_shuffle_whisker{2}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_denoised(:,i));
        correlation_shuffle_whisker{3}(i,n) = corr(whisker_energy_denoised_shuffle,Event_raw(:,i));
        correlation_shuffle_whisker{4}(i,n) = corr(whisker_energy_denoised_shuffle,Event_filtered(:,i));
  
    end
       
        
        correlation_shuffle_whisker{1}(i,iteration+3) = corr(whisker_energy_denoised,detaF_F_raw(:,i));
        correlation_shuffle_whisker{2}(i,iteration+3) = corr(whisker_energy_denoised,detaF_F_denoised(:,i));
        correlation_shuffle_whisker{3}(i,iteration+3) = corr(whisker_energy_denoised,Event_raw(:,i));
        correlation_shuffle_whisker{4}(i,iteration+3) = corr(whisker_energy_denoised,Event_filtered(:,i)); 
        
        correlation_shuffle_whisker{1}(i,iteration+1) = prctile(correlation_shuffle_whisker{1}(i,1:iteration),95);
        correlation_shuffle_whisker{2}(i,iteration+1) = prctile(correlation_shuffle_whisker{2}(i,1:iteration),95);
        correlation_shuffle_whisker{3}(i,iteration+1) = prctile(correlation_shuffle_whisker{3}(i,1:iteration),95);
        correlation_shuffle_whisker{4}(i,iteration+1) = prctile(correlation_shuffle_whisker{4}(i,1:iteration),95);
        
        correlation_shuffle_whisker{1}(i,iteration+2) = prctile(correlation_shuffle_whisker{1}(i,1:iteration),99);
        correlation_shuffle_whisker{2}(i,iteration+2) = prctile(correlation_shuffle_whisker{2}(i,1:iteration),99);
        correlation_shuffle_whisker{3}(i,iteration+2) = prctile(correlation_shuffle_whisker{3}(i,1:iteration),99);
        correlation_shuffle_whisker{4}(i,iteration+2) = prctile(correlation_shuffle_whisker{4}(i,1:iteration),99);
        disp(['cell ',num2str(i),' has been shuffled']);
end
Tuning99_whisker = [];
Tuning95_whisker = [];
for i = 1:cellNum
    if correlation_shuffle_whisker{2}(i,iteration+3) >= correlation_shuffle_whisker{2}(i,iteration+2)
        Tuning99_whisker = [Tuning99_whisker;i];
    elseif correlation_shuffle_whisker{2}(i,iteration+3) >= correlation_shuffle_whisker{2}(i,iteration+1)
        Tuning95_whisker = [Tuning95_whisker;i];
    end
end
Tuninglist_95= [Tuning99_whisker;Tuning95_whisker];
Tuninglist_99 = Tuning99_whisker;
 save([pwd,'\correlation_shuffle_whisker_1000.mat'],'correlation_shuffle_whisker','Tuninglist_95','Tuninglist_99');
 

%% Plot
cell_list = Tuninglist_95;    
load([pwd,'\Paw_movement.mat']);
figure
 set(gcf,'position',[50 50 600 100])
plot(Paw_movement_denoised)
saveas(gcf,[pwd, '\Paw_energy.jpg']);

% cell_list = 1:1:NeuronActivity.CellNum;    
% new_folder = 'CellFigure_1000_95';
new_folder = 'CellFigure_95';
mkdir ('method2',new_folder)
for i = 1:length(cell_list)
     
    clf
    set(gcf,'position',[50 50 600 800])
%     subplot(10,1,1)
%     plot(1:length(x_coordinates),x_coordinates);
%     title(['cell: ',num2str(cell_list(i))]);
%     subplot(10,1,2)
%     plot(1:length(theta),theta);
%     
%    
%     subplot(10,1,4)
%     plot(1:length(theta_change),theta_change);
    subplot(6,1,1)
    plot(1:length(whisker_energy),whisker_energy);
    title('whisker_energy')
    subplot(6,1,2)
    plot(1:length(whisker_energy_denoised),whisker_energy_denoised);
    title('whisker_energy_denoised')
    subplot(6,1,3)
    plot(1:length(NeuronActivity.detaF_F_raw(:,cell_list(i))),NeuronActivity.detaF_F_raw(:,cell_list(i)));
     title('detaF_F_raw')
    subplot(6,1,4)
    plot(1:length(NeuronActivity.detaF_F_denoised(:,cell_list(i))),NeuronActivity.detaF_F_denoised(:,cell_list(i)));
      title('detaF_F_denoised')
    subplot(6,1,5)
    plot(1:length(pawX_change),pawX_change);
     title('paw movement')
    subplot(6,1,6)
    plot(1:length(Paw_movement_denoised),Paw_movement_denoised);
     title('paw movement denoised')
    % 
% 
    hold off
  
     % save figure
     saveas(gcf,[pwd, '\method2\',new_folder,'\','cell', num2str(cell_list(i)),'.jpg'])
end


=======
clear
addpath(genpath('D:\Test_code\whisker'));
path = pwd;

load([pwd,'\stimu_idx.mat']);
load([pwd,'\whisker_above\timestamps_above_aligned.mat']);
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\stimu_idx_2p.mat']);
% stimu_idx = stimu_idx;

non_stimu_time_mean = 55;
stimu_time_mean = 5;
FrameRate_2p = 1/mean(diff(NeuronActivity.timestamps));
FrameRate_behav = 1/mean(diff(timestamps_above_aligned))

files = dir('whisker_above/*_filtered.csv');

behav = struct;
behav.position = cell(1, 2);
behav.time = timestamps_above_aligned;
 
for i = 1:length(files)
  
    filename = fullfile('whisker_above', files(i).name);
    
    data = readtable(filename);
    data(:,1) = [];
    
    for j = 1:2
        
        behav.position{1,j} = [data{:, 3*j-2}, data{:, 3*j-1}, data{:, 3*j}];
        
    end
end


[root,tail,theta] = frequency_tuning(behav, NeuronActivity);


x_coordinates = tail(:,1);
y_coordinates = tail(:,2);

% theta_smooth = smoothdata(theta,'gaussian',5);
theta_change  = diff(theta);

theta_change  = abs(theta_change);
theta_change  = [theta_change;theta_change(end)];
theta_change = theta_change * FrameRate_behav;
% plot(theta_change)
%%

num_trials = size(stimu_idx, 1);  % 
% stim_duration = round(mean(stimu_idx(:,end) - stimu_idx(:,1)));  % 刺激开始到结束对应的帧数
whisker_move = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx(i,1):stimu_idx(i,end);
        non_stimu_duration = stimu_idx(i,end)+1:stimu_idx(i+1,1)-1
    else
        stimu_duration = stimu_idx(i,1):stimu_idx(i,end);
       max_idx = min(stimu_idx(i,end)+round(non_stimu_time_mean*FrameRate_behav),length(timestamps_above_aligned));
        non_stimu_duration = stimu_idx(i,end)+1:max_idx;
    end
        duration = [stimu_duration,non_stimu_duration];
    
    whisker_move(i,1) = sum(theta_change(stimu_duration))/length(stimu_duration) ;
     whisker_move(i,2) = sum(theta_change(non_stimu_duration))/length(non_stimu_duration) ;
      whisker_move(i,3) = sum(theta_change(duration))/length(duration) ;
     
end
whisker_move_mean = mean(whisker_move,1);
%% whisker movement 2p
timestamps = NeuronActivity.timestamps;
behav_time = timestamps_above_aligned;
min_indices = zeros(size(timestamps));  
whisker_energy = zeros(size(timestamps));
for i = 1:length(timestamps)  
    diffs = behav_time - timestamps(i);     
    [~, min_index] = min(abs(diffs));  
     if abs(diffs(min_index)) > 0.1
        min_indices(i) = NaN;
    else
    min_indices(i) = min_index; 
     end
end


for j = 1:length(min_indices)
     if ~isnan(min_indices(j))
    whisker_energy(j) = theta_change(min_indices(j));
     else
          whisker_energy(j) = NaN;
     end
end


whisker_move_2p = zeros(num_trials,3);
for i = 1:num_trials
    if i < num_trials
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i+1,1)-1
    else
        stimu_duration = stimu_idx_2p(i,1):stimu_idx_2p(i,end);
        non_stimu_duration = stimu_idx_2p(i,end)+1:stimu_idx_2p(i,end)+round(non_stimu_time_mean*FrameRate_2p);
    end
        duration = [stimu_duration,non_stimu_duration];
    
    whisker_move_2p(i,1) = nanmean(whisker_energy(stimu_duration));
     whisker_move_2p(i,2) = nanmean(whisker_energy(non_stimu_duration));
      whisker_move_2p(i,3) = nanmean(whisker_energy(duration));
     
end
whisker_move_mean_2p = mean(whisker_move_2p,1);
 
start_idx_2p = find(~isnan(whisker_energy), 1, 'first'); 
end_idx_2p = find(~isnan(whisker_energy), 1, 'last'); 

whisker_energy = whisker_energy(start_idx_2p:end_idx_2p);
whisker_energy_denoised = smoothdata(whisker_energy,'gaussian',20);
whisker_energy_denoised(isnan(whisker_energy_denoised)) = 0;
set(gcf,'position',[50 50 600 100])
plot(whisker_energy_denoised)
saveas(gcf,[pwd, '\whisker_energy.jpg']);

cellNum = NeuronActivity.CellNum;
detaF_F_denoised = NeuronActivity.detaF_F_denoised(start_idx_2p:end_idx_2p,:);
detaF_F_raw = NeuronActivity.detaF_F_raw(start_idx_2p:end_idx_2p,:);
Event_raw = NeuronActivity.Event_raw_exp2(start_idx_2p:end_idx_2p,:);
Event_filtered = NeuronActivity.Event_filtered_exp2(start_idx_2p:end_idx_2p,:);
correlation_whisker = zeros(cellNum,4);  %四列分别为detaf_f_raw;deta_f_f_denoised;event_raw;event_filtered;
for i = 1:cellNum
    correlation_whisker(i,1) = corr(whisker_energy_denoised,detaF_F_raw(:,i));
    correlation_whisker(i,2) = corr(whisker_energy_denoised,detaF_F_denoised(:,i));
    correlation_whisker(i,3) = corr(whisker_energy_denoised,Event_raw(:,i));
    correlation_whisker(i,4) = corr(whisker_energy_denoised,Event_filtered(:,i));
end


save([pwd,'\whisker_energy.mat'],'whisker_move','whisker_move_mean',...
    'whisker_move_2p','whisker_move_mean_2p','root','tail','theta',...
    'theta_change','whisker_energy','start_idx_2p','end_idx_2p',...
    'correlation_whisker');
%% shuffle_whisker

% [root,tail,theta] = frequency_tuning(behav, NeuronActivity);
% 
% x_coordinates = tail(:,1);
% y_corrdinates = tail(:,2);
iteration = 1000;
correlation_shuffle_whisker = cell(1,4);
correlation_shuffle_whisker{1} =  zeros(iteration+3,4);
correlation_shuffle_whisker{2} =  zeros(iteration+3,4);
correlation_shuffle_whisker{3} =  zeros(iteration+3,4);
correlation_shuffle_whisker{4} =  zeros(iteration+3,4);
randindex = randi(length(behav_time)-1,[iteration,1]);

for i = 1:cellNum
   
    for n = 1:iteration
        theta_shuffle(:,1)=[theta((randindex(n)+1):end,1);theta(1:randindex(n),1)];
%         theta_smooth_shuffle = smoothdata(theta_shuffle,'gaussian',100);
         theta_change_shuffle  = diff(theta_shuffle);
           theta_change_shuffle = abs(theta_change_shuffle);
          
           theta_change_shuffle = [theta_change_shuffle;theta_change_shuffle(end)];
            theta_change_shuffle = abs(theta_change_shuffle)*FrameRate_behav;
            whisker_energy_shuffle = zeros(size(timestamps));
      
      
        for j = 1:length(min_indices)
            if ~isnan(min_indices(j))
             whisker_energy_shuffle(j) = theta_change_shuffle(min_indices(j));
            else
                whisker_energy_shuffle(j) = 0;
            end
        end
        
        
        whisker_energy_shuffle = whisker_energy_shuffle(start_idx_2p:end_idx_2p);
        
        whisker_energy_denoised_shuffle = smoothdata(whisker_energy_shuffle,'gaussian',20);
        whisker_energy_denoised_shuffle(isnan(whisker_energy_denoised_shuffle)) = 0;
        correlation_shuffle_whisker{1}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_raw(:,i));
        correlation_shuffle_whisker{2}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_denoised(:,i));
        correlation_shuffle_whisker{3}(i,n) = corr(whisker_energy_denoised_shuffle,Event_raw(:,i));
        correlation_shuffle_whisker{4}(i,n) = corr(whisker_energy_denoised_shuffle,Event_filtered(:,i));
  
    end
       
        
        correlation_shuffle_whisker{1}(i,iteration+3) = corr(whisker_energy_denoised,detaF_F_raw(:,i));
        correlation_shuffle_whisker{2}(i,iteration+3) = corr(whisker_energy_denoised,detaF_F_denoised(:,i));
        correlation_shuffle_whisker{3}(i,iteration+3) = corr(whisker_energy_denoised,Event_raw(:,i));
        correlation_shuffle_whisker{4}(i,iteration+3) = corr(whisker_energy_denoised,Event_filtered(:,i)); 
        
        correlation_shuffle_whisker{1}(i,iteration+1) = prctile(correlation_shuffle_whisker{1}(i,1:iteration),95);
        correlation_shuffle_whisker{2}(i,iteration+1) = prctile(correlation_shuffle_whisker{2}(i,1:iteration),95);
        correlation_shuffle_whisker{3}(i,iteration+1) = prctile(correlation_shuffle_whisker{3}(i,1:iteration),95);
        correlation_shuffle_whisker{4}(i,iteration+1) = prctile(correlation_shuffle_whisker{4}(i,1:iteration),95);
        
        correlation_shuffle_whisker{1}(i,iteration+2) = prctile(correlation_shuffle_whisker{1}(i,1:iteration),99);
        correlation_shuffle_whisker{2}(i,iteration+2) = prctile(correlation_shuffle_whisker{2}(i,1:iteration),99);
        correlation_shuffle_whisker{3}(i,iteration+2) = prctile(correlation_shuffle_whisker{3}(i,1:iteration),99);
        correlation_shuffle_whisker{4}(i,iteration+2) = prctile(correlation_shuffle_whisker{4}(i,1:iteration),99);
        disp(['cell ',num2str(i),' has been shuffled']);
end
Tuning99_whisker = [];
Tuning95_whisker = [];
for i = 1:cellNum
    if correlation_shuffle_whisker{2}(i,iteration+3) >= correlation_shuffle_whisker{2}(i,iteration+2)
        Tuning99_whisker = [Tuning99_whisker;i];
    elseif correlation_shuffle_whisker{2}(i,iteration+3) >= correlation_shuffle_whisker{2}(i,iteration+1)
        Tuning95_whisker = [Tuning95_whisker;i];
    end
end
Tuninglist_95= [Tuning99_whisker;Tuning95_whisker];
Tuninglist_99 = Tuning99_whisker;
 save([pwd,'\correlation_shuffle_whisker_1000.mat'],'correlation_shuffle_whisker','Tuninglist_95','Tuninglist_99');
 

%% Plot
cell_list = Tuninglist_95;    
load([pwd,'\Paw_movement.mat']);
figure
 set(gcf,'position',[50 50 600 100])
plot(Paw_movement_denoised)
saveas(gcf,[pwd, '\Paw_energy.jpg']);

% cell_list = 1:1:NeuronActivity.CellNum;    
% new_folder = 'CellFigure_1000_95';
new_folder = 'CellFigure_95';
mkdir ('method2',new_folder)
for i = 1:length(cell_list)
     
    clf
    set(gcf,'position',[50 50 600 800])
%     subplot(10,1,1)
%     plot(1:length(x_coordinates),x_coordinates);
%     title(['cell: ',num2str(cell_list(i))]);
%     subplot(10,1,2)
%     plot(1:length(theta),theta);
%     
%    
%     subplot(10,1,4)
%     plot(1:length(theta_change),theta_change);
    subplot(6,1,1)
    plot(1:length(whisker_energy),whisker_energy);
    title('whisker_energy')
    subplot(6,1,2)
    plot(1:length(whisker_energy_denoised),whisker_energy_denoised);
    title('whisker_energy_denoised')
    subplot(6,1,3)
    plot(1:length(NeuronActivity.detaF_F_raw(:,cell_list(i))),NeuronActivity.detaF_F_raw(:,cell_list(i)));
     title('detaF_F_raw')
    subplot(6,1,4)
    plot(1:length(NeuronActivity.detaF_F_denoised(:,cell_list(i))),NeuronActivity.detaF_F_denoised(:,cell_list(i)));
      title('detaF_F_denoised')
    subplot(6,1,5)
    plot(1:length(pawX_change),pawX_change);
     title('paw movement')
    subplot(6,1,6)
    plot(1:length(Paw_movement_denoised),Paw_movement_denoised);
     title('paw movement denoised')
    % 
% 
    hold off
  
     % save figure
     saveas(gcf,[pwd, '\method2\',new_folder,'\','cell', num2str(cell_list(i)),'.jpg'])
end


>>>>>>> 342f783 (Include MINI2P_toolbox as a regular foloder)
