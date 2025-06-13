
clear
%addpath(genpath('D:\Test_code\Tools'));
addpath(genpath('D:\Test_code'));
%addpath(genpath('D:\Test_code\MINI2P_toolbox'));
load([pwd,'\method2\NeuronActivity.mat']);
load([pwd,'\MiceVideo1\MiceVideo\behav.mat']);
iteration = 1000;
mininterval_frame = 250;
Radii=[5 5];
t0 = tic;
disp('start shuffling')

foldername = 'shuffle_ratemap_new3';
mkdir([pwd,'\method2'], foldername)
timestamps = NeuronActivity.timestamps;
framestart = 1;
frameend = length(timestamps);
Event_filtered = NeuronActivity.Event_filtered_exp2(framestart:frameend,:);
framenum = size(Event_filtered,1);
cellnum = size(Event_filtered,2);
behav_time = behav.time;
behav_speed = behav.speed{1,1};
behav_pos = zeros(length(behav.time),5);
behav_pos(:,1) = behav_time;
behav_pos(:,2) = behav.position{1,1}(:,1); % x
behav_pos(:,3) = behav.position{1,1}(:,2); % y
behav_pos(:,4) = behav.position{1,1}(:,3); % likelyhood
behav_pos(:,5) = behav.headDirection_filtered; % head direction
%remove data with speed<2.5cm/s
behav_pos(behav_speed<2.5|behav_speed>100,2:5) = NaN;

information_shuffle_rate = zeros(cellnum,iteration+3);
information_shuffle_content = zeros(cellnum,iteration+3);
Gridness_shuffle = zeros(cellnum,iteration+3);
MVL_shuffle = zeros(cellnum,iteration+3);
borderScore_shuffle = zeros(cellnum,iteration+3);

Position = cell(1,cellnum);
Spike = cell(1,cellnum);
ActivityMap = cell(1,cellnum);
aMap = cell(1,cellnum);
turningCurve = cell(1,cellnum);
tcStat = cell(1,cellnum);


for i = 1:cellnum
    disp([' Cell ',num2str(i),'/',num2str(cellnum)])
    
    %% cell real information
   
    e = Event_filtered(:,i);
    
    if length(find(e>0))>2
        k = find(e>0);
        
        spike_number = length(k);   
        spike_pos = zeros(spike_number,3);
        spike_pos(:,1) = timestamps(k);
        spike_pos(:,4) = e(k); % amplitude
        
        speed = zeros(spike_number,1);
        
        for j = 1 : spike_number
            [~, nj] = min(abs(behav_time-spike_pos(j,1)));
            spike_pos(j,[2,3,5,6]) = behav_pos(nj,[2,3,4,5]);
            speed(j) = behav_speed(nj);
        end
        
        %remove spikes with speed<2.5cm/s
        spike_pos = spike_pos((~(speed<2.5))&(~isnan(spike_pos(:,2))),:);
        Position{1,i} = behav_pos;
        Spike{1,i} = spike_pos;
        
        
        % Rate Map (power)
        smooth_space = 2.5;
        bin_space = 2.5;
        Mintime = 0.1;
        Limits = [0 80 0 80];
        ActivityMap{1,i} = SpatialTuning_BNT.map(behav_pos,spike_pos(:,1),'smooth',smooth_space,'binWidth',bin_space,'minTime',Mintime,'limits',Limits);
        [information,~,~]=SpatialTuning_BNT.mapStatsPDF(ActivityMap{1,i});
        information_shuffle_rate(i,iteration+3) = information.rate;
        information_shuffle_content(i,iteration+3) = information.content;
        % autocorrelation map
        aMap{1,i}  = SpatialTuning_BNT.autocorrelation(ActivityMap{1,i}.z);
        [gridnessScore,~,Centerfield,~,ScoreRadius]=analyses.gridnessScore(aMap{1,i} );
        % [gridnessScore, stats] = SpatialTuning_BNT.gridnessScore(aMap);
        Gridness_shuffle(i,iteration+3) = gridnessScore;
        
        % HD
        %note simple time
        sampleTime = mean(diff(behav.time));
        AngleSmooth = 2;
        AngleBinsize=3;
        turningCurve{1,i} = SpatialTuning_BNT.turningCurve(spike_pos(:,6),behav_pos(:,5),sampleTime,'smooth',AngleSmooth,'binWidth',AngleBinsize);
        tcStat{1,i} = SpatialTuning_BNT.tcStatistics(turningCurve{1,i} , AngleBinsize, 50);
        MVL_shuffle(i,iteration+3) = tcStat{1,i}.r;
        % border
        binWidth = 2.5;
        Score= borderScoreCalculation(ActivityMap{1,i}.z, binWidth);
        borderScore_shuffle(i,iteration+3) = Score;
         
    else
        information_shuffle_rate(i,1:iteration+3) = nan;
        information_shuffle_content(i,1:iteration+3) = nan;
        Gridness_shuffle(i,1:iteration+3) = nan;
        MVL_shuffle(i,1:iteration+3) = nan;
        borderScore_shuffle(i,1:iteration+3) = nan;
        
    end
    
    %% shuffle spikes train
    
    
    parfor n = 1:iteration
 
        %disp(['Cell ',num2str(i),' Iteration ',num2str(n)]);
        xmin = mininterval_frame;
        xmax = framenum-mininterval_frame;
        shift_frame = round(xmin+rand(1,1)*(xmax-xmin))
        event_shuffled = circshift(Event_filtered(:,i),shift_frame);
       
        if length(find( event_shuffled>0))>2
            spike_number = length(find(event_shuffled>0));
            spike_pos_shuffle = zeros(spike_number,3);
            spike_pos_shuffle(:,1) = timestamps(find(event_shuffled>0));
            spike_pos_shuffle(:,4) = event_shuffled(find(event_shuffled>0)); % amplitude
            
            speed = zeros(spike_number,1);
            
            for j = 1 : spike_number
                [~, nj] = min(abs(behav_time-spike_pos_shuffle(j,1)));
                spike_pos_shuffle(j,2) = behav_pos(nj,2);
                spike_pos_shuffle(j,3) = behav_pos(nj,3);
                spike_pos_shuffle(j,5) = behav_pos(nj,4); % behavioral likelyhood
                spike_pos_shuffle(j,6) = behav_pos(nj,5); % head direction
                speed(j) = behav_speed(nj);
            end
            
            spike_pos_shuffle = spike_pos_shuffle((~(speed<2.5))&(~isnan(spike_pos_shuffle(:,2))),:);
            if isempty(spike_pos_shuffle)
                information_shuffle_rate(i,n) = nan;
                information_shuffle_content(i,n) = nan;
                Gridness_shuffle(i,n) = nan;
                MVL_shuffle(i,n) = nan;
                borderScore_shuffle(i,n) = nan;
                continue
            end
            
            %% Rate Map (ZWJ)
            smooth_space = 2.5;
            bin_space = 2.5;
            Mintime = 0.1;
            % rate map
            ActivityMap = SpatialTuning_BNT.map(behav_pos,spike_pos_shuffle(:,1),'smooth',smooth_space,'binWidth',bin_space,'minTime',Mintime,'limits',Limits);
            
            [information,~,~]=SpatialTuning_BNT.mapStatsPDF(ActivityMap);
            information_shuffle_rate(i,n) = information.rate;
            information_shuffle_content(i,n) = information.content;
            
            aMap = SpatialTuning_BNT.autocorrelation(ActivityMap.z);  % autocorrelation map
            Gridness_shuffle(i,n)= SpatialTuning_BNT.gridnessScoreShuffled(aMap, Centerfield, ScoreRadius, Radii)
            
            %     [gridnessScore, stats] = SpatialTuning_BNT.gridnessScore(aMap);
            %     Gridness_shuffle(i,n) = gridnessScore;
            
            % HD
            sampleTime = mean(diff(behav.time));
            AngleSmooth = 2;
            AngleBinsize=3;
            turningCurve= SpatialTuning_BNT.turningCurve(spike_pos_shuffle(:,6),behav_pos(:,5),sampleTime,'smooth',AngleSmooth,'binWidth',AngleBinsize);
            tcStat = SpatialTuning_BNT.tcStatistics(turningCurve, AngleBinsize, 50);
            MVL_shuffle(i,n) = tcStat.r;
            % border
            binWidth = 2.5;
            Score_shuffle = borderScoreCalculation(ActivityMap.z, binWidth);
            borderScore_shuffle(i,n) = Score_shuffle;
            
            
            
        else
            disp(['no filered event of cell ',num2str(i),'shuffle: ',num2str(n)]);
            
        end
        
        
        
        
    end
    
    information_shuffle_rate(i,iteration+1) = prctile(information_shuffle_rate(i,1:iteration),95);
    information_shuffle_rate(i,iteration+2) = prctile(information_shuffle_rate(i,1:iteration),99);
    information_shuffle_content(i,iteration+1) = prctile(information_shuffle_content(i,1:iteration),95);
    information_shuffle_content(i,iteration+2) = prctile(information_shuffle_content(i,1:iteration),99);
    Gridness_shuffle(i,iteration+1) = prctile(Gridness_shuffle(i,1:iteration),95);
    Gridness_shuffle(i,iteration+2) = prctile(Gridness_shuffle(i,1:iteration),99);
    MVL_shuffle(i,iteration+1) = prctile(MVL_shuffle(i,1:iteration),95);
    MVL_shuffle(i,iteration+2) = prctile(MVL_shuffle(i,1:iteration),99);
    borderScore_shuffle(i,iteration+1) =prctile(borderScore_shuffle(i,1:iteration),95);
    borderScore_shuffle(i,iteration+2) =prctile(borderScore_shuffle(i,1:iteration),99);
    
    
    
end
Ratemap.Position = Position;
Ratemap.Spike = Spike;
Ratemap.ActivityMap = ActivityMap;
Ratemap.Autocorrelogram = aMap;
Ratemap.turningCurve = turningCurve;
Ratemap.tcStat = tcStat;

save([pwd,'\method2\',foldername filesep 'shuffle_ratemap_new2.mat'],'Ratemap', 'information_shuffle_rate','information_shuffle_content','Gridness_shuffle','MVL_shuffle','borderScore_shuffle');
t1 = toc(t0)
%end
