function am = angleSmooth(a, angleType, smoothMethod, smoothWindow, nanFlag)
% This function is used to smooth a list of angles.

% Input: a: must be a vector;
%        angleType: 'deg', degree;
%                   'rad', radians (default);
%        smoothMethod: the method of function 'smoothdata', default is
%                      'movmean';
%        smoothWindow: the window of function 'smoothdata', default is 15;
%        nanFlag: 0, 'omitnan' (default);
%                 1, 'includenan';

% Created by Xiang Zhang, 2021.

% verify inputs;
[a_row, a_column] = size(a);
if a_row < 5 && a_column < 5
    error('The size of input angles is too small.');
elseif ~isvector(a)
    error ('The input angles must be a vector.');
elseif a_row == 1
    a = a';
    a_row = a_column;
    % a_column = 1;
end

% verify angles in degrees or radians;
switch angleType
    case 'deg'
        a = deg2rad(a);
%     case 'rad'
%         a = a;
end

% verify input of smooth;
if isempty(smoothMethod)
    smoothMethod = 'movmean';
end
if isempty(smoothWindow)
    smoothWindow = 15;
end
switch nanFlag
    case 0
        nanFlag = 'omitnan';
    case []
        nanFlag = 'omitnan';
    case 1
        nanFlag = 'includenan';
end

% transform angles to vectors;
a_vector = zeros(a_row, 2);
a_vector(:,1) = cos(a);
a_vector(:,2) = sin(a);

% smooth angles in vectors;
a_vector_smooth = zeros(a_row, 2);
a_vector_smooth(:,1) = smoothdata(a_vector(:,1), smoothMethod, smoothWindow, nanFlag);
a_vector_smooth(:,2) = smoothdata(a_vector(:,2), smoothMethod, smoothWindow, nanFlag);

% transform vectors to angles;
am = atan2(a_vector_smooth(:,2), a_vector_smooth(:,1));

switch angleType
    case 'deg'
        am = mod(rad2deg(am), 360);
    case 'rad'
        am = mod(am, 2*pi);
end
end