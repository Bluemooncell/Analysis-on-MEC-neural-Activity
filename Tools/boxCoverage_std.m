% Calculate the amount of the box the rat has covered
function [coverage,std] = boxCoverage_std(posx, posy, binWidth, frameRate)

minX = nanmin(posx);
maxX = nanmax(posx);
minY = nanmin(posy);
maxY = nanmax(posy);

% Side lengths of the box
xLength = maxX - minX;
yLength = maxY - minY;

% Number of bins in each direction
colBins = ceil(xLength/binWidth);
rowBins = ceil(yLength/binWidth);

% Allocate memory for the coverage map
coverageMap = zeros(rowBins, colBins);
rowAxis = zeros(rowBins,1);
colAxis = zeros(colBins,1);

% Find start values that centre the map over the path
xMapSize = colBins * binWidth;
yMapSize = rowBins * binWidth;
xOff = xMapSize - xLength;
yOff = yMapSize - yLength;

xStart = minX - xOff / 2;
xStop = xStart + binWidth;

for r = 1:rowBins
    rowAxis(r) = (xStart + xStop) / 2;
    ind = find(posx >= xStart & posx < xStop);
    yStart = minY - yOff / 2;
    yStop = yStart + binWidth;
    for c = 1:colBins
        colAxis(c) = (yStart + yStop) / 2;
        coverageMap(r,c) = length(find(posy(ind) > yStart & posy(ind) < yStop));
        yStart = yStart + binWidth;
        yStop = yStop + binWidth;
    end
    xStart = xStart + binWidth;
    xStop = xStop + binWidth;
end

%if boxType == 1
    coverage = length(find(coverageMap > 0)) / (colBins*rowBins) * 100;
    std = nanstd(coverageMap,0,'all')/frameRate;
% else
%     fullMap = zeros(rowBins, colBins);
%     for r = 1:rowBins
%         for c = 1:colBins
%             dist = sqrt(rowAxis(r)^2 + colAxis(c)^2);
%             if dist > radius
%                 fullMap(r,c) = NaN;
%                 coverageMap(r, c) = NaN;
%             end
%         end
%     end
%     numBins = sum(sum((isfinite(fullMap))));
%     coverage = (length(find(coverageMap > 0)) / numBins) * 100;
%     
end