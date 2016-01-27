function str_out = age_estimator_ground_truth ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.f_ages = estimated ages (vector of float) of the detected chimpansees in the image

    s_fn     = str_settings.s_fn;
    f_ages   = getFloatDataSingleImage ( s_fn, 'Age' );


    %% assign output variables
    str_out        = [];
    str_out.f_ages = f_ages;        
    
end