function str_out = face_detector_yolo_via_terminal ( image, str_settings )
%  function str_out = face_detector_yolo_via_terminal ( image, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
%     image        -- only required for visualization
%     str_settings -- struct with following fields
%         .s_fn                     -- mandatory, char array, filename to entire image, assumes additional file s_fn.ic  
%         .s_path_to_darknet        -- optional, path to your darknet library (default: './')
%         .s_path_to_cfg            -- optional, filename of config file for the given model (default: './yolo.cfg')
%         .s_path_to_weights        -- optional, filename of learned parameter weights for the given model  (default: './yolo.weights')
%         .s_fn_class_labels        -- optional, filename of list with class names known to the given model (default: './classnames.txt')
%         .s_fn_boxes_tmp           -- optional, file name where temporary detections are written to (default: '/tmp/boxes_tmp.txt')
%         .f_thresh                 -- optional, threshold to accept detections with at least that confidence value (default: 0.2)
%         .f_nms                    -- optional, threshold for non-maximum suppression of detection results (default: 0.5)
%         .b_show_detections        -- optional, show detected faces in image (default: false)
% 
%  OUTPUT:
%     str_out                       -- struct with the following fields
%        .i_face_regions            -- kx4 double array , columns
%                                      indicate [xleft ytop     width height ]
%        .f_face_scores             -- kx1 double array 
%        .i_estimated_class_numbers -- kx1 int array, class numbers based on trained yolo model
%  
%  AUTHOR: Alexander Freytag
%  

    s_path_to_darknet = getFieldWithDefault ( str_settings, 's_path_to_darknet', './' );
    s_path_to_cfg     = getFieldWithDefault ( str_settings, 's_path_to_cfg',     './yolo.cfg' );
    s_path_to_weights = getFieldWithDefault ( str_settings, 's_path_to_weights', './yolo.weights' );
    s_fn_class_labels = getFieldWithDefault ( str_settings, 's_fn_class_labels', './classnames.txt' );
    s_fn_boxes_tmp    = getFieldWithDefault ( str_settings, 's_fn_boxes_tmp',    '/tmp/boxes_tmp.txt' );
    f_thresh          = getFieldWithDefault ( str_settings, 'f_thresh',          0.2 );
    f_nms             = getFieldWithDefault ( str_settings, 'f_nms',             0.5 );
    
    %make sure that no previous results are kept in the tempory results
    %file
    if ( exist( s_fn_boxes_tmp, 'file' ) )
        system( sprintf( 'rm %s', s_fn_boxes_tmp ) );
    end
    % make sure that given paths are valid
    assert ( exist( s_path_to_darknet,  'dir' )~=0, sprintf('Given path > %s < to darknet does not exist!',s_path_to_darknet )  );
    assert ( exist( s_path_to_cfg,     'file' )~=0, sprintf('Specified config file > %s < for yolo model does not exist!', s_path_to_cfg) );
    assert ( exist( s_path_to_weights, 'file' )~=0, sprintf('Specified file > %s < with trained weights for yolo model does not exist!', s_path_to_weights) );
    assert ( exist( s_fn_class_labels, 'file' )~=0, sprintf('Specified config > %s < with class names for yolo model does not exist!', s_fn_class_labels) );
    

    
    %%
    % prepare the system call to darknet
    s_call_darknet = sprintf( './darknet yolo test %s %s -c_filename %s -c_classes %s -draw 0 -write 1 -dest %s -thresh %f -nms %f', ...
                              s_path_to_cfg, ...
                              s_path_to_weights, ...
                              str_settings.s_fn, ...
                              s_fn_class_labels, ...
                              s_fn_boxes_tmp, ...
                              f_thresh, ...
                              f_nms ...
                            );

    % go, go, go!
    % note: darknet needs to be called from its root directory, since
    % several internal paths are specified relative to this folder
    s_currentDir = pwd;
    cd( s_path_to_darknet );
    system( s_call_darknet );
    cd( s_currentDir );
    
    % read results from temporary file
    fid = fopen( s_fn_boxes_tmp );      
    
    % s_fn i_x_left i_y_top i_width i_height, f_score s_class("class") i_classNoEst
    cell_results = textscan(fid, '%s %d %d %d %d %f %s %d');
    
    fclose ( fid ); 
    
    % clean-up
    system( sprintf( 'rm %s', s_fn_boxes_tmp ) );
    
    

    
    %% convert results to desired format 
    
    i_face_regions            = [cell_results{2:5}];    
    f_face_scores             = [cell_results{6}];
    i_estimated_class_numbers = [cell_results{8}];
    

    %% visualize detection results if desired
    b_show_detections = getFieldWithDefault ( str_settings, 'b_show_detections', false );    
    if ( b_show_detections )
        hfig = figure;
        imshow ( image );
        hAxes = gca;
        hold on;
        show_boxes ( hAxes, str_regions.i_face_regions');
        hold off;
        pause
        close ( hfig );
    end    
    
    %%assign output variables    
    
    str_out = [];
    str_out.i_face_regions            = i_face_regions;
    str_out.f_face_scores             = f_face_scores;    
    str_out.i_estimated_class_numbers = i_estimated_class_numbers;
    
  
end
