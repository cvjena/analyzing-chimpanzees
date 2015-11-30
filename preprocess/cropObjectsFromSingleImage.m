function s_fns_new = cropObjectsFromSingleImage ( s_fn, settings )
% 
% BRIEF
%  specifically taylored to meta-information provided by chimpansee
%  dataset. 
%  Each image specified by s_fn is supposed to come with an
%  additional file s_fn.ic

    if ( nargin < 2 )
        settings = [];
    end
    
    b_showCropped  = getFieldWithDefault ( settings, 'b_showCropped', false );
    b_waitForInput = getFieldWithDefault ( settings, 'b_waitForInput', false ); 
    b_closeCropped = getFieldWithDefault ( settings, 'b_closeCropped', false );     
    b_saveCropped  = getFieldWithDefault ( settings, 'b_saveCropped', false );
    s_fnWrite      = getFieldWithDefault ( settings, 's_fnWrite', './');

    
    
    %%
    s_ending     = '.ic';
    
    image        = imread ( s_fn );

    s_fnMetaData =  sprintf('%s%s', s_fn, s_ending );

    mystruct     = xml2struct ( s_fnMetaData );

    i_numObjects = length ( mystruct.image_content.objects.object );
    
    s_fns_new    = {};
    
    %% differentiate number of objects ... if only one object, accessing data is directly as variable.field. otherwise variable{idx}.field
    %
    if ( i_numObjects == 1 )


        % fetch bounding box
        try        
            xsize = size(image, 2 );
            ysize = size(image, 1 );
            xleft   = ceil(str2num(mystruct.image_content.objects.object.region.left.Text) );
            xright  = ceil(str2num(mystruct.image_content.objects.object.region.right.Text) );
            ytop    = ceil(str2num(mystruct.image_content.objects.object.region.top.Text) );
            ybottom = ceil(str2num(mystruct.image_content.objects.object.region.bottom.Text) );  

             %imcrop ( image, [xmin ymin width height] )
            subimg = imcrop ( image, [   xleft ytop     ybottom-ytop  xright-xleft] );

            if ( b_showCropped && isempty(subimg) )
                hfig = figure;
                imshow ( subimg );

                if ( b_waitForInput )
                    pause;
                end

                if ( b_closeCropped )
                    close ( hfig );
                end            

            end

            if ( b_saveCropped ) 
                if ( ~isempty(subimg) )

                    idxObject=1;
                    s_fnWriteTmp = sprintf( '%s-object-%d.png', s_fnWrite, idxObject  );
                    imwrite ( subimg , s_fnWriteTmp  );
                    s_fns_new = [s_fns_new;s_fnWriteTmp];
                end
            end
        catch err
            % presumably some data was not correctly formated or
            % given...
        end        
    else
        for idxObject=1:i_numObjects
            
            % fetch bounding box
            try
                xsize = size(image, 2 );
                ysize = size(image, 1 );
                xleft   = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.left.Text) );
                xright  = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.right.Text) );
                ytop    = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.top.Text) );
                ybottom = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.bottom.Text) );  

                 %imcrop ( image, [xmin ymin width height] )
                subimg = imcrop ( image, [   xleft ytop     ybottom-ytop  xright-xleft] );

                if ( b_showCropped && isempty(subimg) )
                    figure;
                    imshow ( subimg );

                    if ( b_waitForInput )
                        pause;
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
            end
        end        
    end


end