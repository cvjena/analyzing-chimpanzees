function str_out = feature_extractor_precomputed_CNN_activations ( image, str_boxes, str_settings )
% BRIEF
% specifically tailored to the chimpanzee dataset and the naming
% convention!

    if ( ~isfield ( str_settings, 's_destFeat' ) )
        error ( 's_destFea	 not specified in settings!') 
    end
    
    persistent featCNN;
    if ( isempty ( featCNN ) )
        featCNN = load ( str_settings.s_destFeat);
        
        if ( isfield ( featCNN, 'struct_feat' ) ) % compatibility with MatConvNet
            featCNN = cell2mat(featCNN.struct_feat);
        elseif ( isfield ( featCNN, 'feat' ) && isfield ( featCNN.feat, 'name' ) )   % compatibility with Caffe
            featCNN = featCNN.feat.(featCNN.feat.name);
        else
            error ( 'CNN features not readable!' )
        end        
    end
    
    
    idxImgUncropped    = find( strcmp ( str_settings.s_imagesUncropped, str_settings.s_fn ) );
    
    s_search_pattern   = sprintf ( '-id%d-', idxImgUncropped );
    
    idxOfCroppedImages = ~cellfun ( @isempty, strfind ( str_settings.dataset.s_images, s_search_pattern ) );
    
    features           = featCNN(:,idxOfCroppedImages);
    
    assert( ~isempty(features) , 'No CNN activations for given image found!' );
    
    
    %% assign outputs
    str_out.features = features;
end