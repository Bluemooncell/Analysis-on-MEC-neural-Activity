                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         clc 
% This code is used to analysis suite2p output
% To calculate dF/Fzero and deconvoluted events,and other related information
% INPUT: Fall.mat
% OUTPUT: NeuronActivity.mat

clear
addpath(genpath('D:\Test_code'));
addpath(genpath('D:\Test_code\Tools\OASIS_matlab'));

load ([pwd,'\Fall.mat']);
foldername = 'method2';
mkdir(foldername);
%% read timestamp information

tdmsFiles = dir([pwd,'\CellVideo2\','*.tdms']);

% read timestamp information
[ConvertedData,ConvertVer,ChanNames]=convertTDMS(false,[tdmsFiles.folder filesep tdmsFiles.name]);
st = ConvertedData.Data.MeasuredData(8).Data;

timestamps = zeros(length(st),1);

% transfer into seconds
    for i = 1:length(st)
        t = st{i};      
        timestamps(i) = str2double(t(12:13))*3600 + str2double(t(15:16))*60 + str2double(t(18:23));
    end

%% detect cell number & frame number

cell = find(iscell(:,1) == 1);
F_raw = (F - Fneu*0.7)';
F_raw = double(F_raw);
F_raw_Iscell = F_raw(:,cell);

[FrameNum,CellNum] = size(F_raw_Iscell);
[FrameNum,ROINum] = size(F_raw);

%% calculate F_zero and dF/F
MovingWindow = 30;
Framerate = 9;
TimeThreadhold = 0.75;
timeexpanded = 0.4;

outlier = zeros(FrameNum,CellNum);
Significant_tem =  zeros(FrameNum,CellNum);
Significant = zeros(FrameNum,CellNum);

for i = 1:CellNum
    disp(['calculate F_zero and dF/F: Cell  ',num2str(i)])
    % calculate F_zero   
    F_zero_uncorrected(:,i)= preprocessing.smooth_percentile(F_raw_Iscell(:,i),ceil(MovingWindow*Framerate),8);

    F_std_local(:,i) = movstd(F_raw_Iscell(:,i),MovingWindow*Framerate);
    F_std_local_min(i)= min(F_std_local(:,i));
    F_std_local_max(i) = max(F_std_local(:,i));
    F_std_local_10percent(i) = F_std_local_min(:,i)+0.1*(F_std_local_max(:,i)-F_std_local_min(:,i));
    F_M(i) = mean(F_raw_Iscell(find(F_std_local(:,i)<F_std_local_10percent(i)),i)-F_zero_uncorrected(find(F_std_local(:,i)<F_std_local_10percent(i)),i));
    F_zero(:,i) = F_zero_uncorrected(:,i)+F_M(:,i);
    
    % find outlier
    F_zero_z(:,i) = zscore(F_zero(:,i));


    for j = 16:FrameNum-15
        if F_zero_z(j,i)<-1.8
           outlier(j-15:j+15,i) = 1;
        end
    end

    % calculate dF/F
    detaF_F_raw(:,i) = (F_raw_Iscell(:,i)-F_zero(:,i))./F_zero(:,i);
    detaF_F_removed(:,i)= detaF_F_raw(:,i);
    detaF_F_removed(find(outlier(:,i)==1),i) = nan;
    % denoise dF/F
 
    detaF_F_denoised(:,i) = wdenoise(detaF_F_raw(:,i),12, ...
        'Wavelet', 'sym4', ...
        'DenoisingMethod', 'Bayes', ...
        'ThresholdRule', 'Median', ...
        'NoiseEstimate', 'LevelIndependent');

    detaF_F_denoised_removed(:,i) = detaF_F_denoised(:,i);
    detaF_F_denoised_removed(find(outlier(:,1)==1),i)=nan;

    % calculate significant transient


    F_std_local_detaF(:,i) = movstd(detaF_F_denoised(:,i),TimeThreadhold*Framerate);  
    Significant_tem(:,i)=(detaF_F_denoised(:,i)>2*F_std_local_detaF(:,i)); %the significant threadhold was set as 1.5 X local STD

        for j=1:1:length(Significant_tem(:,i))-ceil(TimeThreadhold*Framerate)-ceil(timeexpanded*Framerate)
            if sum(Significant_tem(j:1:j+ceil(TimeThreadhold*Framerate),i))>=ceil(TimeThreadhold*Framerate)
                Significant(j:1:j+ceil(TimeThreadhold*Framerate)+ceil(timeexpanded*Framerate),i)=1;
            else 
            end
        end 
        for j=1+ceil(TimeThreadhold*Framerate)+ceil(timeexpanded*Framerate):1:length(Significant_tem(:,1))
            if sum(Significant_tem(j-ceil(TimeThreadhold*Framerate):1:j,i))>=ceil(TimeThreadhold*Framerate)
                Significant(j-ceil(TimeThreadhold*Framerate)-ceil(timeexpanded*Framerate):1:j,i)=1;
            else 
           end
        end
    Significant(find(outlier(:,i)==1),i)= 0; %remove sig within outlier
end



%% deconvolution
addpath(genpath('G:\TJY\Code_WSD_new\Tools\OASIS_matlab'));
p.type = 'exp2';
p.pars = [];
p.sn = [];
p.b = 0;
p.smin = -5;
p.method = 'foopsi';
p.optimize_pars = true;
p.optimize_b = true;
p.max_tau = 100;


%% denoising and deconvolution, filter event

p.type = 'exp2';
p.pars = [];
p.sn = [];
p.b = 0;
p.smin = -5;
p.method = 'foopsi';
p.optimize_pars = true;
p.optimize_b = true;
p.max_tau = 100;

for i = 1:CellNum 
 
[detaF_F_denoised_deconv(:,i), Event_raw_exp2(:,i), options] = deconvolveCa(detaF_F_denoised(:,i), p);
Event_raw_exp2(find(outlier(:,i)==1),i)=0; % remove abnormal signal
Event_baseline=Significant(:,i)==0; % remove resting period
Event_uncertainty=mean(Event_raw_exp2(Event_baseline,i));
Event_filtered_exp2(:,i)=(Event_raw_exp2(:,i)-Event_uncertainty).*Significant(:,i);

e = find(Event_filtered_exp2(:,i)>0);
threshold(i) = mean(Event_filtered_exp2(e,i)) + std(Event_filtered_exp2(e,i)); %threshold,可以更改小一些

  for j=1:FrameNum

        if Significant(j,i) == 0
          Event_filtered_exp2(j,i) = 0;
        end
        if Event_filtered_exp2(j,i) <= threshold(i)
          Event_filtered_exp2(j,i) = 0;
        end

  end
  
  
  Outliers=Event_filtered_exp2(:,i)>2*prctile(Event_filtered_exp2(:,i),99.9);
  Event_filtered_exp2(Outliers,i)=prctile(Event_filtered_exp2(:,i),99.95);
  dF_F_MAX=max(detaF_F_denoised(:,i));
  Event_MAX=max(Event_filtered_exp2(:,i));
  Event_filtered_exp2(:,i)=Event_filtered_exp2(:,i).*dF_F_MAX./Event_MAX; 
  Event_count(i,1) = length( find(Event_filtered_exp2(:,i)>0));
  
    
    disp(['deconvolution: Cell ',num2str(i), ' Events: ',num2str(Event_count(i,1))]) 
end

%% calculate SNR

for i =1: CellNum
    
RestingPeriod = detaF_F_raw(find(Significant(:,i) == 0 & outlier(:,i) == 0),i);
SignalPeriod = detaF_F_raw(find(Significant(:,i) == 1),i);

Peaks = SignalPeriod(find(SignalPeriod>=prctile(SignalPeriod,99)));  % definition of peaks: large than 99th intensity, large than 2x std of the traces
% Baseline=RawTrancient(find(RawTrancient<prctile(SignalPeriod,1)));  % 
Baseline = RestingPeriod;
Signal = median(Peaks)-median(Baseline);
% FrameDifference=abs(RestingPeriod-circshift(RestingPeriod,1));
% noise=median(FrameDifference); % the extraction of the average noise level is from the paper "A deep learning toolbox for noise-optimized, generalized spike inference from calcium imaging data",https://www.biorxiv.org/content/10.1101/2020.08.31.272450v1
noise = std(detaF_F_raw(:,i)); % t

SNR(i,1) = Signal/noise;
if isnan(SNR(i,1))
    SNR(i,1)=0;
else
    disp(['Noise level is ', num2str(noise),'; Signal level is ',num2str(Signal),'; SNR = ',num2str(SNR(i,1))]);
end
end

%% save results
NeuronActivity.CellNum = CellNum;
NeuronActivity.FrameNum = FrameNum;
NeuronActivity.F_raw = F_raw;
NeuronActivity.F_raw_Iscell = F_raw_Iscell;
NeuronActivity.F_zero = F_zero;
NeuronActivity.F_zero_z = F_zero_z;
NeuronActivity.detaF_F_denoised = detaF_F_denoised;
NeuronActivity.detaF_F_raw = detaF_F_raw;
NeuronActivity.detaF_F_denoised_deconv = detaF_F_denoised_deconv;
NeuronActivity.Significant = Significant;
NeuronActivity.Event_filtered_exp2 = Event_filtered_exp2;
NeuronActivity.Event_raw_exp2 = Event_raw_exp2;
NeuronActivity.Event_count = Event_count;
NeuronActivity.SNR = SNR;
NeuronActivity.outlier = outlier;
NeuronActivity.timestamps = timestamps;

save([pwd,'\',foldername,'\','NeuronActivity.mat'],'NeuronActivity')
