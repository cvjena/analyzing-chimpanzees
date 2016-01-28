function str_out = gender_classifier_linear_SVM ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.s_genders    = estimated gender of the detected chimpansees in the
%                            image, cell array of char arrays
%

    svmmodel               = getFieldWithDefault ( str_settings, 'svmmodel', [] );
    settingsLibLinear      = getFieldWithDefault ( str_settings, 'settingsLibLinear', [] ); 
    s_all_genders          = getFieldWithDefault ( str_settings, 's_all_genders', [] ); 
    
    
    assert ( ~isempty ( svmmodel ),          'No trained SVM model for gender classification provided!' );
    assert ( ~isempty ( settingsLibLinear ), 'No LibSVM settings for gender classification provided!' );
        


    [predicted_age_group_ids, ~, ~] = liblinear_test ( zeros(size(str_extracted_features.features,2),1), sparse(double(str_extracted_features.features')), svmmodel, settingsLibLinear );
   
    predicted_genders = s_all_genders( predicted_age_group_ids );

    %% assign outputs
    str_out              = [];
    str_out.s_genders = predicted_genders;
    
end