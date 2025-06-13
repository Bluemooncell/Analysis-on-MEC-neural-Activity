% This script segments time into bins, computes bin-wise firing rates and speed traces, and performs correlation analysis.
% Codes: 1001 = 95th percentile, 1002 = 99th, 1003 = 5th, 1004 = 1st percentile.
warning('off')
clear

%%
addpath(genpath('D:\Test_code\MINI2P_toolbox'));
addpath(genpath('D:\Test_code\Tools'));
addpath(genpath('D:\Test_code'));
folder = 'speed_tunning_timebin';

mkdir ([pwd,'\method2'], folder)
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\MiceVideo1\MiceVideo\behav.mat']);
 %% paremater settings
SpeedBinning = 2;
timeBinning=1; % s
MinSpeed=2.5;
MaxSpeed=18.5;
SpeedRange=MinSpeed:SpeedBinning:MaxSpeed; %cm0
MinSpanTime=10;%second
ShuffleNum=1000;
Shuffling_mininterval=30;
MinEventCount=100;


%load spike data
TotalCell = size(NeuronActivity.F_raw_Iscell,2);
spike_time = NeuronActivity.timestamps;
behav_time = behav.time - spike_time(1);
spike_time = spike_time - spike_time(1);
time = 0;
for i = 1:length(spike_time) - 1
    if spike_time(i+1) - spike_time(i) < 1
        time = time + spike_time(i+1) - spike_time(i);
    end
end

%load behavior data
behav_pos = behav.position{1,1};
behav_pos = fillmissing(behav_pos,'linear');
behav_speed = speed2D(behav_pos(:,1), behav_pos(:,2), behav_time);  %这里断开的时间戳应该影响不大？
FrameRate = length(behav_time)/(behav_time(end)-behav_time(1));
Event_raw = NeuronActivity.Event_filtered_exp2;
Event_logical = Event_raw>0;
time_binnum = floor(time/timeBinning);
% FrameRate = time_binnum/time;
bin_speed = zeros(time_binnum,1);
bin_rate = zeros(time_binnum,TotalCell);
for q = 1 : time_binnum
    tstart = (q-1) * timeBinning;
    tend = (q) * timeBinning;
    bin_speed(q) = mean(behav_speed(behav_time>=tstart & behav_time<tend), 'omitnan');
    
    tstart = max(0, (q-1) * timeBinning);
    tend = min(time_binnum * timeBinning, (q) * timeBinning);
    bin_rate(q, :) = sum(Event_logical(spike_time>=tstart & spike_time<tend, :), 1, 'omitnan')/(tend-tstart);
end

%% calculate speed score
SpeedScore = zeros(TotalCell, ShuffleNum+5);
parfor i = 1:TotalCell
    disp(['processing cell ' num2str(i)])
    ss = zeros(1,ShuffleNum+5);
    bin_rate_smooth = general.smoothGauss(bin_rate(:, i), 2);
    bin_rate_smooth_select = bin_rate_smooth(bin_speed>MinSpeed & bin_speed<=MaxSpeed+SpeedBinning);
    bin_speed_select = bin_speed(bin_speed>MinSpeed & bin_speed<=MaxSpeed+SpeedBinning);
    ss(ShuffleNum+5) = corr(bin_rate_smooth_select, bin_speed_select);
    
    for n=1:1:ShuffleNum
        xmin=Shuffling_mininterval*FrameRate;
        xmax=length(behav_time)-xmin;
        ShiftFrame=round(xmin+rand(1,1)*(xmax-xmin));
        behav_speed_shuffled = circshift(behav_speed,ShiftFrame);
        %         bin_speed_shuffled=circshift(bin_speed,ShiftFrame);
        bin_speed_shuffled =zeros(time_binnum,1);
        for q = 1 : time_binnum
            tstart = (q-1) * timeBinning;
            tend = (q) * timeBinning;
            bin_speed_shuffled(q) = mean(behav_speed_shuffled(behav_time>=tstart & behav_time<tend), 'omitnan');
        end
        bin_rate_smooth_select = bin_rate_smooth(bin_speed_shuffled>MinSpeed & bin_speed_shuffled<=MaxSpeed+SpeedBinning);
        bin_speed_shuffled = bin_speed_shuffled(bin_speed_shuffled>MinSpeed & bin_speed_shuffled<=MaxSpeed+SpeedBinning);
        ss(n) = corr(bin_rate_smooth_select, bin_speed_shuffled);
    end
    ss(ShuffleNum+1) = prctile(ss(1:ShuffleNum), 95);
    ss(ShuffleNum+2) = prctile(ss(1:ShuffleNum), 99);
    ss(ShuffleNum+3) = prctile(ss(1:ShuffleNum), 5);
    ss(ShuffleNum+4) = prctile(ss(1:ShuffleNum), 1);
    
    SpeedScore(i, :) = ss;
end


    % %% identify speed cells
    pos_speedlist_99 = [];
    pos_speedlist_95 = [];
    neg_speedlist_95 = [];
    neg_speedlist_99 = [];
    for i=1:1:TotalCell
        if SpeedScore(i, end) > SpeedScore(i, ShuffleNum+2)
            pos_speedlist_99(end+1) = i;
        elseif SpeedScore(i, end) > SpeedScore(i, ShuffleNum+1)
            pos_speedlist_95(end+1) = i;
        end
    end
    
    for i=1:1:TotalCell
        if SpeedScore(i, end) < SpeedScore(i, ShuffleNum+4)
            neg_speedlist_99(end+1) = i;
        elseif SpeedScore(i, end) < SpeedScore(i, ShuffleNum+3)
            neg_speedlist_95(end+1) = i;
        end
    end
    
       
    save([pwd,'\method2\' folder filesep 'SpeedScore.mat'],'pos_speedlist_99','pos_speedlist_95',...
        'neg_speedlist_95','neg_speedlist_99',...
        'SpeedScore');

%% plot speed_tuning curve for speed-tunning cells
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
FrameRate = length(spike_time)/time;
SpeedSmooth=round(0.25*FrameRate);
SpeedTuning = cell(1,TotalCell);
for i = 1:TotalCell
    Event_raw = NeuronActivity.Event_filtered_exp2(:,i);
    SelectedFrame_raw=find(~isnan(Event_raw(:))); %all the position are select
    SpeedTrain=spike_speed(SelectedFrame_raw);
    %     SpeedTrain_smooth=general.smoothGauss(SpeedTrain,SpeedSmooth);
    SpeedTrain_smooth=SpeedTrain';
    SelectedFrame_filtered=logical((SpeedTrain_smooth>=MinSpeed).*(SpeedTrain_smooth<=MaxSpeed+SpeedBinning));
    SpeedTrain_filtered=SpeedTrain_smooth(SelectedFrame_filtered);
    EventTrain_original=Event_raw(SelectedFrame_raw);
    EventTrain_smooth=general.smoothGauss(EventTrain_original,SpeedSmooth);
    EventTrain_filtered=EventTrain_smooth(SelectedFrame_filtered);
    EventTrain_logical=EventTrain_filtered>0;
    SpeedTuning{i}=SpatialTuning_BNT.SpeedTuningCalcultation(SpeedTrain_filtered,EventTrain_logical,...
        FrameRate,...
        SpeedRange,MinSpanTime,...
        MaxSpeed+SpeedBinning);
end
save([pwd,'\method2\' folder filesep 'SpeedTuning.mat'], 'SpeedTuning')

% plot 
figure;
set(gcf,'position',[50 50 400 500])
for i = [pos_speedlist_95, neg_speedlist_95]
    y = SpeedTuning{i}.Rate;
    x = SpeedRange;
    
    %     values = spcrv([[x(1) x x(end)];[y(1) y y(end)]],3);
    %     plot(values(1,:),values(2,:),'r','LineWidth',5);
    plot(x,y, 'r','LineWidth',5);
    
    title('Speed Tunning Curve','FontSize',20);
    ylabel('firing rate(Hz)','FontSize',20);
    xlabel('running speed(cm/s)','FontSize',20);
    %     ylim([0 3]);
    %     ax = gca;
    %     ax.YTick = [0 1 2 3];
    %     ax.YTickLabel = {'0','1','2','3'};
    %     xlim([0 20]);
    %     title(['speed score: cell',num2str(speedcell99(i)),num2str(scores(1,1))]);
    
    saveas(gcf,[pwd,'\method2\' folder filesep 'cell_' num2str(i) '.png']);
end
close all;



%
