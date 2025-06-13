<<<<<<< HEAD

clear;
path = pwd; 
% load data
load([path,'\322_t1_all\method2\pawX_change_all.mat']);
P1 = pawX_change_all;
load([pwd,'\322_t1_all\stimu_idx_side_all.mat']);
stimu_idx1 = stimu_idx_side_all; 

load([path, '\322_t2_all\method2\pawX_change_all.mat']);
P2 = pawX_change_all;
load([pwd, '\322_t2_all\stimu_idx_side_all.mat']);
stimu_idx2 = stimu_idx_side_all; 
num_trials = size(stimu_idx1, 1);  

num_repeats = 100;  %
accuracy_matrix = zeros(1, num_repeats);  
load([pwd, '\322_t1_1\whisker_side\timestamps_side_aligned.mat']);

FrameRate = 1/mean(diff(timestamps_side_aligned));
bin_length = round(60 * FrameRate);
% FrameRate = 45;
% bin_length = round(60 * FrameRate);

X1_trials = zeros(num_trials, bin_length);
X2_trials = zeros(num_trials, bin_length);

for i = 1:num_trials
    start_idx = stimu_idx1(i, end) - bin_length +1;
    end_idx =  stimu_idx1(i, end);
%     end_idx = min(end_idx,length(P1));
    X1_trials(i, :) = P1(start_idx:end_idx, :)';
end

for i = 1:num_trials
   start_idx = stimu_idx2(i, end) - bin_length+1;
    end_idx =  stimu_idx2(i, end);
    X2_trials(i, :) = P2(start_idx:end_idx, :)';
end

X1_trials(isinf(X1_trials)) = 0;
X2_trials(isinf(X2_trials)) = 0;

  
% [2*num_trials x num_neurons]
X_all = [X1_trials;X2_trials];
labels = [ones(num_trials,1); zeros(num_trials,1)];

 features = X_all; % 
 rng(5)
    for repeat = 1:num_repeats
        
        
        cv = cvpartition(labels, 'HoldOut', 0.2);
          train_idx = training(cv);
            test_idx = test(cv);
        % 
        X_train = features(train_idx, :);
        y_train = labels(train_idx);
        X_test = features(test_idx, :);
        y_test = labels(test_idx);
        
       
        svm_model = fitcsvm(X_train, y_train, ...
            'KernelFunction', 'linear', ...
            'Standardize', true, ...
            'ClassNames', [0, 1]);
        
        y_pred = predict(svm_model, X_test);
        accuracy_matrix(repeat) = sum(y_pred == y_test)/length(y_test);
    end
% end

mean_accuracy = mean(accuracy_matrix, 2);      
std_accuracy = std(accuracy_matrix,0,2);     
sem_accuracy = std_accuracy/sqrt(num_repeats); 



=======

clear;
path = pwd; 
% load data
load([path,'\322_t1_all\method2\pawX_change_all.mat']);
P1 = pawX_change_all;
load([pwd,'\322_t1_all\stimu_idx_side_all.mat']);
stimu_idx1 = stimu_idx_side_all; 

load([path, '\322_t2_all\method2\pawX_change_all.mat']);
P2 = pawX_change_all;
load([pwd, '\322_t2_all\stimu_idx_side_all.mat']);
stimu_idx2 = stimu_idx_side_all; 
num_trials = size(stimu_idx1, 1);  

num_repeats = 100;  %
accuracy_matrix = zeros(1, num_repeats);  
load([pwd, '\322_t1_1\whisker_side\timestamps_side_aligned.mat']);

FrameRate = 1/mean(diff(timestamps_side_aligned));
bin_length = round(60 * FrameRate);
% FrameRate = 45;
% bin_length = round(60 * FrameRate);

X1_trials = zeros(num_trials, bin_length);
X2_trials = zeros(num_trials, bin_length);

for i = 1:num_trials
    start_idx = stimu_idx1(i, end) - bin_length +1;
    end_idx =  stimu_idx1(i, end);
%     end_idx = min(end_idx,length(P1));
    X1_trials(i, :) = P1(start_idx:end_idx, :)';
end

for i = 1:num_trials
   start_idx = stimu_idx2(i, end) - bin_length+1;
    end_idx =  stimu_idx2(i, end);
    X2_trials(i, :) = P2(start_idx:end_idx, :)';
end

X1_trials(isinf(X1_trials)) = 0;
X2_trials(isinf(X2_trials)) = 0;

  
% [2*num_trials x num_neurons]
X_all = [X1_trials;X2_trials];
labels = [ones(num_trials,1); zeros(num_trials,1)];

 features = X_all; % 
 rng(5)
    for repeat = 1:num_repeats
        
        
        cv = cvpartition(labels, 'HoldOut', 0.2);
          train_idx = training(cv);
            test_idx = test(cv);
        % 
        X_train = features(train_idx, :);
        y_train = labels(train_idx);
        X_test = features(test_idx, :);
        y_test = labels(test_idx);
        
       
        svm_model = fitcsvm(X_train, y_train, ...
            'KernelFunction', 'linear', ...
            'Standardize', true, ...
            'ClassNames', [0, 1]);
        
        y_pred = predict(svm_model, X_test);
        accuracy_matrix(repeat) = sum(y_pred == y_test)/length(y_test);
    end
% end

mean_accuracy = mean(accuracy_matrix, 2);      
std_accuracy = std(accuracy_matrix,0,2);     
sem_accuracy = std_accuracy/sqrt(num_repeats); 



>>>>>>> 342f783 (Include MINI2P_toolbox as a regular foloder)
