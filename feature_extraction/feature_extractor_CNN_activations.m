function str_out = feature_extractor_CNN_activations ( image, str_boxes, str_settings )
% BRIEF
%   Run a forward pass of a specified CNN for every region and grep the network's
%   activations in a specific layer as image representation.
%
% INPUT
%  image       -- mandatory, color image or gray value image, given as matrix 
%  str_boxes    -- optional, struct with boxes that describe subimages 
%                  from which we extract CNN activatsions
%                  default: use entire image
%  str_settings -- optional, struct with settings. supported fields are:
%    .str_settingsCaffe
%    .f_mean
%
% OUTPUT
%   str_out    -- struct with the following fields:
%      .features - double matrix, as many rows as detections (specified by str_boxes)
%


    %% get specifications
    
    if ( nargin < 2 )
        str_boxes = [];
    end
    
    if ( nargin < 3 )
        str_settings = [];
    end    
    
    str_settingsCaffe = getFieldWithDefault ( str_settings, 'str_settingsCaffe', [] );
    f_mean            = getFieldWithDefault ( str_settings, 'f_mean', [] );
    
    
    % if no box is provided, we extract feature from the entire image
    if ( isempty( str_boxes ) )
        str_boxes.i_face_regions = [1, 1, size( image,2 ), size( image, 1 ) ];
    end
    

    %% crop detections from given image
        
    for idx=size ( str_boxes.i_face_regions, 1):-1:1
        subimg = imcrop ( image, [   str_boxes.i_face_regions(idx,1) ...
                                     str_boxes.i_face_regions(idx,2) ...
                                     str_boxes.i_face_regions(idx,3) ...
                                     str_boxes.i_face_regions(idx,4) ...
                                 ] );


        [ features_tmp ] = caffe_features_single_image( subimg, f_mean, str_settings.net, str_settingsCaffe );
        if ( ~exist ( 'features', 'var' ) )
            features = zeros ( size(features_tmp,1), size ( str_boxes.i_face_regions, 1) );
        end
        features ( :, idx ) = features_tmp;
    end
        
    
    %% assign outputs
    str_out.features = features;
end