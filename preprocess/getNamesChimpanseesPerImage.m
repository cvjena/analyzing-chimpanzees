function str_names_per_image = getNamesChimpanseesPerImage ( s_filelist, str_settings )

    if ( nargin < 2 )
        str_settings = [];
    end


   % fileId value - open the file
    fid = fopen( s_filelist );
    
    % reads data from open test file into cell array (%s -> read string)
    s_images = textscan(fid, '%s', 'Delimiter','\n');
    
    % get all images
    s_images = s_images{1};
    
    fclose ( fid );
    
   
    str_names_per_image = {};
    
    %%
    
    i_len = length(s_images);
    progressbar(0);
    for s_fileIdx = 1:i_len
        progressbar(s_fileIdx/double(i_len));
        s_fn      = s_images{s_fileIdx};
                
        s_namesTmp  = getNamesSingleImageNewDataLayout ( s_fn, str_settings );
        %s_namesTmp  = getStringDataSingleImage ( s_fn, 'Identity' );
        
        str_names_per_image{s_fileIdx,1}     = s_fn;
        str_names_per_image{s_fileIdx,2}     = s_namesTmp.i_labels;
        str_names_per_image{s_fileIdx,3}     = s_namesTmp.s_classnames;
         
    end
    progressbar(1);


end