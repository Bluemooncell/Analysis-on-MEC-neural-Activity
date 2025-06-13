<<<<<<< HEAD
function [root,tail,theta] = frequency_tuning(behav, NeuronActivity)
%% calculate theta from whisker behav
behav_time = behav.time;
pos1 = behav.position{1,1};
pos2 = behav.position{1,2};
if nanstd(pos1(:,1:2),0,'all')>=nanstd(pos2(:,1:2),0,'all')
    tail = pos1;
    root = pos2;
else
    tail = pos2;
    root = pos1;
end
root_c = nanmean(root(:,1:2));
tail_c = nanmean(tail(:,1:2));
vec0 = [tail_c(1)-root_c(1), tail_c(2)-root_c(2)];
f = @(x,y) x/vec0(1)-y/vec0(2);

theta = zeros(size(tail,1),1);
for i = 1:size(tail,1)
    vec_i = [tail(i,1)-root(i,1), tail(i,2)-root(i,2)];
    if dot(vec0, vec_i)/(norm(vec0)*norm(vec_i)) > 1
        theta(i) = acos(1);
    else
        theta(i) = acos(dot(vec0, vec_i)/(norm(vec0)*norm(vec_i)));
    end
    if f(vec_i(1),vec_i(2)) < 0
        theta(i) = theta(i)*(-1);
    end
    
end
for ind = find(isnan(theta))
    theta(ind) = nanmean(theta(nanmax(ind-3,1):nanmin(ind+3,size(theta,1))));
end

% frequency 和 tuning 应该不行，不用看，tuning部分也许有些地方可以参考
end
% %% calculate frequency
% fre = movstd(theta, 50);
% Ts = nanmean(diff(behav_time));
% figure()
% yy = fft(theta(6000:6200));
% fs = 1/Ts;
% xx = (0:length(yy)-1)*fs/length(yy);
% plot(xx,abs(yy))
% xlabel('Frequency (Hz)')
% ylabel('Magnitude')
% title('Magnitude')
% %% calculate tuning
% FreBinning=0.025;
% MinFre=0;
% MaxFre=0.25;
% FreRange=MinFre:FreBinning:MaxFre;
% MinSpanTime=10;%second
% ShuffleNum=1000;
% Shuffling_mininterval=30;
% 
% spike_time = NeuronActivity.timestamps;
% temp = diff(spike_time);
% time = nansum(temp(temp<1));
% FrameRate = length(spike_time)/time;
% 
% Fre_train = zeros(size(spike_time,1),1);
% for i = 1 : length(spike_time)
%     [~, ind] = nanmin(abs(behav_time-spike_time(i)));
%     Fre_train(i) = fre(ind);
% end
% 
% Event_raw = NeuronActivity.Event_filtered_exp2;
% SelectedFrame_filtered = logical((Fre_train >= MinFre).*(Fre_train <= MaxFre+FreBinning));
% Fre_train_filtered = Fre_train(SelectedFrame_filtered);
% EventTrain_filtered = Event_raw(SelectedFrame_filtered, :);
% EventTrain_logical_1 = EventTrain_filtered > 0;
% 
% Fre_tuning = cell(1,size(EventTrain_filtered,2));
% for i = 1:size(EventTrain_filtered,2)
%     Fre_tuning{1,i}=SpatialTuning_BNT.SpeedTuningCalcultation(Fre_train_filtered,EventTrain_logical_1(:,i),...
%             FrameRate, FreRange,MinSpanTime, MaxFre+FreBinning);
%     if ~isempty(Fre_tuning{1,i})
%         Fre_tuning{1,i}.Rate = smoothdata(Fre_tuning{1,i}.Rate,'lowess',3);
%     else
%         Fre_tuning{1,ii}.Rate = NaN;
%     end
=======
function [root,tail,theta] = frequency_tuning(behav, NeuronActivity)
%% calculate theta from whisker behav
behav_time = behav.time;
pos1 = behav.position{1,1};
pos2 = behav.position{1,2};
if nanstd(pos1(:,1:2),0,'all')>=nanstd(pos2(:,1:2),0,'all')
    tail = pos1;
    root = pos2;
else
    tail = pos2;
    root = pos1;
end
root_c = nanmean(root(:,1:2));
tail_c = nanmean(tail(:,1:2));
vec0 = [tail_c(1)-root_c(1), tail_c(2)-root_c(2)];
f = @(x,y) x/vec0(1)-y/vec0(2);

theta = zeros(size(tail,1),1);
for i = 1:size(tail,1)
    vec_i = [tail(i,1)-root(i,1), tail(i,2)-root(i,2)];
    if dot(vec0, vec_i)/(norm(vec0)*norm(vec_i)) > 1
        theta(i) = acos(1);
    else
        theta(i) = acos(dot(vec0, vec_i)/(norm(vec0)*norm(vec_i)));
    end
    if f(vec_i(1),vec_i(2)) < 0
        theta(i) = theta(i)*(-1);
    end
    
end
for ind = find(isnan(theta))
    theta(ind) = nanmean(theta(nanmax(ind-3,1):nanmin(ind+3,size(theta,1))));
end

% frequency 和 tuning 应该不行，不用看，tuning部分也许有些地方可以参考
end
% %% calculate frequency
% fre = movstd(theta, 50);
% Ts = nanmean(diff(behav_time));
% figure()
% yy = fft(theta(6000:6200));
% fs = 1/Ts;
% xx = (0:length(yy)-1)*fs/length(yy);
% plot(xx,abs(yy))
% xlabel('Frequency (Hz)')
% ylabel('Magnitude')
% title('Magnitude')
% %% calculate tuning
% FreBinning=0.025;
% MinFre=0;
% MaxFre=0.25;
% FreRange=MinFre:FreBinning:MaxFre;
% MinSpanTime=10;%second
% ShuffleNum=1000;
% Shuffling_mininterval=30;
% 
% spike_time = NeuronActivity.timestamps;
% temp = diff(spike_time);
% time = nansum(temp(temp<1));
% FrameRate = length(spike_time)/time;
% 
% Fre_train = zeros(size(spike_time,1),1);
% for i = 1 : length(spike_time)
%     [~, ind] = nanmin(abs(behav_time-spike_time(i)));
%     Fre_train(i) = fre(ind);
% end
% 
% Event_raw = NeuronActivity.Event_filtered_exp2;
% SelectedFrame_filtered = logical((Fre_train >= MinFre).*(Fre_train <= MaxFre+FreBinning));
% Fre_train_filtered = Fre_train(SelectedFrame_filtered);
% EventTrain_filtered = Event_raw(SelectedFrame_filtered, :);
% EventTrain_logical_1 = EventTrain_filtered > 0;
% 
% Fre_tuning = cell(1,size(EventTrain_filtered,2));
% for i = 1:size(EventTrain_filtered,2)
%     Fre_tuning{1,i}=SpatialTuning_BNT.SpeedTuningCalcultation(Fre_train_filtered,EventTrain_logical_1(:,i),...
%             FrameRate, FreRange,MinSpanTime, MaxFre+FreBinning);
%     if ~isempty(Fre_tuning{1,i})
%         Fre_tuning{1,i}.Rate = smoothdata(Fre_tuning{1,i}.Rate,'lowess',3);
%     else
%         Fre_tuning{1,ii}.Rate = NaN;
%     end
>>>>>>> 342f783 (Include MINI2P_toolbox as a regular foloder)
% end