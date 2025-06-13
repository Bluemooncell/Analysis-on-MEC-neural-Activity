<<<<<<< HEAD
%% shuffle method 1 Post-pre/Post+pre

clear
Pre_inter = 50;
Post_inter = 50;

new_folder = sprintf('shuffle_Event_pre%d_post%d', Pre_inter, Post_inter);
mkdir(new_folder);
        
load([pwd, '\method2\NeuronActivity.mat']);
% load([pwd,'\stimu_idx_2p.mat']);

% for combined trial
load([pwd,'\stimu_idx_2p_all.mat']);
stimu_idx_2p = stimu_idx_2p_all;

% NeuronActivity.Event_filtered_exp2(isnan(NeuronActivity.Event_filtered_exp2)) = 0;
% spike = logical(NeuronActivity.Event_filtered_exp2);
% 


NeuronActivity.detaF_F_denoised(isnan(NeuronActivity.detaF_F_denoised)) = 0;
spike = NeuronActivity.detaF_F_denoised;

stimu_time_start = stimu_idx_2p(:,1);
stimu_time_end = stimu_idx_2p(:,3);

sti_num = size(stimu_idx_2p,1);
num_trials = sti_num; 
cellNum = size(spike,2);
experiment_end = stimu_time_end(end) + 55; 
if experiment_end > size(spike,1)
    experiment_end = size(spike,1)
end
FrameRate = 9;


iteration = 1000; 

FR_post_all = cell(cellNum,2);
Index_shuffle = zeros(cellNum, 1005);

% **True FR_post FR_pre**
for i = 1:cellNum
    FR_post = zeros(num_trials,1);
    FR_pre = zeros(num_trials,1);
    
    for j = 1:sti_num
        % FR_post
        temp = spike(stimu_time_start(j):stimu_time_start(j)+Post_inter, i);
        FR_post(j) = sum(temp) / Post_inter * FrameRate ;
        
        %  FR_pre
        
        temp = spike(stimu_time_start(j)-Pre_inter:stimu_time_start(j), i);
        FR_pre(j) = sum(temp) / Pre_inter  * FrameRate;
        
    end
    
    % Index_true
    Index_true = (mean(FR_post) - mean(FR_pre)) / (mean(FR_post) + mean(FR_pre));
    
    % 
    FR_post_all{i,1} = FR_post;
    FR_post_all{i,2} = FR_pre;
    Index_shuffle(i, iteration+5) = Index_true;
end

% ** shuffle**

total_frames = size(spike,1); % 总帧数
mininterval_frame = 50;
for i = 1:cellNum
     spike_temp = NeuronActivity.detaF_F_denoised(:,i);
    for n = 1:iteration
           
        FR_post = zeros(num_trials,1);
        FR_pre = zeros(num_trials,1);
         
     for j = 1:sti_num
          xmin = mininterval_frame;
         xmax = size(spike,1)-mininterval_frame;
         shift_frame = round(xmin+rand(1,1)*(xmax-xmin));  
         spike_shuffle = circshift(spike_temp,shift_frame);
                   
        temp = spike_shuffle(stimu_time_start(j):stimu_time_start(j)+Post_inter);
        FR_post(j) = sum(temp) / Post_inter  * FrameRate ;
        

        
        temp = spike_shuffle(stimu_time_start(j)-Pre_inter:stimu_time_start(j));
        FR_pre(j) = sum(temp) / Pre_inter  * FrameRate;
        
    end
        
        % shuffle index
        Index = (mean(FR_post) - mean(FR_pre)) / (mean(FR_post) + mean(FR_pre));
        Index_shuffle(i, n) = Index;
    end
    
   
    Index_shuffle(i, iteration+1) = prctile(Index_shuffle(i, 1:iteration), 95);
    Index_shuffle(i, iteration+2) = prctile(Index_shuffle(i, 1:iteration), 99);
     Index_shuffle(i,iteration+3) = prctile(Index_shuffle(i,1:iteration),5);
    Index_shuffle(i,iteration+4) = prctile(Index_shuffle(i,1:iteration),1);
    disp(['Cell ', num2str(i), ' has been shuffled']);
end

% **identift neurons**
pos_95list =[];
pos_99list = [];
neg_95list = [];
neg_99list = [];

for j = 1:cellNum
    if Index_shuffle(j,iteration+5) > Index_shuffle(j,iteration+2)
        pos_99list = [pos_99list;j];
    elseif Index_shuffle(j,iteration+5) > Index_shuffle(j,iteration+1)
        pos_95list = [pos_95list;j];
    end
    if Index_shuffle(j,iteration+5) < Index_shuffle(j,iteration+4)
        neg_99list = [neg_99list;j];
    elseif Index_shuffle(j,iteration+5) > Index_shuffle(j,iteration+3)
        neg_95list = [neg_95list;j];
    end
    
end

save([pwd,'\',new_folder,'\Index_Shuffle.mat'],'Index_shuffle','pos_99list','pos_95list','neg_99list',...,
    'neg_95list','Pre_inter','Post_inter');

=======
%% shuffle method 1 Post-pre/Post+pre

clear
Pre_inter = 50;
Post_inter = 50;

new_folder = sprintf('shuffle_Event_pre%d_post%d', Pre_inter, Post_inter);
mkdir(new_folder);
        
load([pwd, '\method2\NeuronActivity.mat']);
% load([pwd,'\stimu_idx_2p.mat']);

% for combined trial
load([pwd,'\stimu_idx_2p_all.mat']);
stimu_idx_2p = stimu_idx_2p_all;

% NeuronActivity.Event_filtered_exp2(isnan(NeuronActivity.Event_filtered_exp2)) = 0;
% spike = logical(NeuronActivity.Event_filtered_exp2);
% 


NeuronActivity.detaF_F_denoised(isnan(NeuronActivity.detaF_F_denoised)) = 0;
spike = NeuronActivity.detaF_F_denoised;

stimu_time_start = stimu_idx_2p(:,1);
stimu_time_end = stimu_idx_2p(:,3);

sti_num = size(stimu_idx_2p,1);
num_trials = sti_num; 
cellNum = size(spike,2);
experiment_end = stimu_time_end(end) + 55; 
if experiment_end > size(spike,1)
    experiment_end = size(spike,1)
end
FrameRate = 9;


iteration = 1000; 

FR_post_all = cell(cellNum,2);
Index_shuffle = zeros(cellNum, 1005);

% **True FR_post FR_pre**
for i = 1:cellNum
    FR_post = zeros(num_trials,1);
    FR_pre = zeros(num_trials,1);
    
    for j = 1:sti_num
        % FR_post
        temp = spike(stimu_time_start(j):stimu_time_start(j)+Post_inter, i);
        FR_post(j) = sum(temp) / Post_inter * FrameRate ;
        
        %  FR_pre
        
        temp = spike(stimu_time_start(j)-Pre_inter:stimu_time_start(j), i);
        FR_pre(j) = sum(temp) / Pre_inter  * FrameRate;
        
    end
    
    % Index_true
    Index_true = (mean(FR_post) - mean(FR_pre)) / (mean(FR_post) + mean(FR_pre));
    
    % 
    FR_post_all{i,1} = FR_post;
    FR_post_all{i,2} = FR_pre;
    Index_shuffle(i, iteration+5) = Index_true;
end

% ** shuffle**

total_frames = size(spike,1); % 总帧数
mininterval_frame = 50;
for i = 1:cellNum
     spike_temp = NeuronActivity.detaF_F_denoised(:,i);
    for n = 1:iteration
           
        FR_post = zeros(num_trials,1);
        FR_pre = zeros(num_trials,1);
         
     for j = 1:sti_num
          xmin = mininterval_frame;
         xmax = size(spike,1)-mininterval_frame;
         shift_frame = round(xmin+rand(1,1)*(xmax-xmin));  
         spike_shuffle = circshift(spike_temp,shift_frame);
                   
        temp = spike_shuffle(stimu_time_start(j):stimu_time_start(j)+Post_inter);
        FR_post(j) = sum(temp) / Post_inter  * FrameRate ;
        

        
        temp = spike_shuffle(stimu_time_start(j)-Pre_inter:stimu_time_start(j));
        FR_pre(j) = sum(temp) / Pre_inter  * FrameRate;
        
    end
        
        % shuffle index
        Index = (mean(FR_post) - mean(FR_pre)) / (mean(FR_post) + mean(FR_pre));
        Index_shuffle(i, n) = Index;
    end
    
   
    Index_shuffle(i, iteration+1) = prctile(Index_shuffle(i, 1:iteration), 95);
    Index_shuffle(i, iteration+2) = prctile(Index_shuffle(i, 1:iteration), 99);
     Index_shuffle(i,iteration+3) = prctile(Index_shuffle(i,1:iteration),5);
    Index_shuffle(i,iteration+4) = prctile(Index_shuffle(i,1:iteration),1);
    disp(['Cell ', num2str(i), ' has been shuffled']);
end

% **identift neurons**
pos_95list =[];
pos_99list = [];
neg_95list = [];
neg_99list = [];

for j = 1:cellNum
    if Index_shuffle(j,iteration+5) > Index_shuffle(j,iteration+2)
        pos_99list = [pos_99list;j];
    elseif Index_shuffle(j,iteration+5) > Index_shuffle(j,iteration+1)
        pos_95list = [pos_95list;j];
    end
    if Index_shuffle(j,iteration+5) < Index_shuffle(j,iteration+4)
        neg_99list = [neg_99list;j];
    elseif Index_shuffle(j,iteration+5) > Index_shuffle(j,iteration+3)
        neg_95list = [neg_95list;j];
    end
    
end

save([pwd,'\',new_folder,'\Index_Shuffle.mat'],'Index_shuffle','pos_99list','pos_95list','neg_99list',...,
    'neg_95list','Pre_inter','Post_inter');

>>>>>>> 342f783 (Include MINI2P_toolbox as a regular foloder)
