
%Input: Ratemap(all cell)  SpeedTunning  isPosSpeedcell
%Output intra_baseline_Speedlist
%       information about intra_baseline_speed cell
% stability is calculated by speedtuning
     
clear all
addpath(genpath('D:\Test_code\Tools'));
addpath(genpath('D:\Test_code\MINI2P_toolbox'));
addpath(genpath('D:\Test_code\MINI2P_toolbox\Analysis'));
mkdir('Speed-data-timebin');
mouseNum = 321;
baselineNum = 2;

load([pwd,'\321-20250311-2\method2\shuffle_ratemap_new3\shuffle_ratemap_new2.mat']);
load([pwd,'\321-20250311-2\method2\speed_tunning_timebin\SpeedTuning.mat']);
load([pwd,'\321-20250311-2\method2\speed_tunning_timebin\SpeedScore.mat']);
load([pwd,'\321-20250311-2\method2\NeuronActivity.mat']);
load([pwd,'\321-20250311-2\MiceVideo1\MiceVideo\behav.mat']);
Speedlist = pos_speedlist_99';
Ratemap = Ratemap;

NeuronActivity = NeuronActivity;
behav = behav;

% num = 0;
% list = [];
% for i = 1:length(list1)
%     if ismember(list2,list1(i))
%         num = num +1
%         list  = [list;list1(i)]
%     end
% end;
stability = zeros(length(Speedlist),2);
stability(:,1) = Speedlist;

timebinning=2; %cm/s
MinSpeed=2.5;
MaxSpeed=18.5;
SpeedRange=MinSpeed:timebinning:MaxSpeed; %cm0
MinSpanTime=10;%second
ShuffleNum=1000;
Shuffling_mininterval=30;
MinEventCount=100;

%% calculate mean rate
 spike_time = NeuronActivity.timestamps;
 behav_time = behav.time;
 time = 0;
    for i = 1:length(spike_time) - 1
        if spike_time(i+1) - spike_time(i) < 1
           time = time + spike_time(i+1) - spike_time(i);
        end
    end
    
spikeNum = zeros(NeuronActivity.CellNum,1);
meanRate = zeros(NeuronActivity.CellNum,1);
for i = 1:NeuronActivity.CellNum
    spikeNum(i) = NeuronActivity.Event_count(i);
    meanRate(i) = spikeNum(i)/time;
end
       
FrameRate = length(spike_time)/time;
SpeedSmooth=round(0.25*FrameRate);
behav_pos = behav.position{1,1};
behav_pos = fillmissing(behav_pos,'linear');
behav_speed = [];
behav_speed = speed2D(behav_pos(:,1), behav_pos(:,2), behav_time); 
          
spike_speed = [];
      for q = 1 : length(spike_time)
           f1 = find(behav_time<spike_time(q));
           t1 = behav_time(max(f1));
           f2 = find(behav_time>=spike_time(q));
           t2 = behav_time(min(f2));
        if spike_time(q) - t1 < t2 - spike_time(q)
           if isempty(f1)
              spike_speed(q) = behav_speed(1);
           else
              spike_speed(q) = behav_speed(max(f1));
           end
        else
           if isempty(f2)
              spike_speed(q) = behav_speed(end);
           else
              spike_speed(q) = behav_speed(min(f2));
           end
        end
      end

      % calculated speed tuning for all the cells
TotalCell = size(NeuronActivity.F_raw_Iscell,2);
FrameRate = length(spike_time)/time;
SpeedSmooth=round(0.25*FrameRate);
SpeedTuning = cell(1,TotalCell);
for i = 1:TotalCell
        Event_raw = NeuronActivity.Event_filtered_exp2(:,i);
        SelectedFrame_raw=find(~isnan(Event_raw(:))); %all the position are select
        SpeedTrain=spike_speed(SelectedFrame_raw);
        %     SpeedTrain_smooth=general.smoothGauss(SpeedTrain,SpeedSmooth);
        SpeedTrain_smooth=SpeedTrain';
        SelectedFrame_filtered=logical((SpeedTrain_smooth>=MinSpeed).*(SpeedTrain_smooth<=MaxSpeed+timebinning));
        SpeedTrain_filtered=SpeedTrain_smooth(SelectedFrame_filtered);
        EventTrain_original=Event_raw(SelectedFrame_raw);
        EventTrain_smooth=general.smoothGauss(EventTrain_original,SpeedSmooth);
        EventTrain_filtered=EventTrain_smooth(SelectedFrame_filtered);
        EventTrain_logical=EventTrain_filtered>0;
        SpeedTuning{i}=SpatialTuning_BNT.SpeedTuningCalcultation(SpeedTrain_filtered,EventTrain_logical,...
            FrameRate,...
            SpeedRange,MinSpanTime,...
        MaxSpeed+timebinning);
end
        

%calculate stability
SpeedTunning_temp = cell(2,length(Speedlist)); 
stability = zeros(length(Speedlist) ,2); 

for ii = 1:length(Speedlist)
  
        half_1_end = floor(length(spike_time) * 0.5);
        half_2_start = half_1_end + 1;
        
        Event_raw = NeuronActivity.Event_filtered_exp2(:,Speedlist(ii));
        mean_rate(ii) = length(find(Event_raw ~= 0 ))/time;
        Event_raw_1 = Event_raw(1:half_1_end);
        spike_speed_1 = spike_speed(1:half_1_end);
        
     
        SelectedFrame_raw_1 = find(~isnan(Event_raw_1(:))); %all the position are select
        SpeedTrain_1 = spike_speed_1(SelectedFrame_raw_1);
%         SpeedTrain_smooth_1 = general.smoothGauss(SpeedTrain_1,SpeedSmooth);
        SpeedTrain_smooth_1= SpeedTrain_1';
        SelectedFrame_filtered_1 = logical((SpeedTrain_smooth_1 >= MinSpeed).*(SpeedTrain_smooth_1 <= MaxSpeed+timebinning));
        SpeedTrain_filtered_1 = SpeedTrain_smooth_1(SelectedFrame_filtered_1);
        EventTrain_original_1 = Event_raw_1(SelectedFrame_raw_1);
        EventTrain_smooth_1 = general.smoothGauss(EventTrain_original_1,SpeedSmooth);
        EventTrain_filtered_1 = EventTrain_smooth_1(SelectedFrame_filtered_1);
        EventTrain_logical_1 = EventTrain_filtered_1 > 0;
                      
            
        SpeedTunning_temp{1,ii}=SpatialTuning_BNT.SpeedTuningCalcultation(SpeedTrain_filtered_1,EventTrain_logical_1,...
                FrameRate,...
                SpeedRange,MinSpanTime,...
                MaxSpeed+timebinning);
        if ~isempty(SpeedTunning_temp{1,ii})
            SpeedTunning_temp{1,ii}.Rate = smoothdata(SpeedTunning_temp{1,ii}.Rate,'lowess',3);
        else
            SpeedTunning_temp{1,ii}.Rate = NaN;
        end
           
      
        Event_raw_2 = Event_raw(half_2_start:end);
        spike_speed_2 = spike_speed(half_2_start:end);
        
      
        SelectedFrame_raw_2 = find(~isnan(Event_raw_2(:))); %all the position are select
        SpeedTrain_2 = spike_speed_2(SelectedFrame_raw_2);
%         SpeedTrain_smooth_2 = general.smoothGauss(SpeedTrain_2,SpeedSmooth);
        SpeedTrain_smooth_2= SpeedTrain_2';
        SelectedFrame_filtered_2 = logical((SpeedTrain_smooth_2 >= MinSpeed).*(SpeedTrain_smooth_2 <= MaxSpeed+timebinning));
        SpeedTrain_filtered_2 = SpeedTrain_smooth_2(SelectedFrame_filtered_2);
        EventTrain_original_2 = Event_raw_2(SelectedFrame_raw_2);
        EventTrain_smooth_2 = general.smoothGauss(EventTrain_original_2,SpeedSmooth);
        EventTrain_filtered_2 = EventTrain_smooth_2(SelectedFrame_filtered_2);
        EventTrain_logical_2 = EventTrain_filtered_2 > 0;
                      
            
        SpeedTunning_temp{2,ii}=SpatialTuning_BNT.SpeedTuningCalcultation(SpeedTrain_filtered_2,EventTrain_logical_2,...
                FrameRate,...
                SpeedRange,MinSpanTime,...
                MaxSpeed+timebinning);
        if ~isempty(SpeedTunning_temp{2,ii})
            SpeedTunning_temp{2,ii}.Rate = smoothdata(SpeedTunning_temp{2,ii}.Rate,'lowess',3);
        else
            SpeedTunning_temp{2,ii}.Rate = NaN;
        end
            
        stability(ii,2) = corr(SpeedTunning_temp{1,ii}.Rate',SpeedTunning_temp{2,ii}.Rate');
                    
          end
%%
threshold = 0.5;


cellNum = [];
intra_stability = [];
information_content = [];
informaton_rate = [];
peak_rate = [];
mean_rate = [];
speed_score =  [];
for j = 1:length(Speedlist)
%     if ismember(Speedlist(j),Speedlist) && ~ismember(Speedlist(j),Speedlist_2)
         if stability(j,2) >= threshold
%             baselineNum = [baselineNum;baseline_number];
            cellNum = [cellNum;Speedlist(j)];
            intra_stability = [intra_stability;stability(j,2)];
%             SpeedTunning = {SpeedTunning,SpeedTunning{1,stability(find(Speedlist == Speedlist(j)))}};
%             information_content = [information_content;information_content(stability(find(Speedlist == Speedlist(j)),1),1003)];
            peak_rate = [peak_rate;SpeedTuning{1,Speedlist(j)}.PeakRate];
            mean_rate = [mean_rate;meanRate(Speedlist(j))];
            speed_score = [speed_score;SpeedScore(Speedlist(j),1005)];
          
        end
end
    

intra_baseline_Speedlist = cellNum;
intra_baseline_Speed = zeros(length(intra_baseline_Speedlist),8);
intra_baseline_Speed(:,1) = mouseNum;
intra_baseline_Speed(:,2) = baselineNum;
intra_baseline_Speed(:,3) = cellNum;
intra_baseline_Speed(:,4) = intra_stability;
intra_baseline_Speed(:,5) = speed_score;
intra_baseline_Speed(:,7) = peak_rate;
intra_baseline_Speed(:,8) = mean_rate;


baselineNum = intra_baseline_Speed(:,2);   
intra_SpeedTunning = cell(length(baselineNum),1);
for m = 1:length(baselineNum)
        intra_SpeedTunning{m} = SpeedTuning{1,cellNum(m)};
end

SpeedTunning_rate = zeros(length(baselineNum),9);
for m = 1:length(baselineNum)
   SpeedTunning_rate(m,:) = intra_SpeedTunning{m}.Rate;
end


% 
save([pwd,'\Speed-data-timebin\intra_baseline_Speed.mat'],'intra_baseline_Speed','SpeedTuning','intra_SpeedTunning','SpeedTunning_rate');
save([pwd,'\Speed-data-timebin\intra_baseline_Speedlist.mat'],'intra_baseline_Speedlist');
