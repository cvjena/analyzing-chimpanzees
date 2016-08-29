function str_out = face_detector_entire_image ( image, str_settings )
% function str_out = face_detector_entire_image ( image, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
%     image        -- the input image
%     str_settings -- struct with following fields
%         .b_show_detections -- optional, bool 
%
% 
%  OUTPUT:
%     str_out                -- struct with the following fields
%        .i_face_regions     -- kx4 double array , columns
%                               indicate [xleft ytop     width height ]
% 
   
    
    i_width  = size( image, 2 );
    i_height = size( image, 1 );
    
    
    i_face_regions = [1, 1, i_width, i_height];
        
    
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
    str_out                = [];
    str_out.i_face_regions = i_face_regions;
    
end