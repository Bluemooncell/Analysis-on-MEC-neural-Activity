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


end
