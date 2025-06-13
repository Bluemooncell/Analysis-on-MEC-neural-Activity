% Calculate statistics of a rate map that depend on probability distribution function (PDF)
%
% Calculates information, sparsity and selectivity of a rate map. Calculations are done
% according to 1993 Skaggs et al. "An Information-Theoretic Approach to Deciphering the Hippocampal Code"
% paper. Another source of information is 1996 Skaggs et al. paper called
% "Theta phase precession in hippocampal neuronal populations and the compression of temporal sequences".
%
%  USAGE
%   [information, sparsity, selectivity] = analyses.mapStatsPDF(map)
%   map             Structure with rate map, output of analyses.map
%   information     Structure with fields:
%       rate        information rate [bits/sec]
%       content     Spatial information content [bits/spike]
%   sparsity        Sparsity value
%   selectivity     Selectivity value
%
%  SEE
%   See also analyses.map

%Modified to adjust spatial information  for HD cells. TJY,2023-7-25 
%
function [information, sparsity, selectivity] = TuningCurveStatsPDF(tuningCurve)
%     if ~isstruct(map)
%         error('BNT:arg', 'Incorrect argument. Map should be a structure. You are probably relying on old code when mapStatsPDF accepted map as matrix.');
%     end
    F = nansum(tuningCurve(:,3)); % overall trial duration
    posPDF = tuningCurve(:,3) ./ F; % probability of animal being in bin x:
                                 % duration of time animal spent in the bin divided by overall trial duration.
    
    meanrate = nansum(tuningCurve(:,2) .* posPDF);
    meansquarerate = nansum( (tuningCurve(:,2) .^ 2) .* posPDF );
    if meansquarerate == 0
       sparsity = NaN;
    else
        sparsity = meanrate^2 / meansquarerate;
    end

    maxrate = nanmax(tuningCurve(:,2));
    if meanrate == 0;
       selectivity = NaN;
       information.content = nan;
       information.rate = nan;
    else
       selectivity = maxrate / meanrate;
       logArg = tuningCurve(:,2) ./ meanrate;
       logArg(logArg < 1) = 1;
       
       information.rate = nansum(posPDF .* tuningCurve(:,2) .* log2(logArg));
       information.content = information.rate / meanrate;
    end
end
