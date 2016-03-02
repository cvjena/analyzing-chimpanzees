function str_out = gender_classifier_ground_truth ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.s_genders = ground truth genders (string) of the annotated chimpansees in the image

    s_fn      = str_settings.s_fn;
    s_genders = getStringDataSingleImage ( s_fn, 'Gender' );
    
    %% assign output variables
    str_out           = [];
    str_out.s_genders = s_genders;        
    
end