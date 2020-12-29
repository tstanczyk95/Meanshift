function peak = findpeak(data, idx, r);
%FINDPEAK find peak
%   Find density peak for the specified point with respect to all points 
%      in the dataset
%
%   Parameters: 
%       data: a matrix containing points with respect to which the density
%         peak is to be computed, point-per-row format is expected
%       r: search window radius
%       idx: a row index of the point in data matrix, for which the density
%          peak is to be computed
%   Output:
%       peak: a vector describing the location of the peak found

  THRESHOLD = 0.01;
  shift = max(max(data)) - min(min(data));
  
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
  end
  
  peak = point;
endfunction
