function s_fns_new = cropObjectsFromMultipleImages ( s_filelist, settings )

    if ( nargin < 2 )
        settings = [];
    end

   % fileId value - open the file
    fid = fopen( s_filelist );
    
    % reads data from open test file into cell array (%s -> read string)
    s_images = textscan(fid, '%s', 'Delimiter','\n');
    
    % get all images
    s_images = s_images{1};
    
    fclose ( fid );
    
    settingsSpecific = [];
    settingsSpecific.b_showCropped  = getFieldWithDefault( settings, 'b_showCropped', true );
    settingsSpecific.b_waitForInput = getFieldWithDefault ( settings, 'b_waitForInput', true );
    settingsSpecific.b_closeCropped = getFieldWithDefault ( settings, 'b_closeCropped', true );    
    settingsSpecific.b_saveCropped  = getFieldWithDefault ( settings, 'b_saveCropped', false );
    
    
    
    %%
    s_fns_new = {};
    
    i_len = length(s_images);
    progressbar(0);    
    for s_fileIdx = 1:i_len
        progressbar(s_fileIdx/double(i_len));
        s_fn         = s_images{s_fileIdx};
        
        settingsSpecific.s_fnWrite  = getFieldWithDefault ( settings, 's_fnWriteDest', './' );    
        settingsSpecific.s_fnWrite  = sprintf('%simg-id%d', settingsSpecific.s_fnWrite, s_fileIdx);
        s_fns_new_tmp               = cropObjectsFromSingleImage ( s_fn, settingsSpecific );
        s_fns_new                   = [s_fns_new;s_fns_new_tmp];
         
    end
    progressbar(1);
    


end