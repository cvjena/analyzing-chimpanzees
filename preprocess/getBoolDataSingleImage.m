function b_values  = getBoolDataSingleImage ( s_fn, s_attribute, s_positive )
% 
% BRIEF
%  specifically taylored to meta-information provided by chimpansee
%  dataset. 
%  Each image specified by s_fn is supposed to come with an
%  additional file s_fn.ic

    
    
    %%
    s_ending       = '.ic';
    
    image          = imread ( s_fn );        
    
    s_fnMetaData   =  sprintf('%s%s', s_fn, s_ending );

    mystruct       = xml2struct ( s_fnMetaData );

    i_numObjects   = length ( mystruct.image_content.objects.object );
    
    %% differentiate number of objects ... if only one object, accessing data is directly as variable.field. otherwise variable{idx}.field
    %
    if ( i_numObjects == 1 )
        myobjects = {mystruct.image_content.objects.object};
    else
        myobjects = mystruct.image_content.objects.object(:);        
    end 
    
    b_values = [];
   
    for idxObject=1:i_numObjects
        i_numAttributes = length(myobjects{idxObject}.attributes.attribute);    


        % check that the object contains a region. otherwise, we can not
        % extract features...            
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
            ytop    = ceil(str2double(myobjects{idxObject}.region.points.point{1}.y.Text));
            ybottom = ceil(str2double(myobjects{idxObject}.region.points.point{3}.y.Text));      
            end       
        catch err       % if field is not existent or empty...
            continue
        end

        if ( ( (xright-xleft) <= 0 ) || ((ybottom-ytop) <= 0)  )
            continue;
        end            
        
         %imcrop ( image, [xmin ymin width height] )
        subimg = imcrop ( image, [   xleft ytop     xright-xleft ybottom-ytop ] );

        if ( isempty(subimg) )
            continue;
        end          

        % fetch age of object
        b_foundAttribute = false;
        for idxAttribute=1:i_numAttributes
            if ( strcmp( myobjects{idxObject}.attributes.attribute{idxAttribute}.key.Text, s_attribute) )
                b_values = [ b_values ; ...
                           strcmp(myobjects{idxObject}.attributes.attribute{idxAttribute}.value.Text, s_positive)...
                        ];
                b_foundAttribute = true;
                break;
            end
        end
        if ( ~b_foundAttribute )
                b_values = [ b_values ; ...
                           NaN ...
                        ];                
        end
    end        



end