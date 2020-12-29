function [segmIm, labels, peaks] = imSegment(im, r, feature_type, enable_optimization, c=4);
%IMSEGMENT image segmentation.
%   Description of its functionaility is given in the assignment
%
%   Parameters: 
%       im: RGB image
%       r: search window radius
%       feature_type: the feature type to be used during the meanshift run;
%          supported values: '3D', '5D'
%       enable_optimization: a flag indicating whether the optimized mode has to  
%          be applied (1 or any non-zero value) or not - with standard mode to 
%          be used then instead (0)
%       c: divisor of the radius contributing to the inner circle size, which
%          will determine the points on the search path to be assigned to the
%          found peak (passed to meanshift_opt)
%   Output:
%       SegmIm: segmentated image where its pixels' values are colored
%           based on the labels
%		    labels: a vector indicating a peak associated to each data point
%		    Peaks:  matrix containing all the peaks found during the meanshift run,
%           peak-per-row and feature-per-column format is returned
   
  imageHeight = size(im, 1);
  imageWidth = size(im, 2);

  im_lab = rgb2lab(im);

  im_r = im_lab(:,:,1)(:);
  im_g = im_lab(:,:,2)(:);
  im_b = im_lab(:,:,3)(:);
  
  if (strcmp(feature_type, '3D'))
    im_v = [im_r im_g im_b];  
  elseif (strcmp(feature_type, '5D'))
    x_row = [1:1:imageWidth];
    X = repmat(x_row, imageHeight, 1);
    X_vectorized = X(:);  
    
    y_column = [1:1:imageHeight]';
    
    %Y = repmat(y_column, 1, imageWidth);
    %Y_vectorized = Y(:);
   
    % Result as for the 2 lines above, but faster
    Y_vectorized = repmat(y_column, imageWidth, 1); 

    im_v = [im_r im_g im_b X_vectorized Y_vectorized];
  else
    printf("\n*** Invalid feature type. Supported values: '3D', '5D'. ***\n\n");
    segmIm = []; 
    labels = []; 
    peaks = [];
    return;
  endif

  if (enable_optimization)
    [labels, peaks] = meanshift_opt(im_v, r, c);
  else
    [labels, peaks] = meanshift(im_v, r);
  endif
 
  peaksNumber = size(peaks,1);
  
  for label = 1:peaksNumber
    clusteredPixelsIndices = labels == label;
    
    for column = 1:size(im_v, 2) % only 3 or 5 columns possible
      im_v(clusteredPixelsIndices, column) = peaks(label, column);
    endfor
  endfor
  
  processedImage = reshape(im_v(:,1:3), imageHeight, imageWidth, 3);
  
  segmIm = lab2rgb(processedImage);
endfunction
