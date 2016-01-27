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
    
    str_regions        = getHeadRegionSingleImage ( s_fn, settings );

    

    i_numObjects = size ( str_regions.f_regions, 2 );
    

    for idxObject=1:i_numObjects

	xleft  =     str_regions.f_regions( idxObject, 1 );
	yleft  =     str_regions.f_regions( idxObject, 2 );
	widtht =     str_regions.f_regions( idxObject, 3 );
	height =     str_regions.f_regions( idxObject, 4 );	

         %imcrop ( image, [xmin ymin width height] )
        subimg = imcrop ( image, [   xleft ytop     width height ] );


        if ( b_showCropped )
            hfig = figure;
            imshow ( subimg );

            if ( b_adaptKeypoints )
                hold on;
                kp_tmp = reshape ( str_regions.f_keypoints(idxObject,:), [2,5] );
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
                s_fnWriteTmp = sprintf( '%s-object-%d.png', s_fnWrite, idxObject  );
                imwrite ( subimg , s_fnWriteTmp  );
                s_fns_new = [s_fns_new;s_fnWriteTmp];           
        end
    end        

    %% assign output variables
    str_out.s_fns_new = s_fns_new;
    
    if ( b_adaptKeypoints )
       str_out.f_keypoints          = f_keypoints;
       str_out.s_possible_keypoints = s_possible_keypoints;
    end
    
    if ( size(s_fns_new,1) ~= size(f_keypoints,1) )
        disp ( 'fishy!' );
    end
     

end