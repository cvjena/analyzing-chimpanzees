function str_out = feature_extractor_precomputed_CNN_activations ( image, str_boxes, str_settings )
% BRIEF
%   Select a single row out of a matrix of pre-computed features
%
% INPUT
%  image       -- mandatory, color image or gray value image, given as matrix 
%  str_boxes    -- optional, struct with boxes that describe subimages 
%                  from which we extract CNN activatsions
%                  not used here!
%  str_settings -- mandatory, struct with settings. supported fields are:
%    .s_destFeat  -- filename, location of features to be loaded (will be loaded as persistent to reduce I/O)
%    .idx_of_img  -- optional, idx to select from the pre-computed
%                    features. Only useful if feature are extracted from
%                    the entire image.
%                    if not provided, .s_imagesUncropped and .s_fn are
%                    required where s_imagesUncropped is the list of names
%                    from the  original dataset with potentially multiple regions per
%                    image and s_fn is the specific filename of a single
%                    image from that set.
%                    Only useful if feature have been pre-computed for
%                    images with multiple regions
%
% OUTPUT
%   str_out    -- struct with the following fields:
%      .features - double matrix, as many rows as detections in the image
%

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
    
    idx_of_img = getFieldWithDefault ( str_settings, 'idx_of_img', 0 );
    if ( idx_of_img < 1 )
        idxImgUncropped    = find( strcmp ( str_settings.s_imagesUncropped, str_settings.s_fn ) );

        s_search_pattern   = sprintf ( '-id%d-', idxImgUncropped );

        idxOfCroppedImages = ~cellfun ( @isempty, strfind ( str_settings.dataset.s_images, s_search_pattern ) );   
        idx_of_img         = idxOfCroppedImages;
    end
    
    features           = featCNN(:,idx_of_img);
    
    assert( ~isempty(features) , 'No CNN activations for given image found!' );
    
    
    %% assign outputs
    str_out.features = features;
end