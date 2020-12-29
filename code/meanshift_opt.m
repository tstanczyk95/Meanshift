function [labels, peaks] = meanshift_opt(data, r, c=4)  
%MEANSHIFT meanshift
%   Find a peak for reach point in the dataset and assign the each point's 
%     label according to its peak. Incorporate basin of attraction speedup.
%
%   Parameters: 
%       data: a matrix containing points with respect to which the density
%         peaks are to be computed, point-per-row format is expected
%       r: search window radius
%       c: divisor of the radius contributing to the inner circle size, which
%          will determine the points on the search path to be assigned to the
%          found peak (passed to findpeak_opt)
%   Output:
%       labels: a vector indicating a peak associated to each data point
%       peaks: matrix containing all the peaks found during the meanshift run,
%         peak-per-row and feature-per-column format is returned

  labels = zeros(size(data, 1), 1);
  
  labels = zeros(size(data, 1), 1);
  
  labels(1) = 1;
  [firstPeak, cpts] = findpeak_opt(data, 1, r, c);
  
  distancesFromPeak = pdist2(data, data(1, :), 'euclidean'); % include all points
  neighbourhoodPointReferences = distancesFromPeak <= r; %s binary mask for r-distance
  
  neigbourhoodOrPathSearchMask = or(neighbourhoodPointReferences, cpts);
  
  neigbourhoodOrPathSearchMask(1) = 0; % exclude 1st point from its close neighbours and path search
  
  labels(neigbourhoodOrPathSearchMask) = 1;
    
  peaks = [firstPeak];  
  
  for i = 2:size(data, 1)
    printf("Pixel nr %d / %d\r", i, size(data,1));
    % Exclude already labeled points
    if (labels(i) != 0)
      continue
    endif
    
    [currentPeak, cpts] = findpeak_opt(data, i, r, c);
   
    distances = sqrt(sum((peaks - currentPeak) .^ 2, 2)); # Euclidean distances per entry (per peak)
    shortDistances = distances < r / 2;
    
    if (sum(shortDistances) == 0)
      % Add new peak
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
      labels(i) = peakIndex;
    endif
    
    
    % When assigning current point to a peak, assign its close neighbours as well (unless already assigned)
    zeroLabelPoints = labels == 0; # binary mask for non-labeled points
    distancesFromPeak = pdist2(data, data(i, :), 'euclidean'); % initially, consider all points
    neighbourhoodPointReferences = distancesFromPeak <= r; % binary mask for r-distance
    
    neigbourhoodOrPathSearchMask = or(neighbourhoodPointReferences, cpts);
    
    completeMask = and(zeroLabelPoints, neigbourhoodOrPathSearchMask);
    labels(completeMask) = labels(i);    
  endfor
endfunction