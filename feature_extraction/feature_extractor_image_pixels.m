function str_out = feature_extractor_image_pixels ( image, str_boxes, str_settings )
% BRIEF
%  Crop subimages according to the provided detections and return the subimage without further processing
% 
%  INPUT
%   image      -- color image or gray value image, given as matrix 
%
%   str_boxes  -- struct with at least the following fields
%        .i_face_regions    - kx4 double array , columns
%                             indicate [xleft ytop width height]
%
%   str_settings --  struct, optional, where the following fields are supported
%        .b_scale_detections - optional, defaults to false
%        .i_detection_width  - optional, defaults to 227, only required if b_scale_detections=true
%        .i_detection_height - optional, defaults to 227, only required if b_scale_detections=true
%
% OUTPUT
%   str_out    -- struct with the following fields:
%      .features - cell array of size equal to the number of detections, 
%                  each cell contains a matrix of type and dimensionality equal to the input image, 
%                  width and height equal to the detections (or scaled)
%

   %% fetch inputs
    if ( nargin < 3 ) 
	str_settings = [];
    end
    
    b_scale_detections = getFieldWithDefault ( str_settings, 'b_scale_detections', false );
    i_detection_width  = getFieldWithDefault ( str_settings, 'i_detection_width', 227 );
    i_detection_height = getFieldWithDefault ( str_settings, 'i_detection_height', 227 );    
    

    %% prepare outputs
    features = {};
    
    
    %% crop subimages, convert, and store
    for idx=size ( str_boxes.i_face_regions, 1):-1:1
	subimg = imcrop ( image, [   str_boxes.i_face_regions(idx,1) ...
	                             str_boxes.i_face_regions(idx,2) ...
	                             str_boxes.i_face_regions(idx,3) ...
	                             str_boxes.i_face_regions(idx,4) ...
	                         ] );
	                         
	if ( b_scale_detections )
	    % to support gray value and color images
	    i_size = size ( subimg );
	    i_size ( 1 ) = i_detection_height;
	    i_size ( 2 ) = i_detection_width;
	    %FIXME - use valid scaling method!
	    subimg = scale ( subimage, i_size );
	end
	
	features{idx} = subimg;
    end
    
    %% assign outputs
    str_out.features = features;
end