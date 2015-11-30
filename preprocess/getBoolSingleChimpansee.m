function b_values  = getBoolSingleChimpansee ( s_fn, s_attribute, s_positive )
% 
% BRIEF
%  specifically taylored to meta-information provided by chimpansee
%  dataset. 
%  Each image specified by s_fn is supposed to come with an
%  additional file s_fn.ic

    
    
    %%
    s_ending       = '.ic';
    s_fnMetaData   =  sprintf('%s%s', s_fn, s_ending );

    mystruct       = xml2struct ( s_fnMetaData );

    i_numObjects   = length ( mystruct.image_content.objects.object );
    
    %% differentiate number of objects ... if only one object, accessing data is directly as variable.field. otherwise variable{idx}.field
    %
    b_values = [];
    if ( i_numObjects == 1 )
        
        i_numAttributes = length(mystruct.image_content.objects.object.attributes.attribute);    
        
        % check that the object contains a region. otherwise, we can not
        % extract features...            
        try
            xleft   = ceil(str2num(mystruct.image_content.objects.object.region.left.Text) );
            xright  = ceil(str2num(mystruct.image_content.objects.object.region.right.Text) );
            ytop    = ceil(str2num(mystruct.image_content.objects.object.region.top.Text) );
            ybottom = ceil(str2num(mystruct.image_content.objects.object.region.bottom.Text) );        
        catch err       % if field is not existent or empty...
            return
        end

        if ( ( (xright-xleft) <= 0 ) || ((ybottom-ytop) <= 0)  )
            return;
        end           

        % fetch age of object
        b_foundAttribute = false;        
        for idxAttribute=1:i_numAttributes
            if ( strcmp( mystruct.image_content.objects.object.attributes.attribute{idxAttribute}.key.Text, s_attribute) )
                b_values = strcmp(mystruct.image_content.objects.object.attributes.attribute{idxAttribute}.value.Text, s_positive);
                b_foundAttribute = true;                
                break;
            end
        end
        if ( ~b_foundAttribute )
                b_values = NaN ;                
        end        

        
    else
        for idxObject=1:i_numObjects
            i_numAttributes = length(mystruct.image_content.objects.object{idxObject}.attributes.attribute);    

            
            % check that the object contains a region. otherwise, we can not
            % extract features...            
            try
                xleft   = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.left.Text) );
                xright  = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.right.Text) );
                ytop    = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.top.Text) );
                ybottom = ceil(str2num(mystruct.image_content.objects.object{idxObject}.region.bottom.Text) );        
            catch err       % if field is not existent or empty...
                continue
            end

            if ( ( (xright-xleft) <= 0 ) || ((ybottom-ytop) <= 0)  )
                continue;
            end             
            
            % fetch age of object
            b_foundAttribute = false;
            for idxAttribute=1:i_numAttributes
                if ( strcmp( mystruct.image_content.objects.object{idxObject}.attributes.attribute{idxAttribute}.key.Text, 'Age') )
                    b_values = [ b_values ; ...
                               strcmp(mystruct.image_content.objects.object{idxObject}.attributes.attribute{idxAttribute}.value.Text, s_positive)...
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


end