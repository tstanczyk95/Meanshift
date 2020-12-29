function [peak, cpts] = findpeak_opt(data, idx, r, c=4)
%FINDPEAK_OPT find peak with optimized appraoch
%   Find density peak for the specified point with respect to all points 
%      in the dataset. Incorporate speedup assigning also all the points
%      on the search path to the found peak.
%
%   Parameters: 
%       data: a matrix containing points with respect to which the density
%         peak is to be computed, point-per-row format is expected
%       r: search window radius
%       idx: a row index of the point in data matrix, for which the density
%          peak is to be computed
%       c: divisor of the radius contributing to the inner circle size, which
%          will determine the points on the search path to be assigned to the
%          found peak
%   Output:
%       peak: a vector describing the location of the peak found
%       cpts: a vector of 0s and 1s indicating for each point whether it is
%       to be assigned to the found peak

  THRESHOLD = 0.01;
  printf("%d",c);
  shift = max(max(data)) - min(min(data));
  cpts = zeros(size(data, 1), 1);
  
  point = data(idx, :);
  
  while shift > THRESHOLD
    currentDinstances = pdist2(data, point, 'euclidean');
    neighbourhoodPointReferences = find(currentDinstances <= r);
    if (min(size(neighbourhoodPointReferences)) == 0)
      break;
    endif

    meanVector = mean(data(neighbourhoodPointReferences, :), 1);
    shift = pdist([point; meanVector] ,'euclidean');
    point = meanVector;
    
    % Mark points on (the current area of) the search path to the peak
    currentPathAreaPointReferences = find(currentDinstances <= r / c);
    cpts(currentPathAreaPointReferences) = 1;
  end
  
  peak = point;
endfunction
