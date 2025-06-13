
clear;
clc;
load([pwd,'\HD-data\intra_baseline_HD99All_re.mat']);
load([pwd,'\HD-data\Ratemap_HD99All_re.mat']);

load([pwd,'\HD-data\corrValue_shuffle_s12.mat']);
correlation = corrValue_true;
load([pwd,'\HD-data\corrValue_shuffle_s23.mat']);
correlation = [correlation,corrValue_true];
MVL = [intra_baseline_HD99All{1}(:,5),intra_baseline_HD99All{2}(:,5),intra_baseline_HD99All{3}(:,5)];
MVL_change = [abs(MVL(:,2) - MVL(:,1)),abs(MVL(:,3) - MVL(:,2))];
PFD = NaN(size(intra_baseline_HD99All{1},1),4);
for i = 1:4
    for j = 1:size(PFD,1)
       PFD(j,i) = Ratemap_HD99All{i}.tcStat{1,j}.peakDirection;
    end
end
PFD_change = zeros(size(correlation,1),2);
for j = 1:2
   for i = 1:size(correlation,1)
        angle = PFD(i,j+1) - PFD(i,j);
        if angle >= -180 && angle <= 180
            PFD_change(i,j) = angle;
        elseif angle > 180
            PFD_change(i,j) = -(360 - angle);
        else  angle < -180
            PFD_change(i,j) = 360 + angle;
        end
   end
end


PFD_change = abs(PFD_change);
%% GMM

X = [correlation,MVL_change];
x = zscore(X);
[n,p] = size(X);


rng('default');
k = 3; % Number of GMM components
options = statset('MaxIter',1000);
Sigma = {'diagonal','full'}; % Options for covariance matrix type
nSigma = numel(Sigma);

SharedCovariance = {true,false}; % Indicator for identical or nonidentical covariance matrices
SCtext = {'true','false'};
nSC = numel(SharedCovariance);
% d = 500; % Grid length
% x1 = linspace(min(X(:,1))-0.5, max(X(:,1))+0.5, d);
% x2 = linspace(min(X(:,2))-0.5, max(X(:,2))+0.5, d);
% % x3 = linspace(min(X(:,3))-0.5, max(X(:,3))+0.5, d);
% [x1grid,x2grid] = ndgrid(x1,x2);
% X0 = [x1grid(:) x2grid(:)]; % Grid points with three columns
% threshold = sqrt(chi2inv(0.99,2)); % Adjust threshold for three-dimensional space
count = 1;
figure;

%purple blue+blue+green blue
C1 = [145/255 225/255 226/255];   %Green
C2 = [100/255 190/255 255/255]; %blue
C3 = [134/255 155/255 255/255]; %purple
C = [C1;C2;C3];
for i = 1:nSigma
    for j = 1:nSC
        gmfit = fitgmdist(x,k,'CovarianceType',Sigma{i}, ...
            'SharedCovariance',SharedCovariance{j},'Options',options); % Fitted GMM
        clusterX = cluster(gmfit,x); % Cluster index 
%         mahalDist = mahal(gmfit,X0); % Distance from each grid point to each GMM component
        % Draw ellipsoids over each GMM component and show clustering result.
        subplot(4,2,count);
        coeff = pca(x, 'NumComponents', 2);
        X_pca = x * coeff;

% 绘制二维散点图
       subplot(4,2,count)
       h = gscatter(X_pca(:,1), X_pca(:,2),clusterX,C,'.',20);
       colormap(C);
%         colorbar;
       legend(h,'Cluster1','Cluster2','Cluster3');
       xlabel('PC 1');
       ylabel('PC 2');
       title(sprintf('Sigma is %s\nSharedCovariance = %s AIC:%.2f\nBIC:%.2f',Sigma{i},SCtext{j},gmfit.AIC,gmfit.BIC),'FontSize',8);   
       ax = gca;
      
        subplot(4,2,count+1);
        silhouette(x,clusterX);
        count = count + 2;
       
        silhouetteValues = silhouette(x, clusterX);
        
        chIndex = evalclusters(x, clusterX, 'CalinskiHarabasz');
        
        meanSilhouette = mean(silhouetteValues);
       
        calinskiHarabaszIndex = chIndex.CriterionValues;
         title(sprintf('mean silhouette: %.2f\nCalinski-Harabasz: %.2f', meanSilhouette, calinskiHarabaszIndex), 'FontSize', 8);
         

        
        
        end
end

%% distribution
figure
i = 1;
j = 1;
gmfit = fitgmdist(x,k,'CovarianceType',Sigma{i}, ...
            'SharedCovariance',SharedCovariance{j},'Options',options); % Fitted GMM
clusterX = cluster(gmfit,x); % Cluster index 

cluster1 = find(clusterX == 1);        
cluster2 = find(clusterX == 2);
cluster3 = find(clusterX == 3);
cluster1_initial = cluster1,cluster2_initial=cluster2,cluster3_initial = cluster3;
 silhouette(x,clusterX);

silhouetteValues = silhouette(x, clusterX);

chIndex = evalclusters(x, clusterX, 'CalinskiHarabasz');

meanSilhouette = mean(silhouetteValues);

calinskiHarabaszIndex = chIndex.CriterionValues;
h = gscatter(X_pca(:,1), X_pca(:,2),clusterX,C,'.',20);

%  colormap(C);
%         colorbar;
legend(h,'Cluster1','Cluster2','Cluster3');
xlabel('PC 1');
ylabel('PC 2');
% title(sprintf('Sigma is %s\nSharedCovariance = %s AIC:%.2f\nBIC:%.2f',Sigma{i},SCtext{j},gmfit.AIC,gmfit.BIC),'FontSize',8); 

% title(sprintf('mean silhouette: %.2f\nCalinski-Harabasz: %.2f', meanSilhouette, calinskiHarabaszIndex), 'FontSize', 8);
ax = gca;
xlim([-5,3]);
ylim([-3,5.5]);
ax.XTick = [-5 0 3];
ax.YTick = [0 5];
      
X_pca_initial = X_pca;
clusterX_initial = clusterX;




