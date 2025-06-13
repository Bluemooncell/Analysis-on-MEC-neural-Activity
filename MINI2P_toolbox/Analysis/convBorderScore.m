function convb = convBorderScore(g_map)
[X,Y] = size(g_map);
[xM,yM]=meshgrid(1:X,1:Y);
xM = min(xM,X+1-xM);
yM = min(yM,Y+1-yM);
M = min(xM, yM);
M=1./M;
    g_map = g_map/nansum(g_map(:));
    convb = nansum(g_map(:).*M(:));
end