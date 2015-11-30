function s_names = getNamesAllChimpansees ( s_filelist )


   % fileId value - open the file
    fid = fopen( s_filelist );
    
    % reads data from open test file into cell array (%s -> read string)
    s_images = textscan(fid, '%s', 'Delimiter','\n');
    
    % get all images
    s_images = s_images{1};
    
    fclose ( fid );
    
   
    s_names = {};
    
    %%
    
    i_len = length(s_images);
    progressbar(0);
    for s_fileIdx = 1:i_len
        progressbar(s_fileIdx/double(i_len));
        s_fn      = s_images{s_fileIdx};
                
        s_namesTmp  = getStringSingleChimpansee ( s_fn, 'Identity' );
        
        s_names     = [s_names; s_namesTmp];
         
    end
    progressbar(1);


end