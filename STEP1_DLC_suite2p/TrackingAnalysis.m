% This code is used to analysis DLC output
% To calculate animal behavioral information
% INPUT: '*0000.csv'(DLC output)
% OUTPUT: behav.mat



close all
clear
addpath(genpath('D:\Test_code\Tools'));

dir_name = pwd;
pos2 = [];
pos1 =[];
ind_all = [];

%% collect all csv files;
csvFiles = dir([dir_name filesep '*0000_filtered.csv']);
DLCposition_Raw = [];
    for i = 1:length(csvFiles)
        DLCposition_Raw = [DLCposition_Raw;xlsread([dir_name filesep csvFiles(i).name])];
    end
    
    save([dir_name filesep 'DLCposition.mat'],'DLCposition_Raw');
    disp('Original position data is collected and saved.');
    
%% creat behav file and select ROI;
behav = msGenerateVideoObj_normal_yjm('.avi');
 
 % timestamps;
ConvertedData = convertTDMS(0,'../MiceVideo_Info.tdms');
timestamps = ConvertedData.Data.MeasuredData(4).Data;

    for i = 1:length(timestamps)
        t = timestamps{i};
        behav.time(i) = str2double(t(12:13))*3600 + str2double(t(15:16))*60 + str2double(t(18:23));
    end
behav.time = behav.time'
behav.duration = behav.time(end)- behav.time(1);
frameIdx = round(behav.numFrames/2);
vidNum = behav.vidNum(frameIdx);
vidFrameNum = behav.frameNum(frameIdx);

% select ROI
frame = behav.vidObj{vidNum}.read(vidFrameNum);
userInput = 'N';
while(strcmpi(userInput,'N'))
    imshow(frame,'InitialMagnification','fit');
    hold on;
    for m = 2:9:size(DLCposition_Raw,2)
        n = m+1;
        plot(DLCposition_Raw(:,m),DLCposition_Raw(:,n));
        saveas(gcf,'Trajectory_before.jpg'); 
    end

    hold off;
    disp('Select ROI');
    roi = drawrectangle;
    userInput = input('Keep ROI? (Y/N)','s');                                                                    
end
behav.ROI = roi.Position;
close();

behav.trackLength = input('Enter the trackLength: ');
%behav.trackLength = 80;
behav.shape = 1;

behav = rmfield(behav,'vidObj');
save('behav.mat','behav');
disp('behav.mat is created.');

%% correct DLC position;
if behav.numFrames ~= size(DLCposition_Raw,1)
    error('Frames error, and file is not saved.');
else
    disp('DLCposition file is saved and start correction.');
    
    DLCposition_corrected = DLCposition_Raw;
    DLCposition_corrected(:,1) = behav.time;
    
     for m = 2:3:size(DLCposition_Raw,2)
        n = m+1;
        pos = (DLCposition_Raw(:,m)-behav.ROI(1)) / behav.ROI(3) * behav.trackLength;
        pos(:,2) = (DLCposition_Raw(:,n)-behav.ROI(2)) / behav.ROI(4) * behav.trackLength;
        
        % remove the position out of boundary;
        for i = 1:size(pos,1)
            if pos(i,1) < -0.5 || pos(i,1) > behav.trackLength + 0.5 || pos(i,2) < -0.5 || pos(i,2) > behav.trackLength + 0.5 % boundary;
                pos(i,:) = NaN;
            end
        end
        
        DLCposition_corrected(:,m:n) = pos;
     end
    
    % remove too fast speed;

        pos1 = DLCposition_corrected(:,2:3); %%ÐÞ¸Ä
        pos2 = DLCposition_corrected(:,11:12);
      
        
        speed1 = sqrt(diff(pos1(:,1)).^2 + diff(pos1(:,2)).^2) ./ diff(behav.time);
        speed2 = sqrt(diff(pos2(:,1)).^2 + diff(pos2(:,2)).^2) ./ diff(behav.time);  
        figure;
        plot(speed1);
        figure;
        plot(speed2);
    
     threshold = input('Enter the threshold of speed threshold: ');
    %threshold = 150;
    if isempty(threshold)
        threshold = 60;
    end
    close all;
    
     figure_i = 1;
    for m = 2:9:size(DLCposition_Raw,2)
        n = m+1;
        
        pos = DLCposition_corrected(:,m:n);
        
        speed = speed2D(pos(:,1), pos(:,2), behav.time);
        pos((speed > threshold),:) = NaN;
        
        % remove wrong position between nan values;
        ind = find(isnan(pos(:,1)));
        for ind_i = 1:length(ind) - 1
            if ind(ind_i) ~= 1 && ind(ind_i+1) - ind(ind_i) <= 30
                if (abs(pos(ind(ind_i)-1,1) - pos(ind(ind_i)+1,1)) > 25 || ...
                        abs(pos(ind(ind_i)-1,2) - pos(ind(ind_i)+1,2)) > 25) && ...
                        (abs(pos(ind(ind_i+1)-1,1) - pos(ind(ind_i+1)+1,1)) > 25 || ...
                        abs(pos(ind(ind_i+1)-1,2) - pos(ind(ind_i+1)+1,2)) > 25)
                    pos(ind(ind_i):ind(ind_i+1),:) = nan;
                end
            end
            ind_i = ind_i+1;
        end
        ind_all = [ind_all sum(isnan(pos(:,1)))];
        
        DLCposition_corrected(:,m:n) = pos;
        
        subplot(1,2,figure_i);
        plot(pos(:,1),pos(:,2));
        xlim([-1,81]);
        ylim([-1,81]);
        title(strcat('point ',num2str(figure_i)));
        daspect([1 1 1]);
        axis on
        xlabel('X (cm)');
        ylabel('Y (cm)');
        
        figure_i = figure_i + 1;
    end
    
    
    saveas(gcf,'trajectory_corrected.jpg'); 
    disp(['The trajectory has ',num2str(ind_all),' nan values']);
    close all;
    
    save('DLCposition.mat','DLCposition_corrected');
    
%% calculate and filter head direction 
    dotNum = 2;
    unitNum = 1;
    behav.position = cell(1,2);
    ind_all = zeros(1, dotNum / 2);

    pos1 = DLCposition_corrected(:,2:4); %%%ÐÞ¸Ä
    pos2 = DLCposition_corrected(:,17:18);
    behav.position{1,1} = pos1;
    behav.position{1,2} = pos2;
    behav.speed{1,1} = speed2D(pos1(:,1), pos1(:,2), behav.time);
    behav.speed{1,2} = speed2D(pos2(:,1), pos2(:,2), behav.time);

    % head direction calculation;
    hdDir = atan2(DLCposition_corrected(:, 12) - DLCposition_corrected(:, 3),DLCposition_corrected(:, 11) - DLCposition_corrected(:, 2));
    hdDir = mod(360 * hdDir / (2*pi), 360);
    behav.headDirection_Raw = hdDir;
                   
    % remove too long LED bar;
    % no LDE bar, but a threshold for the distance betwwen nose and head?
    LEDBar = vecnorm(DLCposition_corrected(:, 2 : 3) - ...
                DLCposition_corrected(:, 11 : 12),2,2);
            plot(LEDBar);
            LEDBar_threshold = input('Enter a threshold for LED bar length. ');
            % LEDBar_threshold = 4;
            close();
            if isempty(LEDBar_threshold)
                LEDBar_threshold = 4;
            end
            hdDir(LEDBar > LEDBar_threshold) = NaN;
            
            ind = find(isnan(hdDir));
            for ind_i = 1:length(ind) - 1
                if ind(ind_i) ~= 1 && ind(ind_i+1) - ind(ind_i) <= 30
                    if (abs(hdDir(ind(ind_i)-1,1) - hdDir(ind(ind_i)+1,1)) > 60) && ...
                            (abs(hdDir(ind(ind_i+1)-1,1) - hdDir(ind(ind_i+1)+1,1)) > 60)
                        hdDir(ind(ind_i):ind(ind_i+1),:) = nan;
                    end
                end
                ind_i = ind_i+1;
            end
            ind_all = sum(isnan(hdDir));
            
            % mean filter;
            hdDir = angleSmooth(hdDir, 'deg', 'movmean', 15, 0);
            behav.headDirection_filtered = hdDir;

%         disp(['The LED direction has ',num2str(ind_all),' nan values']);

%% coverage & explortation std   
   [behav.coverage,behav.std] = boxCoverage_std(behav.position{1,2}(:,1), behav.position{1,2}(:,2), 2, behav.numFrames/behav.duration);
%% running percentage (speed > 2.5 cm/s)
   behav.average_speed = mean(behav.speed{1,2},'omitnan');
    running_frame = length(find(behav.speed{1,2}>2.5));
    behav.running_percentage = running_frame/behav.numFrames;
    behav.running_time = behav.duration * behav.running_percentage;
%% save result
   save([dir_name filesep 'behav.mat'], 'behav');
   disp(strcat(pwd,' Analysis finished and results are saved.'));
   end