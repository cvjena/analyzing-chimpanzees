function f_ages = getAgeAllChimpansees ( s_filelist )


   % fileId value - open the file
    fid = fopen( s_filelist );
    
    % reads data from open test file into cell array (%s -> read string)
    s_images = textscan(fid, '%s', 'Delimiter','\n');
    
    % get all images
    s_images = s_images{1};
    
    fclose ( fid );
    
   
    f_ages = [];
    
    %%
    
    i_len = length(s_images);
    progressbar(0);    
    for s_fileIdx = 1:i_len
        progressbar(s_fileIdx/double(i_len));        
        s_fn      = s_images{s_fileIdx};
                
        f_ageTmp  = getFloatSingleChimpansee ( s_fn, 'Age' );
        
        f_ages    = [f_ages; f_ageTmp];
         
    end
    progressbar(1);    


end