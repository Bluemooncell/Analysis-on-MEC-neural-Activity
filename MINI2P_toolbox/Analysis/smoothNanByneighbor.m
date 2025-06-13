function newmap = smoothNanByneighbor(g_map)
%SMOOTHNANBYNEIGHBOR - Replace nan by average value of its adjacent pixel.
%
%Syntax: newmap = smoothNanByneighbor(g_map)
%
%Inputs:
%   g_map: Original ratemap, expected to be matrix. 
%
%Outputs:
%   newmap: g_map after replace nan by average value of its adjacent pixel.
nrow = size(g_map, 1);
ncol = size(g_map, 2);
idxnan = find(isnan(g_map));
kernel = fspecial('gaussian',[5,5],1);
newmap = g_map;
for ipixel = idxnan'
    [row,col] = ind2sub([nrow, ncol],ipixel);
    vnear = g_map(max(1,row-2):min(nrow,row+2),max(1,col-2):min(ncol,col+2));
    vkernel = kernel((max(1,row-2):min(nrow,row+2))-row+3,(max(1,col-2):min(ncol,col+2))-col+3);
    idx = find(~isnan(vnear));
    newmap(ipixel) = dot(vnear(idx),vkernel(idx))/sum(vkernel(idx));
end

end