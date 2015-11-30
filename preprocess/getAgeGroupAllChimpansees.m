function b_age_groups = getAgeGroupAllChimpansees ( s_filelist )


   % fileId value - open the file
    fid = fopen( s_filelist );
    
    % reads data from open test file into cell array (%s -> read string)
    s_images = textscan(fid, '%s', 'Delimiter','\n');
    
    % get all images
    s_images = s_images{1};
    
    fclose ( fid );
    
   
    b_age_groups = [];
    
    %%
    
    i_len = length(s_images);
    progressbar(0);    
    for s_fileIdx = 1:i_len
        progressbar(s_fileIdx/double(i_len));        
        s_fn      = s_images{s_fileIdx};
                
        b_age_groupsTmp  = getBoolSingleChimpansee ( s_fn, 'AgeGroup', 'Infant' );
        
        b_age_groups     = [b_age_groups; b_age_groupsTmp];
         
    end
    progressbar(1);    


end