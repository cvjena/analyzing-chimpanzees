function str_out = cropObjectsFromSingleImage ( s_fn, settings )
% 
% BRIEF
%  specifically taylored to meta-information provided by chimpansee
%  dataset. 
%  Each image specified by s_fn is supposed to come with an
%  additional file s_fn.ic
%
% OUTPUT
%  str_out   -- struct with following fields
%        .s_fns_new   --  struct of cell arrays, contains the file name of
%                         each cropped and written face image
%        .f_keypoints --  (optional, if settings.b_adaptKeypoints = true),
%                         double array, as many rows as contained images, 
%                         10 columns (x,y)-tupel for 5 possible keypoints. 
%                         Inf if no information is provided
%        .s_possible_keypoints  
%                     --  (optional, if settings.b_adaptKeypoints = true)
%                         cell array of char arrays, names in order of the 5 keypoints. 
%
% INPUT
%  s_fn     -- char array 
%  settings -- (optional), struct with the following optional fields:
%        .b_showCropped    ( default: false)
%        .b_waitForInput   ( default: false)
%        .b_closeCropped   ( default: false)
%        .b_saveCropped    ( default: false)
%        .s_fnWrite        ( default: './')
%        .b_adaptKeypoints ( default: false)



    if ( nargin < 2 )
        settings = [];
    end
    
    b_showCropped      = getFieldWithDefault ( settings, 'b_showCropped', false );
    b_waitForInput     = getFieldWithDefault ( settings, 'b_waitForInput', false ); 
    b_closeCropped     = getFieldWithDefault ( settings, 'b_closeCropped', false );     
    b_saveCropped      = getFieldWithDefault ( settings, 'b_saveCropped', false );
    s_fnWrite          = getFieldWithDefault ( settings, 's_fnWrite', './');
    b_adaptKeypoints   = getFieldWithDefault ( settings, 'b_adaptKeypoints', false);

    
    
    %%
    s_ending     = '.ic';
    
    image        = imread ( s_fn );

    s_fnMetaData =  sprintf('%s%s', s_fn, s_ending );

    mystruct     = xml2struct ( s_fnMetaData );

    i_numObjects = length ( mystruct.image_content.objects.object );
    
    s_fns_new    = {};
    
    if ( b_adaptKeypoints )
        f_keypoints    = inf(0,10); 
        s_possible_keypoints = {'RightEye', 'LeftEye', 'MouthCenter', 'LeftEarlobe', 'RightEarlobe'};
    end
    
    %% differentiate number of objects ... if only one object, accessing data is directly as variable.field. otherwise variable{idx}.field
    %
    if ( i_numObjects == 1 )
        myobjects = {mystruct.image_content.objects.object};
    else
        myobjects = mystruct.image_content.objects.object(:);        
    end

    for idxObject=1:i_numObjects

        % fetch bounding box
        try
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

            if ( b_adaptKeypoints )
                i_numKP = length(myobjects{idxObject}.markers.marker);
                f_keypoints_tmp    = inf(1,10);
                for idxKP = 1:i_numKP
                    try
                        s_KP_name = myobjects{idxObject}.markers.marker{idxKP}.label.Text;                            
                        f_KP_x    = ceil(str2double(myobjects{idxObject}.markers.marker{idxKP}.x.Text));
                        f_KP_y    = ceil(str2double(myobjects{idxObject}.markers.marker{idxKP}.y.Text));                  

                        f_KP_x    = f_KP_x - xleft;
                        f_KP_y    = f_KP_y - ytop;

                        i_idxKP   = find ( strcmp ( s_possible_keypoints, s_KP_name ) );

                        f_keypoints_tmp ( 1, 2*i_idxKP-1 ) = f_KP_x;
                        f_keypoints_tmp ( 1, 2*i_idxKP   ) = f_KP_y;
                    catch err
                        % presumably some data was not correctly formated or
                        % given...
                        disp( 'keypoint is invalid');
                        % we simply continue and let the information by
                        % Inf to indicate the abscence of this keypoint
                    end 
                end

                f_keypoints = [f_keypoints; f_keypoints_tmp];                
            end                

             %imcrop ( image, [xmin ymin width height] )
            subimg = imcrop ( image, [   xleft ytop     xright-xleft ybottom-ytop ] );

            if ( b_showCropped && ~isempty(subimg) )
                hfig = figure;
                imshow ( subimg );

                if ( b_adaptKeypoints )
                    hold on;
                    kp_tmp = reshape ( f_keypoints_tmp, [2,5] );
                    plot ( kp_tmp(1,:), ...
                           kp_tmp(2,:), ...
                           'bx'...
                          ) ;
                end                    

                if ( b_waitForInput )
                    pause;
                end
                
                if ( b_closeCropped ) 
                    close ( hfig );
                end
            end

            if ( b_saveCropped ) 
                if ( ~isempty(subimg) )
                    s_fnWriteTmp = sprintf( '%s-object-%d.png', s_fnWrite, idxObject  );
                    imwrite ( subimg , s_fnWriteTmp  );
                    s_fns_new = [s_fns_new;s_fnWriteTmp];                
                end
            end
        catch err
            % presumably some data was not correctly formated or
            % given...
            err;                
        end
    end        

    %% assign output variables
    str_out.s_fns_new = s_fns_new;
    
    if ( b_adaptKeypoints )
       str_out.f_keypoints          = f_keypoints;
       str_out.s_possible_keypoints = s_possible_keypoints;
    end

end