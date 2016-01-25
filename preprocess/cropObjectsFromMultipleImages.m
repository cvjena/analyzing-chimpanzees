function str_out = cropObjectsFromMultipleImages ( s_filelist, settings )
%
% 
% BRIEF
% Call cropObjectsFromSingleImage.m to several images consecutively and
% combine resulting outputs
%
%  Specifically taylored to meta-information provided by chimpansee
%  dataset. 
%  Each image specified by s_fn is supposed to come with an
%  additional file s_fn.ic
%
% OUTPUT
%  str_out   -- struct with following fields
%        .s_fns_new   --  cell array of char arrays, contains the file name of
%                         each cropped and written face image
%        .f_keypoints --  (optional, if settings.b_adaptKeypoints = true),
%                         as many rows as contained images, 10 columns (x,y)-tupel 
%                         for 5 possible keypoints. Inf if no information
%                         is provided
%        .s_possible_keypoints  
%                     --  (optional, if settings.b_adaptKeypoints = true)
%                          cell array of char arrays, names in order of the 5 keypoints. 
%
% INPUT
%  s_filelist  -- cell array with filenames in each cell ( char array). 
%                 We assume an equally named .ic file which is located 
%                 at the same place
%  settings    -- (optional), struct with the following optional fields:
%        .b_showCropped    ( default: true)
%        .b_waitForInput   ( default: true)
%        .b_closeCropped   ( default: true)
%        .b_saveCropped    ( default: false)
%        .s_fnWrite        ( default: './')
%        .b_adaptKeypoints ( default: false)

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
    settingsSpecific.b_showCropped     = getFieldWithDefault ( settings, 'b_showCropped', true );
    settingsSpecific.b_waitForInput    = getFieldWithDefault ( settings, 'b_waitForInput', true );
    settingsSpecific.b_closeCropped    = getFieldWithDefault ( settings, 'b_closeCropped', true );    
    settingsSpecific.b_saveCropped     = getFieldWithDefault ( settings, 'b_saveCropped', false );
    settingsSpecific.b_adaptKeypoints  = getFieldWithDefault ( settings, 'b_adaptKeypoints', false );
    
    
    
    
    %%
    s_fns_new = {};
    if ( settingsSpecific.b_adaptKeypoints )
        f_keypoints = [];
    end
    
    i_len = length(s_images);
    progressbar(0);    
    for s_fileIdx = 1:i_len
        progressbar(s_fileIdx/double(i_len));
        s_fn         = s_images{s_fileIdx};
        
        settingsSpecific.s_fnWrite  = getFieldWithDefault ( settings, 's_fnWriteDest', './' );    
        settingsSpecific.s_fnWrite  = sprintf('%simg-id%d', settingsSpecific.s_fnWrite, s_fileIdx);
        str_results                 = cropObjectsFromSingleImage ( s_fn, settingsSpecific );
        s_fns_new                   = [s_fns_new;str_results.s_fns_new];
        if ( isfield ( str_results, 'f_keypoints' ) )
            f_keypoints             = [f_keypoints;str_results.f_keypoints];
        end
         
    end
    progressbar(1);
    
    %% assign output variables
    str_out.s_fns_new = s_fns_new;
    
    if ( settingsSpecific.b_adaptKeypoints )
       str_out.f_keypoints          = f_keypoints;
       str_out.s_possible_keypoints = str_results.s_possible_keypoints;       
    end    
    


end