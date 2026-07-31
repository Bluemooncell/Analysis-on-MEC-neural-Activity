
%
clear;
addpath(genpath('D:\code\whisker\automatic'));
path = pwd;
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\whisker_energy.mat']);
% load([pwd,'\MiceVideo1\MiceVideo1\behav.mat']);
% behav_time = behav.time;
half_length = 0.5*length(whisker_energy);

%% total
cellNum = NeuronActivity.CellNum;
detaF_F_denoised = NeuronActivity.detaF_F_denoised;
detaF_F_raw = NeuronActivity.detaF_F_raw;
Event_raw = NeuronActivity.Event_raw_exp2;
Event_filtered = NeuronActivity.Event_filtered_exp2;
correlation = zeros(cellNum,4);  %detaf_f_raw;deta_f_f_denoised;event_raw;event_filtered;
for i = 1:cellNum
    correlation(i,1) = corr(whisker_energy_denoised,detaF_F_raw(:,i));
    correlation(i,2) = corr(whisker_energy_denoised,detaF_F_denoised(:,i));
    correlation(i,3) = corr(whisker_energy_denoised,Event_raw(:,i));
    correlation(i,4) = corr(whisker_energy_denoised,Event_filtered(:,i));
 
end
%% first half
timestamps_1 = NeuronActivity.timestamps(1:half_length);

whisker_movement_1 = whisker_energy_denoised(1:half_length,:);
detaF_F_denoised_1 = NeuronActivity.detaF_F_denoised(1:half_length,:);
detaF_F_raw_1 = NeuronActivity.detaF_F_raw(1:half_length,:);
Event_raw_exp2_1 = NeuronActivity.Event_raw_exp2(1:half_length,:);
Event_filtered_exp2_1 = NeuronActivity.Event_filtered_exp2(1:half_length,:);
%% second half
timestamps_2 = NeuronActivity.timestamps(half_length+1:end);

whisker_movement_2 = whisker_energy_denoised(half_length+1:end,:);
detaF_F_denoised_2 = NeuronActivity.detaF_F_denoised(half_length+1:end,:);
detaF_F_raw_2 = NeuronActivity.detaF_F_raw(half_length+1:end,:);
Event_raw_exp2_2 = NeuronActivity.Event_raw_exp2(half_length+1:end,:);
Event_filtered_exp2_2 = NeuronActivity.Event_filtered_exp2(half_length+1:end,:);
%% first half
timestamps = timestamps_1;
detaF_F_denoised = detaF_F_denoised_1;
detaF_F_raw = detaF_F_raw_1;
Event_raw = Event_raw_exp2_1;
Event_filtered = Event_filtered_exp2_1;
whisker_movement = whisker_movement_1;

cellNum = NeuronActivity.CellNum;

iteration = 1000;
correlation_shuffle = cell(1,4);
correlation_shuffle{1} =  zeros(cellNum,iteration+3);
correlation_shuffle{2} =  zeros(cellNum,iteration+3);
correlation_shuffle{3} =  zeros(cellNum,iteration+3);
correlation_shuffle{4} =  zeros(cellNum,iteration+3);
randindex = randi(length(timestamps)-1,[iteration,1]);
% min_indices = zeros(size(timestamps));
% for ii = 1:length(timestamps)  
%             diffs = behav_time - timestamps(ii);     
%             [~, min_index] = min(abs(diffs));  
%             min_indices(ii) = min_index;  
% end

for i = 1:cellNum
     
    for n = 1:iteration
       whisker_energy_denoised_shuffle=[whisker_movement((randindex(n)+1):end,1);whisker_movement(1:randindex(n),1)];
%         theta_smooth_shuffle = smoothdata(theta_shuffle,'gaussian',100);
%          theta_change_shuffle  = diff(theta_smooth_shuffle);
%       
%         whisker_energy_shuffle = zeros(size(timestamps));
%         theta_change_shuffle = abs(theta_change_shuffle);
%       
%         for j = 1:length(min_indices)-1
%              whisker_energy_shuffle(j) = sum(theta_change_shuffle(min_indices(j):(min_indices(j+1)-1)))/(min_indices(j+1)-min_indices(j));
%         end
%         
%         whisker_energy_shuffle(end) = whisker_energy_shuffle(end-1);
%         whisker_energy_denoised_shuffle = smoothdata(whisker_energy_shuffle,'gaussian',10);
        
        correlation_shuffle{1}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_raw(:,i));
        correlation_shuffle{2}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_denoised(:,i));
        correlation_shuffle{3}(i,n) = corr(whisker_energy_denoised_shuffle,Event_raw(:,i));
        correlation_shuffle{4}(i,n) = corr(whisker_energy_denoised_shuffle,Event_filtered(:,i));
  
    end
       
        
        correlation_shuffle{1}(i,iteration+3) = corr(whisker_movement,detaF_F_raw(:,i));
        correlation_shuffle{2}(i,iteration+3) = corr(whisker_movement,detaF_F_denoised(:,i));
        correlation_shuffle{3}(i,iteration+3) = corr(whisker_movement,Event_raw(:,i));
        correlation_shuffle{4}(i,iteration+3) = corr(whisker_movement,Event_filtered(:,i)); 
        
        correlation_shuffle{1}(i,iteration+1) = prctile(correlation_shuffle{1}(i,1:iteration),95);
        correlation_shuffle{2}(i,iteration+1) = prctile(correlation_shuffle{2}(i,1:iteration),95);
        correlation_shuffle{3}(i,iteration+1) = prctile(correlation_shuffle{3}(i,1:iteration),95);
        correlation_shuffle{4}(i,iteration+1) = prctile(correlation_shuffle{4}(i,1:iteration),95);
        
        correlation_shuffle{1}(i,iteration+2) = prctile(correlation_shuffle{1}(i,1:iteration),99);
        correlation_shuffle{2}(i,iteration+2) = prctile(correlation_shuffle{2}(i,1:iteration),99);
        correlation_shuffle{3}(i,iteration+2) = prctile(correlation_shuffle{3}(i,1:iteration),99);
        correlation_shuffle{4}(i,iteration+2) = prctile(correlation_shuffle{4}(i,1:iteration),99);
        disp(['cell ',num2str(i),' has been shuffled']);
end

%stimulation
Tuning95 = [];
Tuning99 = [];

for i = 1:cellNum
    if correlation_shuffle{2}(i,iteration+3) >= correlation_shuffle{2}(i,iteration+2)
        Tuning99 = [Tuning99;i];
    elseif correlation_shuffle{2}(i,iteration+3) >= correlation_shuffle{2}(i,iteration+1)
        Tuning95 = [Tuning95;i];
    end
end
Tuninglist_95_stimu = [Tuning99;Tuning95];
Tuninglist_99_stimu = Tuning99;
save([pwd,'\stability_thre\correlation_shuffle_1000_firsthalf.mat'],'correlation_shuffle','Tuninglist_95_stimu','Tuninglist_99_stimu');

list_1 = Tuninglist_95_stimu;
correlation_shuffle_1 = correlation_shuffle;
%% second half
timestamps = timestamps_2;
detaF_F_denoised = detaF_F_denoised_2;
detaF_F_raw = detaF_F_raw_2;
Event_raw = Event_raw_exp2_2;
Event_filtered = Event_filtered_exp2_2;
whisker_movement = whisker_movement_2;

cellNum = NeuronActivity.CellNum;

iteration = 1000;
correlation_shuffle = cell(1,4);
correlation_shuffle{1} =  zeros(cellNum,iteration+3);
correlation_shuffle{2} =  zeros(cellNum,iteration+3);
correlation_shuffle{3} =  zeros(cellNum,iteration+3);
correlation_shuffle{4} =  zeros(cellNum,iteration+3);
randindex = randi(length(timestamps)-1,[iteration,1]);
% min_indices = zeros(size(timestamps));
% for ii = 1:length(timestamps)  
%             diffs = behav_time - timestamps(ii);     
%             [~, min_index] = min(abs(diffs));  
%             min_indices(ii) = min_index;  
% end

for i = 1:cellNum
     
    for n = 1:iteration
       whisker_energy_denoised_shuffle=[whisker_movement((randindex(n)+1):end,1);whisker_movement(1:randindex(n),1)];
%         theta_smooth_shuffle = smoothdata(theta_shuffle,'gaussian',100);
%          theta_change_shuffle  = diff(theta_smooth_shuffle);
%       
%         whisker_energy_shuffle = zeros(size(timestamps));
%         theta_change_shuffle = abs(theta_change_shuffle);
%       
%         for j = 1:length(min_indices)-1
%              whisker_energy_shuffle(j) = sum(theta_change_shuffle(min_indices(j):(min_indices(j+1)-1)))/(min_indices(j+1)-min_indices(j));
%         end
%         
%         whisker_energy_shuffle(end) = whisker_energy_shuffle(end-1);
%         whisker_energy_denoised_shuffle = smoothdata(whisker_energy_shuffle,'gaussian',10);
        
        correlation_shuffle{1}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_raw(:,i));
        correlation_shuffle{2}(i,n) = corr(whisker_energy_denoised_shuffle,detaF_F_denoised(:,i));
        correlation_shuffle{3}(i,n) = corr(whisker_energy_denoised_shuffle,Event_raw(:,i));
        correlation_shuffle{4}(i,n) = corr(whisker_energy_denoised_shuffle,Event_filtered(:,i));
  
    end
       
        
        correlation_shuffle{1}(i,iteration+3) = corr(whisker_movement,detaF_F_raw(:,i));
        correlation_shuffle{2}(i,iteration+3) = corr(whisker_movement,detaF_F_denoised(:,i));
        correlation_shuffle{3}(i,iteration+3) = corr(whisker_movement,Event_raw(:,i));
        correlation_shuffle{4}(i,iteration+3) = corr(whisker_movement,Event_filtered(:,i)); 
        
        correlation_shuffle{1}(i,iteration+1) = prctile(correlation_shuffle{1}(i,1:iteration),95);
        correlation_shuffle{2}(i,iteration+1) = prctile(correlation_shuffle{2}(i,1:iteration),95);
        correlation_shuffle{3}(i,iteration+1) = prctile(correlation_shuffle{3}(i,1:iteration),95);
        correlation_shuffle{4}(i,iteration+1) = prctile(correlation_shuffle{4}(i,1:iteration),95);
        
        correlation_shuffle{1}(i,iteration+2) = prctile(correlation_shuffle{1}(i,1:iteration),99);
        correlation_shuffle{2}(i,iteration+2) = prctile(correlation_shuffle{2}(i,1:iteration),99);
        correlation_shuffle{3}(i,iteration+2) = prctile(correlation_shuffle{3}(i,1:iteration),99);
        correlation_shuffle{4}(i,iteration+2) = prctile(correlation_shuffle{4}(i,1:iteration),99);
        disp(['cell ',num2str(i),' has been shuffled']);
end

%stimulation
Tuning95 = [];
Tuning99 = [];

for i = 1:cellNum
    if correlation_shuffle{2}(i,iteration+3) >= correlation_shuffle{2}(i,iteration+2)
        Tuning99 = [Tuning99;i];
    elseif correlation_shuffle{2}(i,iteration+3) >= correlation_shuffle{2}(i,iteration+1)
        Tuning95 = [Tuning95;i];
    end
end
Tuninglist_95_stimu = [Tuning99;Tuning95];
Tuninglist_99_stimu = Tuning99;
save([pwd,'\stability_thre\correlation_shuffle_1000_secondhalf.mat'],'correlation_shuffle','Tuninglist_95_stimu','Tuninglist_99_stimu');

list_2 = Tuninglist_95_stimu;
correlation_shuffle_2 = correlation_shuffle;
%%
intra_overlaplist = intersect(list_1,list_2);
intra_overlap = zeros(length(intra_overlaplist),7);
%4:7 为detaf_f_raw;deta_f_f_denoised;event_raw;event_filtered;
for i = 1:length(intra_overlaplist)
    intra_overlap(i,1) = intra_overlaplist(i);
    intra_overlap(i,2) = correlation_shuffle_1{2}(intra_overlaplist(i),1003);
    intra_overlap(i,3) = correlation_shuffle_2{2}(intra_overlaplist(i),1003);
     intra_overlap(i,4) = correlation(intra_overlaplist(i),1);
      intra_overlap(i,5) = correlation(intra_overlaplist(i),2);
       intra_overlap(i,6) = correlation(intra_overlaplist(i),3);
        intra_overlap(i,7) = correlation(intra_overlaplist(i),4);
end
    
save([pwd,'\stability_thre\deltaFdenoised_shuffle_intraoverlap.mat'],'correlation','intra_overlap');

%% plot
new_folder = 'CellFigure_95_intrasessionoverlap';
% new_folder = 'CellFigure_all';
mkdir ('stability_thre',new_folder)
for i = 1:length(intra_overlaplist)
     
    clf
    set(gcf,'position',[50 50 1200 800])
    
    subplot(6,2,1)
    plot(1:half_length,detaF_F_raw_1(:,intra_overlaplist(i)));
    title(['cell: ',num2str(intra_overlaplist(i)),' 1 st']);
     subplot(6,2,3)
    plot(1:half_length,detaF_F_denoised_1(:,intra_overlaplist(i)));
     title('denoised delta F/F');
   subplot(6,2,5)
    plot(1:half_length,Event_raw_exp2_1(:,intra_overlaplist(i)));
     title('raw event');
     subplot(6,2,7)
    plot(1:half_length,Event_filtered_exp2_1(:,intra_overlaplist(i)));
    title('filtered event');
      subplot(6,2,9)
    plot(1:half_length,whisker_energy(1:half_length));
     title('raw whisker_energy');
    subplot(6,2,11)
    plot(1:half_length,whisker_movement_1);
     title('denoised whisker_energy');
    
    
    subplot(6,2,2)
    plot(1:half_length,detaF_F_raw_2(:,intra_overlaplist(i)));
    title('2nd raw delta F/F');
    subplot(6,2,4)
    plot(1:half_length,detaF_F_denoised_2(:,intra_overlaplist(i)));
    title('denoised delta F/F');
   subplot(6,2,6)
    plot(1:half_length,Event_raw_exp2_2(:,intra_overlaplist(i)));
    title('raw event');
    subplot(6,2,8)
    plot(1:half_length,Event_filtered_exp2_2(:,intra_overlaplist(i)));
    title('filtered event');
      subplot(6,2,10)
    plot(1:half_length,whisker_energy(half_length+1:end));
     title('raw whisker_energy');
    subplot(6,2,12)
    plot(1:half_length,whisker_movement_2);
     title('denoised whisker_energy');
    
% 
    hold off
  
%     % save figure
    saveas(gcf,[pwd, '\stability_thre\',new_folder,'\','cell', num2str(intra_overlaplist(i))],'jpg')
end


