<<<<<<< HEAD
% decoding tecture identitiy based on population vectore of MEC neurons
clear;
path = pwd;
% load
load([path, '\322_t1_all\method2\NeuronActivity.mat']);
N1 = NeuronActivity;
load([pwd, '\322_t1_all\stimu_idx_2p_all.mat']);
stimu_idx1 = stimu_idx_2p_all;

load([path, '\322_t2_all\method2\NeuronActivity.mat']);
N2 = NeuronActivity;
load([pwd, '\322_t2_all\stimu_idx_2p_all.mat']);
stimu_idx2 = stimu_idx_2p_all;

%% mean_FR
N1.Event_filtered_exp2(isnan(N1.Event_filtered_exp2)) = 0;
N2.Event_filtered_exp2(isnan(N2.Event_filtered_exp2)) = 0;

Event1 = logical(N1.Event_filtered_exp2);  % [35000 x n]
Event2 = logical(N2.Event_filtered_exp2);  

num_neurons = size(Event1, 2);
num_trials = size(stimu_idx1, 1);

% Make sure the number of frames in Event1 can be evenly divided by num_trials.
num_repeats = 100;
accuracy_matrix = zeros(1, num_repeats);
bin_length = 540;
accuracy_matrix = zeros(1, num_repeats); 

X1_trials = zeros(num_neurons, num_trials, bin_length);
X2_trials = zeros(num_neurons, num_trials, bin_length);


for i = 1:num_trials
    start_idx = stimu_idx1(i, 1);
    end_idx = start_idx + bin_length - 1;
    X1_trials(:, i, :) = Event1(start_idx:end_idx, :)';
end

for i = 1:num_trials
    start_idx = stimu_idx2(i, 1);
    end_idx = start_idx + bin_length -1;
    X2_trials(:, i, :) = Event2(start_idx:end_idx, :)';
end

% X1_trials(isinf(X1_trials)) = 0;
% X2_trials(isinf(X2_trials)) = 0;

X1_trials_avg = squeeze(mean(X1_trials, 3));  % [num_neurons, num_trials]，
X1_trials_avg = X1_trials_avg';  % [num_trials x num_neurons]

X2_trials_avg = squeeze(mean(X2_trials, 3));
X2_trials_avg = X2_trials_avg';

X_all = [X1_trials_avg; X2_trials_avg];
labels = [ones(num_trials,1); zeros(num_trials,1)];

[coeff, score] = pca(X_all);
% num_components = 60;  %
% features = score(:, 1:num_components);  %
features = X_all; 
rng(5)

for repeat = 1:num_repeats
    
    cv = cvpartition(labels, 'HoldOut', 0.2);
    train_idx = training(cv);
    test_idx = test(cv);
    
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

mean_accuracy = mean(accuracy_matrix, 2);
std_accuracy = std(accuracy_matrix,0,2);
sem_accuracy = std_accuracy/sqrt(num_repeats);

=======
% decoding tecture identitiy based on population vectore of MEC neurons
clear;
path = pwd;
% load
load([path, '\322_t1_all\method2\NeuronActivity.mat']);
N1 = NeuronActivity;
load([pwd, '\322_t1_all\stimu_idx_2p_all.mat']);
stimu_idx1 = stimu_idx_2p_all;

load([path, '\322_t2_all\method2\NeuronActivity.mat']);
N2 = NeuronActivity;
load([pwd, '\322_t2_all\stimu_idx_2p_all.mat']);
stimu_idx2 = stimu_idx_2p_all;

%% mean_FR
N1.Event_filtered_exp2(isnan(N1.Event_filtered_exp2)) = 0;
N2.Event_filtered_exp2(isnan(N2.Event_filtered_exp2)) = 0;

Event1 = logical(N1.Event_filtered_exp2);  % [35000 x n]
Event2 = logical(N2.Event_filtered_exp2);  

num_neurons = size(Event1, 2);
num_trials = size(stimu_idx1, 1);

% Make sure the number of frames in Event1 can be evenly divided by num_trials.
num_repeats = 100;
accuracy_matrix = zeros(1, num_repeats);
bin_length = 540;
accuracy_matrix = zeros(1, num_repeats); 

X1_trials = zeros(num_neurons, num_trials, bin_length);
X2_trials = zeros(num_neurons, num_trials, bin_length);


for i = 1:num_trials
    start_idx = stimu_idx1(i, 1);
    end_idx = start_idx + bin_length - 1;
    X1_trials(:, i, :) = Event1(start_idx:end_idx, :)';
end

for i = 1:num_trials
    start_idx = stimu_idx2(i, 1);
    end_idx = start_idx + bin_length -1;
    X2_trials(:, i, :) = Event2(start_idx:end_idx, :)';
end

% X1_trials(isinf(X1_trials)) = 0;
% X2_trials(isinf(X2_trials)) = 0;

X1_trials_avg = squeeze(mean(X1_trials, 3));  % [num_neurons, num_trials]，
X1_trials_avg = X1_trials_avg';  % [num_trials x num_neurons]

X2_trials_avg = squeeze(mean(X2_trials, 3));
X2_trials_avg = X2_trials_avg';

X_all = [X1_trials_avg; X2_trials_avg];
labels = [ones(num_trials,1); zeros(num_trials,1)];

[coeff, score] = pca(X_all);
% num_components = 60;  %
% features = score(:, 1:num_components);  %
features = X_all; 
rng(5)

for repeat = 1:num_repeats
    
    cv = cvpartition(labels, 'HoldOut', 0.2);
    train_idx = training(cv);
    test_idx = test(cv);
    
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

mean_accuracy = mean(accuracy_matrix, 2);
std_accuracy = std(accuracy_matrix,0,2);
sem_accuracy = std_accuracy/sqrt(num_repeats);

>>>>>>> 342f783 (Include MINI2P_toolbox as a regular foloder)
