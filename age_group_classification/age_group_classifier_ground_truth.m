function str_out = age_group_classifier_ground_truth ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.s_names = estimated age group (array of char array) of the detected chimpansees in the image

    s_fn          = str_settings.s_fn;
    s_age_groups  = getStringDataSingleImage ( s_fn, 'AgeGroup' );


    %% assign output variables
    str_out              = [];
    str_out.s_age_groups = s_age_groups;        
    
end