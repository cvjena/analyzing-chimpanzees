function str_out = face_identifier_linear_SVM ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.s_names = estimated names of the detected chimpansees in the image

    svmmodel          = getFieldWithDefault ( str_settings, 'svmmodel', [] );
    settingsLibLinear = getFieldWithDefault ( str_settings, 'settingsLibLinear', [] );    
    
    assert ( ~isempty ( svmmodel ),          'No trained SVM model for identification provided!' );
    assert ( ~isempty ( settingsLibLinear ), 'No LibSVM settings for identification provided!' );
        

   [predicted_labels, ~, ~] = liblinear_test ( zeros(1,size(str_extracted_features,2)), sparse(double(str_extracted_features')), svmmodel, settingsLibLinear );
   
    %FIXME change towards returning actual names instead of numbers!
    predicted_names = arrayfun ( @num2string, predicted_labels );

    %% assign outputs
    str_out         = [];
    str_out.s_names = predicted_names;
    
end