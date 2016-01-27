function str_out = face_identifier_ground_truth ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.s_names = estimated names of the detected chimpansees in the image

    s_fn     = str_settings.s_fn;
    s_names  = getStringDataSingleImage ( s_fn, 'Identity' );


    %% assign output variables
    str_out         = [];
    str_out.s_names = s_names;        
    
end