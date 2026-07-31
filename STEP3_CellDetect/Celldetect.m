% This script is used to select cells which pass shuffle
% The input is a result from "shuffle_60_session_ratemap_new",
% which contains Gridness_shuffle、borderScore_shuffle and MVL_shuffle.

%Output(for each cell type):  [N x 9] matrix
% row1:number of mouse 
% row2 number of baseline(1 or 2)
% row3 number of cell
% row4 intrastability of cell
% row5 Gridness/borderScore/MVL
% row6 information content( the calculation is different for Grid/Border
% and HD)
% row7 peak rate
% row8 mean rate
% row9 information rate(the calculation is different for Grid/Border)
% row10 
% mean rate of grid and HD cell are calculated in the same way.
%                                          Created by TJY,2023-2-10
%                                          Modified by TJY,2023-4-22
%                                          Modified by TJY,2023-9-12


clear;
addpath(genpath('D:\code\Tools'));
addpath(genpath('D:\code\MINI2P_toolbox'));
addpath(genpath('D:\code\MINI2P_toolbox\Analysis'));

load([pwd,'\method2\shuffle_ratemap_new3\shuffle_ratemap_new2.mat']) 
load([pwd,'\method2\NeuronActivity.mat']);
mkdir('HD-data')
mkdir('Grid-data');
mkdir('Border-data');
mkdir('Spatial-data');
%% change this!!!!!!!!!!!!!!!!!!!!!!!!!
mouseNum = 349;
baselineNum = 2;

threshold_Grid = 0.3;
threshold_Border = 0.3;
threshold_HD = 0.5;
threshold_Spatial = 0.5;
%% Get index of grid cells which pass 95 and 99 shuffle
[a,b] = size(Gridness_shuffle);
Gridlist_95 =[];
Gridlist_99 = [];
for i = 1:a
    if Gridness_shuffle(i,1003) > Gridness_shuffle(i,1002)
        Gridlist_99 = [Gridlist_99;i];
    elseif Gridness_shuffle(i,1003) > Gridness_shuffle(i,1001)
        Gridlist_95 = [Gridlist_95;i];
    end
end
GridNum_95 = length(Gridlist_95);
GridNum_99 = length(Gridlist_99);

%% Get index of border cells which pass 95 and 99 shuffle
[c,d] = size(borderScore_shuffle);
Borderlist_95 =[];
Borderlist_99 = [];
for i = 1:c
    if borderScore_shuffle(i,1003) > borderScore_shuffle(i,1002)
        Borderlist_99 = [Borderlist_99;i];
  
    elseif borderScore_shuffle(i,1003) > borderScore_shuffle(i,1001)
        Borderlist_95 = [Borderlist_95;i];
    end
end
BorderNum_95 = length(Borderlist_95);
BorderNum_99 = length(Borderlist_99);

%% Get index of head-direction cells which pass 95 and 99 shuffle
[e,f] = size(MVL_shuffle);
HDlist_95 =[];
HDlist_99 = [];
for i = 1:e
    if MVL_shuffle(i,1003) > MVL_shuffle(i,1002)
        HDlist_99 = [HDlist_99;i];
  
    elseif MVL_shuffle(i,1003) > MVL_shuffle(i,1001)
        HDlist_95 = [HDlist_95;i];
    end
end
HDNum_95 = length(HDlist_95);
HDNum_99 = length(HDlist_99);

%% Get index of Spatial cells which pass 95 and 99 shuffle
[a,b] = size(information_shuffle_content);
Spatiallist_95 =[];
Spatiallist_99 = [];
for i = 1:a
    if information_shuffle_content(i,1003) > information_shuffle_content(i,1002)
        Spatiallist_99 = [Spatiallist_99;i];
    elseif information_shuffle_content(i,1003) > information_shuffle_content(i,1001)
        Spatiallist_95 = [Spatiallist_95;i];
    end
end
SpatialNum_95 = length(Spatiallist_95);
SpatialNum_99 = length(Spatiallist_99);



%% cell data for baseline

% calculate mean rate (consider uncontinuous data)
time = 0;
for i = 1:length(NeuronActivity.timestamps)-1
    if NeuronActivity.timestamps(i+1) - NeuronActivity.timestamps(i) < 1
        time = time + NeuronActivity.timestamps(i+1) - NeuronActivity.timestamps(i);
    end
end

spikeNum = zeros(NeuronActivity.CellNum,1);
meanRate = zeros(NeuronActivity.CellNum,1);
for i = 1:NeuronActivity.CellNum
    spikeNum(i) = NeuronActivity.Event_count(i);
    meanRate(i) = spikeNum(i)/time;
end
stability = zeros(NeuronActivity.CellNum,1);
for ii = 1:NeuronActivity.CellNum
      spike_pos = [];
      behav_pos =[];
     if ~isempty(Ratemap.Spike{1,ii}) && ~isempty(Ratemap.Position{1,ii})
       spike_pos = Ratemap.Spike{1,ii};
       behav_pos = Ratemap.Position{1,ii};
%     
       % Rate Map (power)
        smooth_space = 2.5;
        bin_space = 2.5;
        Mintime = 0.1;
         Limits = [0 80 0 80];
    
    % calculate Activity map for each half session
        half_1_start = 1;
        half_1_end = floor(length(behav_pos) * 0.5);
        behav_pos_1 = [];
        behav_pos_1(:,1) = behav_pos(1:half_1_end,1);
        behav_pos_1(:,2) = behav_pos(1:half_1_end,2); % x
        behav_pos_1(:,3) = behav_pos(1:half_1_end,3); % y
        behav_pos_1(:,4) = behav_pos(1:half_1_end,4);% likelyhood
        behav_pos_1(:,5) = behav_pos(1:half_1_end,5);
    
        spike_time = spike_pos(:,1);
        behav_time_1 = behav_pos_1(:,1);
        time_interval = abs(spike_time - behav_time_1(end));
        timeinter_min = min(time_interval);
        [row, col]=find(time_interval==timeinter_min);
        spike_end_1 = row - 1;
        
        spike_pos_1 = [];
        spike_pos_1(:,1) = spike_pos(1:spike_end_1,1);
        spike_pos_1(:,2) = spike_pos(1:spike_end_1,2);
        spike_pos_1(:,3) = spike_pos(1:spike_end_1,3);
        spike_pos_1(:,4) = spike_pos(1:spike_end_1,4);
     
        ActivityMap_1 = SpatialTuning_BNT.map(behav_pos_1,spike_pos_1(:,1),'smooth',smooth_space,'binWidth',bin_space,'minTime',Mintime,'limits',Limits);
    
        half_2_start = half_1_end + 1;
        behav_pos_2 = [];
        behav_pos_2(:,1) = behav_pos(half_2_start:end,1);
        behav_pos_2(:,2) = behav_pos(half_2_start:end,2); % x
        behav_pos_2(:,3) = behav_pos(half_2_start:end,3); % y
        behav_pos_2(:,4) = behav_pos(half_2_start:end,4);% likelyhood
        behav_pos_2(:,5) = behav_pos(half_2_start:end,5);
    
    
        spike_start_2 = spike_end_1 + 1 ;
        spike_pos_2 = [];
        spike_pos_2(:,1) = spike_pos(spike_end_1 + 1:end,1);
        spike_pos_2(:,2) = spike_pos(spike_end_1 + 1:end,2);
        spike_pos_2(:,3) = spike_pos(spike_end_1 + 1:end,3);
        spike_pos_2(:,4) = spike_pos(spike_end_1 + 1:end,4);
       
        ActivityMap_2 = SpatialTuning_BNT.map(behav_pos_2,spike_pos_2(:,1),'smooth',smooth_space,'binWidth',bin_space,'minTime',Mintime,'limits',Limits);
        
        % calculate inter-session stability
        map1 = ActivityMap_1.z;
        map2 = ActivityMap_2.z;
        if ~isempty(map1) && ~isempty(map2)
            stability(ii) = analyses.spatialCrossCorrelation(map1,map2);
        else
            stability(ii) = NaN;
        end
        
     else
         stability(ii) = NaN;
     end
end
%% Grid cell
Gridlist = [Gridlist_99;Gridlist_95];


cellNum = [];
intra_stability = [];
Gridness = [];
information_content = [];
information_rate = [];
peak_rate = [];
mean_rate = [];

for j = 1:length(Gridlist)
     if Gridness_shuffle(Gridlist(j),1003) >= 0
        if stability(Gridlist(j)) >= threshold_Grid
           
            cellNum = [cellNum;Gridlist(j)];
            intra_stability = [intra_stability;stability(Gridlist(j))];
            Gridness = [Gridness;Gridness_shuffle(Gridlist(j),1003)];
            information_content = [information_content;information_shuffle_content(Gridlist(j),1003)];
            information_rate= [information_rate;information_shuffle_rate(Gridlist(j),1003)];
            peak_rate = [peak_rate;Ratemap.ActivityMap{1,Gridlist(j)}.peakRate];
            mean_rate = [mean_rate;meanRate(Gridlist(j))];
        end
end
%     
end

intra_baseline_Gridlist = cellNum;
intra_baseline_Grid = zeros(length(intra_baseline_Gridlist),9);
intra_baseline_Grid(:,1) = mouseNum;
intra_baseline_Grid(:,2) = baselineNum;
intra_baseline_Grid(:,3) = cellNum;
intra_baseline_Grid(:,4) = intra_stability;
intra_baseline_Grid(:,5) = Gridness;
intra_baseline_Grid(:,6) = information_content;
intra_baseline_Grid(:,7) = peak_rate;
intra_baseline_Grid(:,8) = mean_rate;
intra_baseline_Grid(:,9) = information_rate;

 save([pwd,'\Grid-data\intra_baseline_Grid.mat'],'intra_baseline_Grid');
 save([pwd,'\Grid-data\intra_baseline_Gridlist.mat'],'intra_baseline_Gridlist');
 
 %% Border cell
Borderlist = [Borderlist_99;Borderlist_95];



cellNum = [];
intra_stability = [];
borderScore = [];
information_content = [];
peak_rate = [];
mean_rate = [];
information_rate = [];

for j = 1:length(Borderlist)
  
     if stability(Borderlist(j)) >= threshold_Border
           
            cellNum = [cellNum;Borderlist(j)];
            intra_stability = [intra_stability;stability(Borderlist(j))];
            borderScore = [borderScore;borderScore_shuffle(Borderlist(j),1003)];
            information_content = [information_content;information_shuffle_content(Borderlist(j),1003)];
            information_rate= [information_rate;information_shuffle_rate(Borderlist(j),1003)];
            peak_rate = [peak_rate;Ratemap.ActivityMap{1,Borderlist(j)}.peakRate];
            mean_rate = [mean_rate;meanRate(Borderlist(j))];
     end  
end

intra_baseline_Borderlist = cellNum;
intra_baseline_Border = zeros(length(intra_baseline_Borderlist),8);
intra_baseline_Border(:,1) = mouseNum;
intra_baseline_Border(:,2) = baselineNum;
intra_baseline_Border(:,3) = cellNum;
intra_baseline_Border(:,4) = intra_stability;
intra_baseline_Border(:,5) = borderScore;
intra_baseline_Border(:,6) = information_content;
intra_baseline_Border(:,7) = peak_rate;
intra_baseline_Border(:,8) = mean_rate;
intra_baseline_Border(:,9) = information_rate;
% 
% 
 save([pwd,'\Border-data\intra_baseline_Border.mat'],'intra_baseline_Border');
 save([pwd,'\Border-data\intra_baseline_Borderlist.mat'],'intra_baseline_Borderlist');
 
 %% HD cell
HDlist = HDlist_99;
stability_HD = zeros(NeuronActivity.CellNum,1);

sampleTime = mean(diff(Ratemap.Position{1,1}(:,1)));
AngleSmooth = 2;
AngleBinsize=3;
   
for ii = 1:NeuronActivity.CellNum
      spike_pos = [];
      behav_pos =[];
     if ~isempty(Ratemap.Spike{1,ii}) && ~isempty(Ratemap.Position{1,ii})
       spike_pos = Ratemap.Spike{1,ii};
       behav_pos = Ratemap.Position{1,ii};
    
    % calculate tuning curve for each half session
        half_1_start = 1;
        half_1_end = floor(length(behav_pos) * 0.5);
        behav_pos_1 = [];
        behav_pos_1(:,1) = behav_pos(1:half_1_end,1);
        behav_pos_1(:,2) = behav_pos(1:half_1_end,2); % x
        behav_pos_1(:,3) = behav_pos(1:half_1_end,3); % y
        behav_pos_1(:,4) = behav_pos(1:half_1_end,4);% likelyhood
        behav_pos_1(:,5) = behav_pos(1:half_1_end,5);
    
        spike_time = spike_pos(:,1);
        behav_time_1 = behav_pos_1(:,1);
        time_interval = abs(spike_time - behav_time_1(end));
        timeinter_min = min(time_interval);
        [row, col]=find(time_interval==timeinter_min);
        spike_end_1 = row - 1;
        
        spike_pos_1 = [];
        spike_pos_1(:,1) = spike_pos(1:spike_end_1,1);
        spike_pos_1(:,2) = spike_pos(1:spike_end_1,2);
        spike_pos_1(:,3) = spike_pos(1:spike_end_1,3);
        spike_pos_1(:,4) = spike_pos(1:spike_end_1,4);
        spike_pos_1(:,5) = spike_pos(1:spike_end_1,5);
        spike_pos_1(:,6) = spike_pos(1:spike_end_1,6);
        if ~isempty(spike_pos_1)
            turningCurve_1 = SpatialTuning_BNT.turningCurve(spike_pos_1(:,6),behav_pos_1(:,5),sampleTime,'smooth',AngleSmooth,'binWidth',AngleBinsize);
            %         tcStat_1 = SpatialTuning_BNT.tcStatistics(turningCurve{1,i} , AngleBinsize, 49);
            turning1 = turningCurve_1(:,2);
        else
            turning1 = [];
        end
        
      
        half_2_start = half_1_end + 1;
        behav_pos_2 = [];
        behav_pos_2(:,1) = behav_pos(half_2_start:end,1);
        behav_pos_2(:,2) = behav_pos(half_2_start:end,2); % x
        behav_pos_2(:,3) = behav_pos(half_2_start:end,3); % y
        behav_pos_2(:,4) = behav_pos(half_2_start:end,4);% likelyhood
        behav_pos_2(:,5) = behav_pos(half_2_start:end,5);
    
    
        spike_start_2 = spike_end_1 + 1 ;
        spike_pos_2 = [];
        spike_pos_2(:,1) = spike_pos(spike_end_1 + 1:end,1);
        spike_pos_2(:,2) = spike_pos(spike_end_1 + 1:end,2);
        spike_pos_2(:,3) = spike_pos(spike_end_1 + 1:end,3);
        spike_pos_2(:,4) = spike_pos(spike_end_1 + 1:end,4);
        spike_pos_2(:,5) = spike_pos(spike_end_1 + 1:end,5);
        spike_pos_2(:,6) = spike_pos(spike_end_1 + 1:end,6);
     if ~isempty(spike_pos_2) 
        turningCurve_2 = SpatialTuning_BNT.turningCurve(spike_pos_2(:,6),behav_pos_2(:,5),sampleTime,'smooth',AngleSmooth,'binWidth',AngleBinsize);
%         tcStat_1 = SpatialTuning_BNT.tcStatistics(turningCurve{1,i} , AngleBinsize, 49);
        turning2 = turningCurve_2(:,2);
     else
         turning2 = [];
     end
       if ~isempty(turning1) & ~isempty(turning2)
       stability_HD(ii) = corr(turning1,turning2);
       else
           stability_HD(ii) = NaN;
       end
    
     else
         stability_HD(ii) = NaN; 
     end
end


tuningCurve = cell(1,NeuronActivity.CellNum);
tcStat = cell(1,NeuronActivity.CellNum);
information_content_HD = zeros(NeuronActivity.CellNum,1);
information_rate_HD = zeros(NeuronActivity.CellNum,1);
for i = 1:NeuronActivity.CellNum
   spike_pos = Ratemap.Spike{1,i};
   behav_pos = Ratemap.Position{1,i};
              if ~isempty(spike_pos) && ~isempty(behav_pos)
                tuningCurve{i} = SpatialTuning_BNT.turningCurve(spike_pos(:,6),behav_pos(:,5),sampleTime,'smooth',AngleSmooth,'binWidth',AngleBinsize);
                tcStat{i} = SpatialTuning_BNT.tcStatistics(tuningCurve{i},AngleBinsize,50);
                [information_HD,~,~]=analyses.TuningCurveStatsPDF(tuningCurve{i}); 
                information_content_HD(i) = information_HD.content;
                information_rate_HD(i) = information_HD.rate;
                
              end

end


cellNum = [];
intra_stability = [];
MVL = [];
information_content = [];
peak_rate = [];
mean_rate = [];
information_rate = [];

for j = 1:length(HDlist)
  
        if stability_HD(HDlist(j)) >= threshold_HD
            
            cellNum = [cellNum;HDlist(j)];
            intra_stability = [intra_stability;stability_HD(HDlist(j))];
            MVL = [MVL;MVL_shuffle(HDlist(j),1003)];
            information_content = [information_content;information_content_HD(HDlist(j))];
            peak_rate = [peak_rate;tcStat{1,HDlist(j)}.peakRate];
            mean_rate = [mean_rate;meanRate(HDlist(j))];
            information_rate = [information_rate;information_rate_HD(HDlist(j))];
        end
end


intra_baseline_HD99list = cellNum;
intra_baseline_HD99 = zeros(length(intra_baseline_HD99list),9);
intra_baseline_HD99(:,1) = mouseNum;
intra_baseline_HD99(:,2) = baselineNum;
intra_baseline_HD99(:,3) = cellNum;
intra_baseline_HD99(:,4) = intra_stability;
intra_baseline_HD99(:,5) = MVL;
intra_baseline_HD99(:,6) = information_content;
intra_baseline_HD99(:,7) = peak_rate;
intra_baseline_HD99(:,8) = mean_rate;
intra_baseline_HD99(:,9) = information_rate;

 save([pwd,'\HD-data\intra_baseline_HD99.mat'],'intra_baseline_HD99');
 save([pwd,'\HD-data\intra_baseline_HD99list.mat'],'intra_baseline_HD99list');


%% Spatial cell
% Spatiallist = [Spatiallist_99;Spatiallist_95];
Spatiallist = [Spatiallist_99];

cellNum = [];
intra_stability = [];
Spatialness = [];
information_content = [];
information_rate = [];
peak_rate = [];
mean_rate = [];

for j = 1:length(Spatiallist)
        if stability(Spatiallist(j)) >= threshold_Spatial
           
            cellNum = [cellNum;Spatiallist(j)];
            intra_stability = [intra_stability;stability(Spatiallist(j))];
            Spatialness = [Spatialness;information_shuffle_content(Spatiallist(j),1003)];
            information_content = [information_content;information_shuffle_content(Spatiallist(j),1003)];
            information_rate= [information_rate;information_shuffle_rate(Spatiallist(j),1003)];
            peak_rate = [peak_rate;Ratemap.ActivityMap{1,Spatiallist(j)}.peakRate];
            mean_rate = [mean_rate;meanRate(Spatiallist(j))];
        end
%     
end

intra_baseline_Spatiallist = cellNum;
intra_baseline_Spatial = zeros(length(intra_baseline_Spatiallist),9);
intra_baseline_Spatial(:,1) = mouseNum;
intra_baseline_Spatial(:,2) = baselineNum;
intra_baseline_Spatial(:,3) = cellNum;
intra_baseline_Spatial(:,4) = intra_stability;
intra_baseline_Spatial(:,5) = Spatialness;
intra_baseline_Spatial(:,6) = information_content;
intra_baseline_Spatial(:,7) = peak_rate;
intra_baseline_Spatial(:,8) = mean_rate;
intra_baseline_Spatial(:,9) = information_rate;

 save([pwd,'\Spatial-data\intra_baseline_Spatial.mat'],'intra_baseline_Spatial');
 save([pwd,'\Spatial-data\intra_baseline_Spatiallist.mat'],'intra_baseline_Spatiallist');
 

