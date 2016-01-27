function str_results = pipeline_all_about_apes ( img, str_settings )

    b_visualize_results = getFieldWithDefault ( str_settings, 'b_visualize_results', false );
    
    if ( b_visualize_results )
        hFig = figure;
        imshow ( img );
        hAxes = gca;
        hold on;
    end    
    

    %% 1 - detect and localize faces
    str_detection          = getFieldWithDefault ( str_settings, 'str_detection', []);
    str_face_detector      = getFieldWithDefault ( str_detection, 'str_face_detector', struct('name', {}, 'mfunction', {} ) );
    str_settings_detection = getFieldWithDefault ( str_detection, 'str_settings_detection', [] );
    
    str_detected_faces     = str_face_detector.mfunction ( img, str_settings_detection );
    
    if ( b_visualize_results )
        show_boxes ( hAxes, str_detected_faces.i_face_regions');
    end
    
    %% 2 - extract features of every face
    str_feature_extraction          = getFieldWithDefault ( str_settings, 'str_feature_extraction', []);
    str_feature_extractor           = getFieldWithDefault ( str_feature_extraction, 'str_feature_extractor', struct('name', {}, 'mfunction', {} ) );
    str_settings_feature_extraction = getFieldWithDefault ( str_feature_extraction, 'str_settings_feature_extraction', [] );
    
    str_extracted_features          = str_feature_extractor.mfunction ( img, str_detected_faces, str_settings_feature_extraction );
    
    %% 3.1 - decide for known/unknown of each face hypothesis (open-set)
    str_settings_novelty = getFieldWithDefault ( str_settings, 'str_settings_novelty', []);
    
    b_do_novelty_detection = getFieldWithDefault ( str_settings_novelty, 'b_do_novelty_detection', true );
    str_novelty_detector = getFieldWithDefault ( str_settings_novelty, 'str_novelty_detector', struct('name', {}, 'mfunction', {}, 'settings', {} ) );
    
    if ( b_visualize_results )
        %print novelty result to image
    end    
    
    %% 3.2 - classify each face hypothesis (closed-sed)
    str_settings_identification = getFieldWithDefault ( settings, 'str_settings_identification', []);
    
    b_do_identification = getFieldWithDefault ( str_settings_identification, 'b_do_identification', true );
    
    if ( b_visualize_results )
        %print id to image
    end
    
    %% 4 estimate age of each face hypothesis
    str_settings_age_estimation = getFieldWithDefault ( str_settings, 'str_settings_age_estimation', []);
    
    b_do_age_estimation = getFieldWithDefault ( str_settings_age_estimation, 'b_do_age_estimation', true );
    
    if ( b_visualize_results )
        %print age to image
    end
    
    %% 5 estimate age group of each face hypothesis
    str_settings_gender_estimation = getFieldWithDefault ( str_settings, 'str_settings_gender_estimation', []);
    
    b_do_gender_estimation = getFieldWithDefault ( str_settings_gender_estimation, 'b_do_gender_estimation', true );
    
    if ( b_visualize_results )
        %print age group to image
    end     
    
    %% 6 estimate gender of each face hypothesis
    str_settings_gender_estimation = getFieldWithDefault ( str_settings, 'str_settings_gender_estimation', []);
    
    b_do_gender_estimation = getFieldWithDefault ( str_settings_gender_estimation, 'b_do_gender_estimation', true );
    
    if ( b_visualize_results )
        %print gender to image
    end    
    
    
    %% clean up
    if ( b_visualize_results )
        pause
        close ( hFig );
    end          
    
end