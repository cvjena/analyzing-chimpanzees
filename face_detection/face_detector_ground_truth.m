function str_out = face_detector_ground_truth ( image, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.i_face_regions = i_face_regions;   kx4 double array , columns
%                               indicate [xleft ytop     width height ]

    s_ending     = '.ic';
    s_fn         = str_settings.s_fn;
    

    
    s_fnMetaData =  sprintf('%s%s', s_fn, s_ending );

    mystruct     = xml2struct ( s_fnMetaData );

    i_numObjects = length ( mystruct.image_content.objects.object );
    
    if ( i_numObjects == 1 )
        myobjects = {mystruct.image_content.objects.object};
    else
        myobjects = mystruct.image_content.objects.object(:);        
    end
    
    %[xmin ymin width height]
    i_face_regions    = zeros(0,4);     
    
    for idxObject=1:i_numObjects    
        % fetch bounding box
        if ( isfield ( myobjects{idxObject}.region, 'left') && ...
             isfield ( myobjects{idxObject}.region, 'right') && ...
             isfield ( myobjects{idxObject}.region, 'top') && ...
             isfield ( myobjects{idxObject}.region, 'bottom')  ...
            )                
            xleft   = ceil(str2double(myobjects{idxObject}.region.left.Text) );
            xright  = ceil(str2double(myobjects{idxObject}.region.right.Text) );
            ytop    = ceil(str2double(myobjects{idxObject}.region.top.Text) );
            ybottom = ceil(str2double(myobjects{idxObject}.region.bottom.Text) );  
        elseif ( isfield ( myobjects{idxObject}.region, 'points') ...
               )                
           % order of points is top left, top right, bottom right,
           % bottom left

            xleft   = ceil(str2double(myobjects{idxObject}.region.points.point{1}.x.Text));
            xright  = ceil(str2double(myobjects{idxObject}.region.points.point{3}.x.Text));
            ytop    = ceil(str2double(myobjects{idxObject}.region.points.point{1}.x.Text));
            ybottom = ceil(str2double(myobjects{idxObject}.region.points.point{3}.x.Text));      
        end 
        
        i_face_regions = [i_face_regions; xleft ytop     xright-xleft ybottom-ytop];  
    end
    
    
    b_show_detections = getFieldWithDefault ( str_settings, 'b_show_detections', false );    
    if ( b_show_detections )
        hfig = figure;
        imshow ( image );
        hAxes = gca;
        hold on;
        show_boxes ( hAxes, i_face_regions');
        hold off;
        pause
        close ( hfig );
    end

    %% assign output variables
    str_out.i_face_regions = i_face_regions;        
    
end