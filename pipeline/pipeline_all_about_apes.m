function str_results = pipeline_all_about_apes ( img, str_settings )
    %% 1 - detect and localize faces
    str_settings_detection = getFieldWithDefault ( str_settings, 'str_settings_detection', []);
    str_face_detector      = getFieldWithDefault ( str_settings_detection, 'str_face_detector', struct('name', {}, 'mfunction', {}, 'settings', {} ) );
    
    str_face_detector.mfunction ( img, str_face_detector.settings );
    
    %% 2 - extract features of every face
    str_settings_feature_extraction = getFieldWithDefault ( str_settings, 'str_settings_feature_extraction', []);
    
    %% 3.1 - decide for known/unknown of each face hypothesis (open-set)
    str_settings_novelty = getFieldWithDefault ( str_settings, 'str_settings_novelty', []);
    
    b_do_novelty_detection = getFieldWithDefault ( str_settings_novelty, 'b_do_novelty_detection', true );
    str_novelty_detector = getFieldWithDefault ( str_settings_novelty, 'str_novelty_detector', struct('name', {}, 'mfunction', {}, 'settings', {} ) );
    
    %% 3.2 - classify each face hypothesis (closed-sed)
    str_settings_identification = getFieldWithDefault ( settings, 'str_settings_identification', []);
    
    b_do_identification = getFieldWithDefault ( str_settings_identification, 'b_do_identification', true );
    
    %% 4 estimate age of each face hypothesis
    str_settings_age_estimation = getFieldWithDefault ( str_settings, 'str_settings_age_estimation', []);
    
    b_do_age_estimation = getFieldWithDefault ( str_settings_age_estimation, 'b_do_age_estimation', true );
    
    %% 5 estimate gender of each face hypothesis
    str_settings_gender_estimation = getFieldWithDefault ( str_settings, 'str_settings_gender_estimation', []);
    
    b_do_gender_estimation = getFieldWithDefault ( str_settings_gender_estimation, 'b_do_gender_estimation', true );
    
end