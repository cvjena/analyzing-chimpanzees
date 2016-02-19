function str_out = feature_extractor_CNN_activations ( image, str_boxes, str_settings )
% BRIEF
% specifically tailored to the chimpanzee dataset and the naming
% convention!

    %% get specifications
    s_layer = getFieldWithDefault ( str_settings, 's_layer', 'pool5' );
    f_mean  = getFieldWithDefault ( str_settings, 'f_mean', [] );

    %% crop detections from given image
    
    for idx=size ( str_boxes.i_face_regions, 1):-1:1
        subimg = imcrop ( image, [   str_boxes.i_face_regions(idx,1) ...
                                     str_boxes.i_face_regions(idx,2) ...
                                     str_boxes.i_face_regions(idx,3) ...
                                     str_boxes.i_face_regions(idx,4) ...
                                 ] );


        [ features_tmp ] = caffe_features_single_image( subimg, f_mean, str_settings.net, s_layer );
        if ( ~exist ( 'features', 'var' ) )
            features = zeros ( size(features_tmp,1), size ( str_boxes.i_face_regions, 1) );
        end
        features ( :, idx ) = features_tmp;
    end
        
    
    %% assign outputs
    str_out.features = features;
end