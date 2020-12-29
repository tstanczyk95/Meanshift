function [labels, peaks] = meanshift(data, r)
%MEANSHIFT meanshift
%   Find a peak for reach point in the dataset and assign the each point's 
%     label according to its peak.
%
%   Parameters: 
%       data: a matrix containing points with respect to which the density
%         peaks are to be computed, point-per-row format is expected
%       r: search window radius
%   Output:
%       labels: a vector indicating a peak associated to each data point
%       peaks: matrix containing all the peaks found during the meanshift run,
%         peak-per-row and feature-per-column format is returned

  labels = zeros(size(data, 1), 1);
  
  labels(1) = 1;
  firstPeak = findpeak(data, 1, r);
  peaks = [firstPeak];  
  
  for i = 2:size(data, 1)
    printf("Pixel nr %d / %d\r", i, size(data,1));
    currentPeak = findpeak(data, i, r);
    
    distances = sqrt(sum((peaks - currentPeak) .^ 2, 2)); % Euclidean distances per entry (per peak)
    shortDistances = distances < r / 2;
    
    if (sum(shortDistances) == 0)
      % Add a new peak
      labels(i) = max(labels) + 1;
      peaks = [peaks; currentPeak];    
    elseif (sum(shortDistances) == 1) 
      % Assign to the indicated peak
      peakIndex = find(shortDistances == 1);
      labels(i) = peakIndex;
    else % More than one peaks are matching
      % Assign to the peak with the shortest distance
      
      shortestDistance = min(distances);
      
      peakIndex = find(distances == shortestDistance);
      labels(i) = peakIndex(1);
    endif
  endfor
endfunction
