function str_out = face_detector_precomputed_boxes ( image, str_settings )
% function str_out = face_detector_precomputed_boxes ( image, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
%     image        -- only required for visualization
%     str_settings -- struct with following fields
%         .s_fn              -- mandatory, char array, filename to entire image, assumes additional file s_fn.ic  
%         .b_show_detections -- optional, bool 
%         .s_destBoxes       -- string, filename to file with detection results, 
%                               syntax as used by YOLO, i.e., 
%                               s_fn_orig_img i_xleft i_xright i_ytop i_ybottom f_score

% 
%  OUTPUT:
%     str_out                -- struct with the following fields
%        .i_face_regions     -- kx4 double array , columns
%                               indicate [xleft ytop     width height ]
% 
   
    
    
    persistent precomp_face_dections;
    if ( isempty ( precomp_face_dections ) )
        s_destBoxes  = getFieldWithDefault ( str_settings, 's_destBoxes', '' );
        
        % fileId value - open the file
        fid = fopen( s_destBoxes );

        % reads data from open test file into cell array (%s -> read string)
        s_detections = textscan(fid, '%s %d %d %d %d %f');

        % get all information
        precomp_face_dections.s_images  = s_detections{1};
        %
        precomp_face_dections.i_xleft   = s_detections{2};
        precomp_face_dections.i_xright  = s_detections{3};
        precomp_face_dections.i_ytop    = s_detections{4};        
        precomp_face_dections.i_ybottom = s_detections{5};
        %
        precomp_face_dections.f_score  = s_detections{6};

        fclose ( fid );
    end

%     
    
    idx_image = find( strcmp ( precomp_face_dections.s_images, str_settings.s_fn ) );
    
    i_numDetectedFaces = length(idx_image);
    str_regions.i_face_regions = zeros ( i_numDetectedFaces ,4 );
    

    str_regions.i_face_regions(:,1) = precomp_face_dections.i_xleft ( idx_image );
    str_regions.i_face_regions(:,2) = precomp_face_dections.i_ytop  ( idx_image );
    str_regions.i_face_regions(:,3) = precomp_face_dections.i_xright ( idx_image ) - precomp_face_dections.i_xleft ( idx_image );
    str_regions.i_face_regions(:,4) = precomp_face_dections.i_ybottom  ( idx_image )  - precomp_face_dections.i_ytop( idx_image );
    

    
    
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