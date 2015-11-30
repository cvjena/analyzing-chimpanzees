function s_dataset_names = getDatasetNamesAllChimpansees ( s_filelist )


   % fileId value - open the file
    fid = fopen( s_filelist );
    
    % reads data from open test file into cell array (%s -> read string)
    s_images = textscan(fid, '%s', 'Delimiter','\n');
    
    % get all images
    s_images = s_images{1};
    
    fclose ( fid );
    
   
    s_dataset_names = {};
    
    %%
    
    i_len = length(s_images);
    progressbar(0);
    for s_fileIdx = 1:i_len
        progressbar(s_fileIdx/double(i_len));
        s_fn             = s_images{s_fileIdx};
        
        posOfSlash       = findstr ( s_fn, '/' );
        
        s_namedataset    = s_fn( (posOfSlash(end-1)+1):(posOfSlash(end)-1));
        i_num            = getNumberOfChimpanseesInImage ( s_fn );
        for i=1:i_num
            s_dataset_names  = [s_dataset_names; s_namedataset];
        end
         
    end
    progressbar(1);


end

function i_num = getNumberOfChimpanseesInImage ( s_fn )
    %%
    s_ending       = '.ic';
    s_fnMetaData   =  sprintf('%s%s', s_fn, s_ending );

    mystruct       = xml2struct ( s_fnMetaData );

    i_numObjects   = length ( mystruct.image_content.objects.object );
    
    % that's the largest number of possible objects in the current frame
    %
    % it might be less if not all relevant information is specified for
    % each object
    i_num          = i_numObjects;
    
    
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
            i_num   = 0;
            return;
        end

        if ( ( (xright-xleft) <= 0 ) || ((ybottom-ytop) <= 0)  )
            i_num   = 0;
            return;
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
                i_num   = i_num-1;
                continue
            end

            if ( ( (xright-xleft) <= 0 ) || ((ybottom-ytop) <= 0)  )
                i_num   = i_num-1;
                continue;
            end             
            
        end           
    end
    
end
