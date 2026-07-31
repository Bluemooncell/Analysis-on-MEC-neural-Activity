clear
close all
clc
addpath(genpath('D:\code\whisker\automatic'));
addpath(genpath('D:\code\MINI2P_toolbox'));
addpath(genpath('D:\code\Tools'));
addpath(genpath('D:\code\'));
path = pwd;

load([pwd,'\method2\NeuronActivity.mat']);
FrameRate_2p = 1/mean(diff(NeuronActivity.timestamps));

ConvertedData = convertTDMS(0,'MiceVideo2/MiceVideo_Info.tdms');
timestamps = ConvertedData.Data.MeasuredData(4).Data;
date = timestamps{1}(9:10);
for i = 1:length(timestamps)
    t = timestamps{i};
    hour = str2double(t(12:13));
    if t(9:10) ~= date
        hour = hour + 24;
    end
    behav_time(i) = hour*3600 + str2double(t(15:16))*60 + str2double(t(18:23));
end
behav_time = behav_time';
FrameRate_behav = 1/mean(diff(behav_time));

%% 
files = dir('MiceVideo2/MiceVideo/*_filtered.csv');

behav = struct;
behav.time = behav_time;
behav.position = cell(1, 2);
data_all = table();


for i = 1:length(files)
   
    filename = fullfile('MiceVideo2\MiceVideo', files(i).name);
    
   
    opts = detectImportOptions(filename);
    opts.VariableNamesLine = 1;  
    data = readtable(filename, opts);
    
    data(:, 1) = [];
    
   
    data_all = [data_all; data]; 
    
end

for j = 1:2
   
    behav.position{1, j} = [data_all{:, 3*j-2}, data_all{:, 3*j-1}, data_all{:, 3*j}];
end

[root,tail,theta] = frequency_tuning(behav, NeuronActivity);

behav.time = behav_time;
save([pwd,'\MiceVideo2\MiceVideo\behav.mat'],'behav');


x_coordinates = tail(:,1);
y_coordinates = tail(:,2);
% theta_smooth = smoothdata(theta,'gaussian',5);
theta_smooth = smoothdata(theta,'gaussian',100);

theta_change  = diff(theta_smooth);

theta_change  = abs(theta_change);
theta_change  = [theta_change;theta_change(end)];
theta_change = theta_change * FrameRate_behav;
% plot(theta_change)
%%
timestamps = NeuronActivity.timestamps;
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
% for j = 1:length(min_indices)-1
%     whisker_energy(j) = sum(theta_change(min_indices(j):(min_indices(j+1)-1)))/(min_indices(j+1)-min_indices(j));
% end
%whisker_energy(end) = whisker_energy(end-1);
for j = 1:length(min_indices)
     if ~isnan(min_indices(j))
    whisker_energy(j) = theta_change(min_indices(j));
     else
          whisker_energy(j) = NaN;
     end
end


whisker_energy_denoised = smoothdata(whisker_energy,'gaussian',10);
% theta_change = smoothdata(theta_change,'gaussian',5);
% theta_change  = [theta_change;theta_change(end)];
% for j = 1:length(min_indices)-1
%     whisker_energy(j) = sum(theta_change(min_indices(j):(min_indices(j+1)-1)))/(min_indices(j+1)-min_indices(j));
% end
% for j = 1:length(min_indices)
%      if ~isnan(min_indices(j))
%     whisker_energy(j) = theta_change(min_indices(j));
%      else
%           whisker_energy(j) = NaN;
%      end
% end
% 
% whisker_energy_denoised = smoothdata(whisker_energy,'gaussian',20);

%%
whisker_energy_denoised(isnan(whisker_energy_denoised)) = 0;

 set(gcf,'position',[50 50 600 100])
plot(whisker_energy_denoised)
saveas(gcf,[pwd, '\whisker_energy.jpg']);


cellNum = NeuronActivity.CellNum;
detaF_F_denoised = NeuronActivity.detaF_F_denoised;
detaF_F_raw = NeuronActivity.detaF_F_raw;
Event_raw = NeuronActivity.Event_raw_exp2;
Event_filtered = NeuronActivity.Event_filtered_exp2;
correlation_whisker = zeros(cellNum,4);  %detaf_f_raw;deta_f_f_denoised;event_raw;event_filtered;
for i = 1:cellNum
    correlation_whisker(i,1) = corr(whisker_energy_denoised,detaF_F_raw(:,i));
    correlation_whisker(i,2) = corr(whisker_energy_denoised,detaF_F_denoised(:,i));
    correlation_whisker(i,3) = corr(whisker_energy_denoised,Event_raw(:,i));
    correlation_whisker(i,4) = corr(whisker_energy_denoised,Event_filtered(:,i));
end


save([pwd,'\whisker_energy.mat'],'root','tail','theta',...
    'theta_change','whisker_energy','whisker_energy_denoised',...
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
        
        
     
        
        whisker_energy_denoised_shuffle = smoothdata(whisker_energy_shuffle,'gaussian',10);
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
 

%%
cell_list = Tuninglist_95;    
  
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
%     subplot(6,1,5)
%     plot(1:length(pawX_change),pawX_change);
%      title('paw movement')
%     subplot(6,1,6)
%     plot(1:length(Paw_movement_denoised),Paw_movement_denoised);
%      title('paw movement denoised')
%     % 
% 
    hold off
  
     % save figure
     saveas(gcf,[pwd, '\method2\',new_folder,'\','cell', num2str(cell_list(i)),'.jpg'])
end


