function str_results = pipeline_all_about_apes ( img, str_settings )

    str_results = [];


    %% 1 - detect and localize faces
    str_face_detection          = getFieldWithDefault ( str_settings, 'str_face_detection', []);
    str_face_detector           = getFieldWithDefault ( str_face_detection, 'str_face_detector', struct('name', {}, 'mfunction', {} ) );
    str_settings_face_detection = getFieldWithDefault ( str_face_detection, 'str_settings_face_detection', [] );
    
    str_detected_faces          = str_face_detector.mfunction ( img, str_settings_face_detection );
    
%     if ( b_visualize_results )
%         show_boxes ( hAxes, str_detected_faces.i_face_regions');
%     end
    
    %% 2 - extract features of every face
    str_feature_extraction          = getFieldWithDefault ( str_settings, 'str_feature_extraction', []);
    str_feature_extractor           = getFieldWithDefault ( str_feature_extraction, 'str_feature_extractor', struct('name', {}, 'mfunction', {} ) );
    str_settings_feature_extraction = getFieldWithDefault ( str_feature_extraction, 'str_settings_feature_extraction', [] );
    
    str_extracted_features          = str_feature_extractor.mfunction ( img, str_detected_faces, str_settings_feature_extraction );
    
    %% 3.1 - decide for known/unknown of each face hypothesis (open-set)
    str_novelty_detection  = getFieldWithDefault ( str_settings, 'str_novelty_detection', []);
    str_novelty_detector   = getFieldWithDefault ( str_novelty_detection, 'str_novelty_detector', struct('name', {}, 'mfunction', {} ) );
    str_settings_novelty_detection ...
                           = getFieldWithDefault ( str_novelty_detection, 'str_settings_novelty_detection', [] );


    b_do_novelty_detection = getFieldWithDefault ( str_novelty_detection, 'b_do_novelty_detection', false );                       
    
    if ( b_do_novelty_detection )
        str_results_novelty_detection ...
                           = str_novelty_detector.mfunction ( str_extracted_features, str_settings_novelty_detection );
                       
%         if ( b_visualize_results )
%             %print novelty result to image
%             str_results_novelty_detection
%         end
    end
                       
   
    
    %% 3.2 - classify each face hypothesis (closed-sed)
    str_identification          = getFieldWithDefault ( str_settings, 'str_identification', []);
    str_identifier              = getFieldWithDefault ( str_identification, 'str_identifier', struct('name', {}, 'mfunction', {} ) );
    str_settings_identification = getFieldWithDefault ( str_identification, 'str_settings_identification', [] );    
    
    
    b_do_identification = getFieldWithDefault ( str_settings_identification, 'b_do_identification', false );
    
    if ( b_do_identification )
        str_results_identification ...
                           = str_identifier.mfunction ( str_extracted_features, str_settings_identification );
                       
%         if ( b_visualize_results )
%             %print identification result to image
%             %str_results_identification
%             writeTextToImage ( hAxes, str_results_identification.s_names, ...
%                                [str_detected_faces.i_face_regions(:,1) + str_detected_faces.i_face_regions(:,3) ...
%                                 str_detected_faces.i_face_regions(:,1)] ...
%                                 );
%         end    
    end
                       
   
    
    %% 4 estimate age of each face hypothesis
    str_age_estimation          = getFieldWithDefault ( str_settings, 'str_age_estimation', []);
    str_age_estimator           = getFieldWithDefault ( str_age_estimation, 'str_age_estimator', struct('name', {}, 'mfunction', {} ) );
    str_settings_age_estimation = getFieldWithDefault ( str_age_estimation, 'str_settings_age_estimation', [] );        
    
    b_do_age_estimation         = getFieldWithDefault ( str_settings_age_estimation, 'b_do_age_estimation', false );
     
    if ( b_do_age_estimation )
        str_results_age_estimation ...
                           = str_age_estimator.mfunction ( str_extracted_features, str_settings_age_estimation );
                       
%         if ( b_visualize_results )
%             %print age to image
%             str_results_age_estimation
%         end                           
    end
                       
 
    
    %% 5 estimate age group of each face hypothesis
    str_age_group_estimation          = getFieldWithDefault ( str_settings, 'str_age_group_estimation', []);
    str_age_group_estimator           = getFieldWithDefault ( str_age_group_estimation, 'str_age_group_estimator', struct('name', {}, 'mfunction', {} ) );
    str_settings_age_group_estimation = getFieldWithDefault ( str_age_group_estimation, 'str_settings_age_group_estimation', [] );        
    
    b_do_age_group_estimation         = getFieldWithDefault ( str_age_group_estimation, 'b_do_age_group_estimation', false );
     
    if ( b_do_age_group_estimation )
        str_results_age_group_estimation ...
                           = str_age_group_estimator.mfunction ( str_extracted_features, str_settings_age_group_estimation );
                       
%         if ( b_visualize_results )
%             %print age group to image
%             str_results_age_group_estimation
%         end                           
    end
    
    %% 6 estimate gender of each face hypothesis
    str_gender_estimation          = getFieldWithDefault ( str_settings, 'str_gender_estimation', []);
    str_gender_estimator           = getFieldWithDefault ( str_age_group_estimation, 'str_gender_estimator', struct('name', {}, 'mfunction', {} ) );
    str_settings_gender_estimation = getFieldWithDefault ( str_age_group_estimation, 'str_settings_gender_estimation', [] );        
    
    b_do_gender_estimation         = getFieldWithDefault ( str_age_group_estimation, 'b_do_gender_estimation', false );
     
    if ( b_do_gender_estimation )
        str_results_gender_estimation ...
                                   = str_age_group_estimator.mfunction ( str_extracted_features, str_settings_gender_estimation );
                       
%         if ( b_visualize_results )
%             %print age group to image
%             str_results_gender_estimation
%         end 
    end
    
    str_settings_gender_estimation = getFieldWithDefault ( str_settings, 'str_settings_gender_estimation', []);
    
    b_do_gender_estimation = getFieldWithDefault ( str_settings_gender_estimation, 'b_do_gender_estimation', false );
    
%     if ( b_visualize_results )
%         %print gender to image
%     end    
    
   
    %% assign outputs
    str_results = [];
    %
    str_results.str_detected_faces                   = str_detected_faces;
    %
    if ( b_do_novelty_detection )
        str_results.str_results_novelty_detection    = str_results_novelty_detection;
    end     
    %
    if ( b_do_identification )
        str_results.str_results_identification       = str_results_identification;
    end      
    %
    if ( b_do_age_estimation )
        str_results.str_results_age_estimation       = str_results_age_estimation;
    end    
    %
    if ( b_do_age_group_estimation )
        str_results.str_results_age_group_estimation = str_results_age_group_estimation;
    end
    %
    if ( b_do_gender_estimation )
        str_results.str_results_gender_estimation    = str_results_gender_estimation;
    end
    
    
    %% visualize final results
    b_visualize_results = getFieldWithDefault ( str_settings, 'b_visualize_results', false );
    
    if ( b_visualize_results )
        
        % combine all results to nice text strings
        s_est_attributes_combined = combine_results_to_text ( str_results );
        
        % show results
        hFig = figure;
        imshow ( img );
        xsize = size(img,2);
        ysize = size(img,1);
        hAxes = gca;
        hold on;
        
        % show detections
        show_boxes ( hAxes, str_detected_faces.i_face_regions');        
        
        % plot text with estimated attributes nex to the bounding boxes
        for idx=1:size(str_detected_faces.i_face_regions,1)
            
            writeTextToImage ( s_est_attributes_combined{idx}, ...
                               [str_detected_faces.i_face_regions(idx,1)/double(xsize) ... %+ str_detected_faces.i_face_regions(idx,4) ...
                                0.98 - str_detected_faces.i_face_regions(idx,2)/double(ysize)] ...
                             );                            
            
        end
        hold off;
        
        
       
    
    
        % clean up
        pause
        close ( hFig );
    end     
    
end