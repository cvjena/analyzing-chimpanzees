function str_out = face_detector_ground_truth ( image, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
%     image        -- only required for visualization
%     str_settings -- struct with following fields
%         .s_fn              -- mandatory, char array, filename to entire image, assumes additional file s_fn.ic  
%         .b_show_detections -- optional, bool 
%         .b_adaptKeypoints  -- optional, bool, if true, gt keypoints are
%                               returned relative to each provided bounding box
% 
%  OUTPUT:
%     str_out                -- struct with the following fields
%        .i_face_regions     -- kx4 double array , columns
%                               indicate [xleft ytop     width height ]
%        .f_keypoints        --  (optional, if settings.b_adaptKeypoints = true),
%                                double array, as many rows as contained images, 
%                                10 columns (x,y)-tupel for 5 possible keypoints. 
%                                Inf if no information is provided
%        .s_possible_keypoints  
%                            --  (optional, if settings.b_adaptKeypoints = true)
%                                cell array of char arrays, names in order of the 5 keypoints. 

    s_fn         = str_settings.s_fn;
    str_regions  = getHeadRegionSingleImage ( s_fn, str_settings );
    
    
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

    %% assign output variables
    str_out = str_regions;        
    
end