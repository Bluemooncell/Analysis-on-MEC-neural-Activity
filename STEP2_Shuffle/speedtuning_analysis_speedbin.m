%This script segments the firing rates according to each speed bin and performs linear correlation analysis between firing rate and running speed for filtering
warning('off')
close all;
clear all;

%%
addpath(genpath('D:\Test_code\MINI2P_toolbox'));
addpath(genpath('D:\Test_code\Tools'));
addpath(genpath('D:\Test_code'));

folder = 'speed_tunning_splitbin';
mkdir ('method2',folder);
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\MiceVideo1\MiceVideo\behav.mat']);
% load('ExperimentInformation.mat');
% load('NAT.mat');

%% paremater settings
SpeedBinning=2; %cm/s
MinSpeed=2.5;
MaxSpeed=18.5;
SpeedRange=MinSpeed:SpeedBinning:MaxSpeed; %cm0
MinSpanTime=10;%second
ShuffleNum=1000;
Shuffling_mininterval=30;
MinEventCount=100;
Session = 1;

%load spike data
TotalCell = size(NeuronActivity.F_raw_Iscell,2);
spike_time = NeuronActivity.timestamps;
behav_time = behav.time;
time = 0;
for i = 1:length(spike_time) - 1
    if spike_time(i+1) - spike_time(i) < 1
        time = time + spike_time(i+1) - spike_time(i);
    end
end
        
%load behavior data
FrameRate = length(spike_time)/time;
SpeedSmooth=round(0.25*FrameRate);
behav_pos = behav.position{1,1};
behav_pos = fillmissing(behav_pos,'linear');
behav_speed = [];
behav_speed = speed2D(behav_pos(:,1), behav_pos(:,2), behav_time);  %这里断开的时间戳应该影响不大？
%calculate speed for each frame of recording neuronactivity
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

%%
SpeedTunning=cell(Session,TotalCell); % tuning curve
Speed_Pearson=zeros(Session,TotalCell,ShuffleNum+3); % K-S value for shuffles (1 to ShuffleNum, 95th, 5th, and observed data)
Speed_Spearman=zeros(Session,TotalCell,ShuffleNum+3); % Spearman for shuffles (1 to ShuffleNum, 95th, 5th, and observed data)

%% K-S analysis and Spearmean test
% generate speed tuning curve with finner binning

for j=1:1:Session
    k=1;
    for i=1:1:TotalCell
        Event_raw = NeuronActivity.Event_filtered_exp2(:,i);
        num = 0;
        for f = 1:length(Event_raw)
            if Event_raw(f) > 0 && spike_speed(f) > MinSpeed
                num = num + 1;
            end
        end% filter out the pmid 35305313frames with speed valid
        % filter out the frames with speed threadholds
%          if num > MinEventCount && NeuronActivity.SNR(i) > 3
            SelectedFrame_raw=find(~isnan(Event_raw(:))); %all the position are select
            SpeedTrain=spike_speed(SelectedFrame_raw);
%             SpeedTrain_smooth=general.smoothGauss(SpeedTrain,SpeedSmooth);
            SpeedTrain_smooth = SpeedTrain';
            SelectedFrame_filtered=logical((SpeedTrain_smooth>=MinSpeed).*(SpeedTrain_smooth<=MaxSpeed+SpeedBinning));
            SpeedTrain_filtered=SpeedTrain_smooth(SelectedFrame_filtered);
            EventTrain_original=Event_raw(SelectedFrame_raw);
            EventTrain_smooth=general.smoothGauss(EventTrain_original,SpeedSmooth);
            EventTrain_filtered=EventTrain_smooth(SelectedFrame_filtered);
            EventTrain_logical=EventTrain_filtered>0;
            SpeedTunning{j,i}=SpatialTuning_BNT.SpeedTuningCalcultation(SpeedTrain_filtered,EventTrain_logical,...
                FrameRate,...
                SpeedRange,MinSpanTime,...
                MaxSpeed+SpeedBinning);
%             if ~isempty(SpeedTunning{j,i})
            SpeedTunning{j,i}.Rate=smoothdata(SpeedTunning{j,i}.Rate,'lowess',3);
            
            SpeedCount=round(SpeedTunning{j,i}.Rate./max(SpeedTunning{j,i}.Rate)*100);
            KS_SpeedBinVector{k,1}=zeros(sum(SpeedCount(~isnan(SpeedCount))),1);
            m=1;
            for p=1:1:length(SpeedCount)
                if ~isnan(SpeedCount(p))
                    for q=1:1:SpeedCount(p)
                        
                        KS_SpeedBinVector{k,1}(m,1)=SpeedTunning{k,1}.SpeedRange(p);
                        m=m+1;
                        
                    end
                    
                end
            end
%             end
            disp(['cell:',num2str(i),'shuffle']);
            for n=1:1:ShuffleNum
              
                xmin=Shuffling_mininterval*FrameRate;
                xmax=size(SelectedFrame_filtered,1)-xmin;
                ShiftFrame=round(xmin+rand(1,1)*(xmax-xmin));
                SpikeTrain_raw_shuffled=circshift(EventTrain_filtered,ShiftFrame);
                SpikeTrain_raw_shuffled_logical=SpikeTrain_raw_shuffled>0;
                
                Speedtuning_shuffled=SpatialTuning_BNT.SpeedTuningCalcultation(SpeedTrain_filtered,SpikeTrain_raw_shuffled_logical,...
                    FrameRate,...
                    SpeedTunning{k,i}.SpeedRange,MinSpanTime,MaxSpeed+SpeedBinning);
                
                RateSmoothed=smoothdata(Speedtuning_shuffled.Rate,'lowess',3);
                SpeedCount=round(RateSmoothed./max(SpeedTunning{j,i}.Rate)*100);
                
                % calculate the KS value for shuffles
                KS_SpeedBinVector_shuffle=zeros(sum(SpeedCount(~isnan(SpeedCount))),1);
                m=1;
                for p=1:1:length(SpeedCount)
                    if ~isnan(SpeedCount(p))
                        for q=1:1:SpeedCount(p)
                            KS_SpeedBinVector_shuffle(m,1)=Speedtuning_shuffled.SpeedRange(p);
                            m=m+1;
                        end
                    else
                    end
                end
                if ~isempty(KS_SpeedBinVector_shuffle)
                   
                    Speed_Pearson(j,i,n)=corr(Speedtuning_shuffled.Rate',Speedtuning_shuffled.SpeedRange');
                else
                   Speed_Pearson(j,i,n)= NaN;
                end
                % calculate the spearman correlation
                if ~isempty(SpeedTrain_filtered) && ~isempty(SpikeTrain_raw_shuffled_logical(:,1))
                  speedScore_tem=SpatialTuning_BNT.speedScore(SpeedTrain_filtered,SpikeTrain_raw_shuffled_logical(:,1)*FrameRate,...
                    0.4); %改动！！！
                
                  Speed_Spearman(j,i,n)=speedScore_tem(1);
                end
                
            end
                
            Speed_Pearson(j,i,ShuffleNum+1)=prctile(Speed_Pearson(j,i,1:ShuffleNum),95);
            Speed_Pearson(j,i,ShuffleNum+2)=prctile(Speed_Pearson(j,i,1:ShuffleNum),5);
            if ~isempty(KS_SpeedBinVector{k,1})
              Speed_Pearson(j,i,ShuffleNum+3)=corr(SpeedTunning{k,i}.Rate',SpeedTunning{k,i}.SpeedRange');
            else
              Speed_Pearson(j,i,ShuffleNum+3) = NaN;
            end

            Speed_Spearman(j,i,ShuffleNum+1)=prctile(Speed_Spearman(j,i,1:ShuffleNum),95);
            Speed_Spearman(j,i,ShuffleNum+2)=prctile(Speed_Spearman(j,i,1:ShuffleNum),5);
             if ~isempty(SpeedTrain_filtered) && ~isempty(EventTrain_logical)
               speedScore_tem=SpatialTuning_BNT.speedScore(SpeedTrain_filtered,EventTrain_logical*FrameRate,...
                0.4);%改动！！！
               Speed_Spearman(j,i,ShuffleNum+3)=speedScore_tem(1);
             end
                            
        end
    end



%% identify speed cells
IsPosSpeedCell=cell(Session,1);
IsNagSpeedCell=cell(Session,1);
IsNonlinearSpeedCell=cell(Session,1);
for j=1:1:Session
    g=1;
    k=1;
    h=1;
    for i=1:1:TotalCell
        if Speed_Pearson(j,i,ShuffleNum+3)>Speed_Pearson(j,i,ShuffleNum+1)
%             if Speed_Spearman(j,i,ShuffleNum+3)>Speed_Spearman(j,i,ShuffleNum+1)
                IsPosSpeedCell{j,1}(g)=i;
                g=g+1;
%             elseif Speed_Spearman(j,i,ShuffleNum+3)<Speed_Spearman(j,i,ShuffleNum+2)
        elseif Speed_Pearson(j,i,ShuffleNum+3)< Speed_Pearson(j,i,ShuffleNum+2)
                IsNagSpeedCell{j,1}(k)=i;
                k=k+1;
        else
                IsNonlinearSpeedCell{j,1}(h)=i;
                h=h+1;
        end
    end      
end
 save([pwd,'\method2\speed_tunning_splitbin\speedTunning.mat'],'Event_raw','EventTrain_original',...
        'EventTrain_smooth','EventTrain_filtered','FrameRate','MaxSpeed','MinSpeed',...
        'FrameRate','SpeedCount','SpeedRange','Speed_Spearman','Speed_Pearson',...
        'SpeedBinning','speedScore_tem','SpeedTunning','Speedtuning_shuffled',...
        'SpeedTrain_filtered','SpeedTrain_smooth','SpeedTrain','SpeedSmooth','spike_time',...
        'spike_speed','IsPosSpeedCell','IsNonlinearSpeedCell','IsNagSpeedCell')
    %     end


%% save information for positive speed-tunning cells
PosSpeedRange = SpeedRange;
for jj = 1:length(IsPosSpeedCell{1,1})
    PosSpeedTunning(jj) = SpeedTunning{1,IsPosSpeedCell{1,1}(jj)};
    PosSpeedKStest(jj) = Speed_Pearson(1,IsPosSpeedCell{1,1}(jj),103);
    PosSpeedSpearman(jj)= Speed_Spearman(1,IsPosSpeedCell{1,1}(jj),103);
end
save([pwd,'\method2\speed_tunning_splitbin\IsPosSpeedCell.mat'],'IsPosSpeedCell',...
    'PosSpeedRange','PosSpeedTunning','PosSpeedKStest','PosSpeedSpearman')
%% plot speed_tuning curve for postive speed-tunning cells

figure;
set(gcf,'position',[50 50 400 500])
for ii = 1:length(IsPosSpeedCell{1,1})
    y = SpeedTunning{1,IsPosSpeedCell{1,1}(ii)}.Rate;
    x = SpeedRange;
    
%     values = spcrv([[x(1) x x(end)];[y(1) y y(end)]],3);
%     plot(values(1,:),values(2,:),'r','LineWidth',5);
           plot(x,y, 'r','LineWidth',5);
    
    title('Speed Tunning Curve','FontSize',20);
    ylabel('firing rate(Hz)','FontSize',20);
    xlabel('running speed(cm/s)','FontSize',20);
    ylim([0 3]);
    ax = gca;
    ax.YTick = [0 1 2 3]; 
    ax.YTickLabel = {'0','1','2','3'}
    %     xlim([0 20]);
    %     title(['speed score: cell',num2str(speedcell99(i)),num2str(scores(1,1))]);
    
     saveas(gcf,strcat(pwd,'\method2\speed_tunning_splitbin\cell', num2str(IsPosSpeedCell{1,1}(ii)),'speed-tuning.png'));
end
close all;

