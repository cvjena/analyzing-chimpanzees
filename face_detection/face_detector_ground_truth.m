function str_out = face_detector_ground_truth ( image, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.i_face_regions = i_face_regions;   kx4 double array , columns
%                               indicate [xleft ytop     width height ]

    str_regions  = getHeadRegionSingleImage ( s_fn, settings )
    
    
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