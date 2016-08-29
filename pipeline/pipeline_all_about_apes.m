function str_results = pipeline_all_about_apes ( img, str_settings )
% function str_results = pipeline_all_about_apes ( img, str_settings )
%  BRIEF
%    
%
%  INPUT
%    
%    str_settings -- struct, optional, the following fields are supported
%
%  OUTPUT
% 
%  author: Alexander Freytag

    str_results = [];


    %% 1 - detect and localize faces
    str_face_detection          = getFieldWithDefault ( str_settings, 'str_face_detection', []);
    str_face_detector           = getFieldWithDefault ( str_face_detection, 'str_face_detector', struct('name', {}, 'mfunction', {} ) );
    str_settings_face_detection = getFieldWithDefault ( str_face_detection, 'str_settings_face_detection', [] );
    
    str_detected_faces          = str_face_detector.mfunction ( img, str_settings_face_detection );
    
    
    %% 2 - extract features of every face
    str_feature_extraction          = getFieldWithDefault ( str_settings, 'str_feature_extraction', []);
    str_feature_extractor           = getFieldWithDefault ( str_feature_extraction, 'str_feature_extractor', struct('name', {}, 'mfunction', {} ) );
    str_settings_feature_extraction = getFieldWithDefault ( str_feature_extraction, 'str_settings_feature_extraction', [] );
    
    str_extracted_features          = [];
    if ( ~isempty(str_feature_extractor) &&  ~isempty( str_feature_extractor.mfunction ) )
        str_extracted_features = str_feature_extractor.mfunction ( img, str_detected_faces, str_settings_feature_extraction );
    end
    
    %% 3.1 - decide for known/unknown of each face hypothesis (open-set)
    str_novelty_detection  = getFieldWithDefault ( str_settings, 'str_novelty_detection', []);
    str_novelty_detector   = getFieldWithDefault ( str_novelty_detection, 'str_novelty_detector', struct('name', {}, 'mfunction', {} ) );
    str_settings_novelty_detection ...
                           = getFieldWithDefault ( str_novelty_detection, 'str_settings_novelty_detection', [] );


    b_do_novelty_detection = getFieldWithDefault ( str_novelty_detection, 'b_do_novelty_detection', false );                       
    
    if ( b_do_novelty_detection )
        str_results_novelty_detection ...
                           = str_novelty_detector.mfunction ( str_extracted_features, str_settings_novelty_detection );
    end
                       
   
    
    %% 3.2 - classify each face hypothesis (closed-sed)
    str_identification          = getFieldWithDefault ( str_settings, 'str_identification', []);
    str_identifier              = getFieldWithDefault ( str_identification, 'str_identifier', struct('name', {}, 'mfunction', {} ) );
    str_settings_identification = getFieldWithDefault ( str_identification, 'str_settings_identification', [] );    
    
    
    b_do_identification         = getFieldWithDefault ( str_identification, 'b_do_identification', false );
    
    if ( b_do_identification )
        str_results_identification ...
                                = str_identifier.mfunction ( str_extracted_features, str_settings_identification );
    end
                       
   
    
    %% 4 estimate age of each face hypothesis
    str_age_estimation          = getFieldWithDefault ( str_settings, 'str_age_estimation', []);
    str_age_estimator           = getFieldWithDefault ( str_age_estimation, 'str_age_estimator', struct('name', {}, 'mfunction', {} ) );
    str_settings_age_estimation = getFieldWithDefault ( str_age_estimation, 'str_settings_age_estimation', [] );        
    
    b_do_age_estimation         = getFieldWithDefault ( str_age_estimation, 'b_do_age_estimation', false );
     
    if ( b_do_age_estimation )
        str_results_age_estimation ...
                           = str_age_estimator.mfunction ( str_extracted_features, str_settings_age_estimation );                        
    end
                       
 
    
    %% 5 estimate age group of each face hypothesis
    str_age_group_estimation          = getFieldWithDefault ( str_settings, 'str_age_group_estimation', []);
    str_age_group_estimator           = getFieldWithDefault ( str_age_group_estimation, 'str_age_group_estimator', struct('name', {}, 'mfunction', {} ) );
    str_settings_age_group_estimation = getFieldWithDefault ( str_age_group_estimation, 'str_settings_age_group_estimation', [] );        
    
    b_do_age_group_estimation         = getFieldWithDefault ( str_age_group_estimation, 'b_do_age_group_estimation', false );
     
    if ( b_do_age_group_estimation )
        str_results_age_group_estimation ...
                           = str_age_group_estimator.mfunction ( str_extracted_features, str_settings_age_group_estimation );                         
    end
    
    %% 6 estimate gender of each face hypothesis
    str_gender_estimation          = getFieldWithDefault ( str_settings, 'str_gender_estimation', []);
    str_gender_estimator           = getFieldWithDefault ( str_gender_estimation, 'str_gender_estimator', struct('name', {}, 'mfunction', {} ) );
    str_settings_gender_estimation = getFieldWithDefault ( str_gender_estimation, 'str_settings_gender_estimation', [] );        
    
    b_do_gender_estimation         = getFieldWithDefault ( str_gender_estimation, 'b_do_gender_estimation', false );
     
    if ( b_do_gender_estimation )
        str_results_gender_estimation ...
                                   = str_gender_estimator.mfunction ( str_extracted_features, str_settings_gender_estimation );
    end
      
   
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
        b_deactivate_screen = getFieldWithDefault ( str_settings, 'b_deactivate_screen', false );
        if ( b_deactivate_screen ) 
            hFig = figure('Visible','Off');
            image ( img );
            axis off
        else
            hFig = figure;
            % deactivate the annoying warning that the image is too big to fit
            % the screen and will be resized...
            warning('off', 'Images:initSize:adjustingMag');
            imshow ( img );
        end
        
        xsize = size(img,2);
        ysize = size(img,1);
        hAxes = gca;
        hold on;
        
        % show detections
        show_boxes ( str_detected_faces.i_face_regions', hAxes);        
        
        % plot text with estimated attributes nex to the bounding boxes
        str_settings_text = [];
        str_settings_text.c_color_text = [255 0 0 ] / 255;
        str_settings_text.c_color_bg   = [255 200 200 ] / 255;
        str_settings_text.i_fontsize   = 15;
            
        
        
        for idx=1:size(str_detected_faces.i_face_regions,1)
            
            writeTextToImage ( s_est_attributes_combined{idx}, ...
                               [0.000 + double(str_detected_faces.i_face_regions(idx,1))/double(xsize) ... 
                                1.015 - double(str_detected_faces.i_face_regions(idx,2))/double(ysize)], ...
                                str_settings_text ...
                             );                            
            
        end
        hold off;
        
        
        
        b_write_results = getFieldWithDefault ( str_settings, 'b_write_results', false );
        
        if ( b_write_results ) 
            s_dest_to_save = getFieldWithDefault ( str_settings, 's_dest_to_save', './ape_result' );
            %saveas(hFig,sprintf('%s%s',s_dest_to_save,'.png'),'png')
            print('-dpng','-r600',sprintf('%s%s',s_dest_to_save,'.png'))
            saveas(hFig,sprintf('%s%s',s_dest_to_save,'.eps'),'epsc')
            system(sprintf('epstopdf %s',sprintf('%s%s',s_dest_to_save,'.eps')));            
            
            s_fn_orig = str_settings.s_fn;
            printResultsToSVG(  sprintf('%s%s',s_dest_to_save,'.svg'), str_detected_faces, s_est_attributes_combined, s_fn_orig, xsize, ysize );
        end
       
    
    
        % clean up
        f_timeToWait = getFieldWithDefault ( str_settings, 'f_timeToWait', 2.0 );
        pause( f_timeToWait )
        close ( hFig );
    end     
    
end

function printResultsToSVG(  s_fn_dest_svg, str_detected_faces, s_est_attributes_combined, s_fn_orig, i_width, i_height )

    %% compute svg text


    
    s_svg = {};

    s_start = sprintf('<svg width="%dpx" height="%dpx" viewBox="0 0 %d %d"',i_width, i_height, i_width, i_height);
    s_start = sprintf('%s xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">\n', s_start);
    
    s_svg = [s_svg,s_start];
    
    % write svg styles
    s_svg = [s_svg, '<style type="text/css">'];
    s_svg = [s_svg, '  <![CDATA['];

    i_linewidth = 5;
    sRGB_box    = sprintf('rgb(%d,%d,%d)',255,0,0);    
    s_svg = [s_svg, sprintf('\nrect.detection{\nstroke:%s;\nfill:none;stroke-width:%d;\n}',  sRGB_box, i_linewidth ) ];
    
    i_fontWidth = 22;%
    sRGB_text   = sprintf('rgb(%d,%d,%d)',255,0,0);    
    s_svg = [s_svg, sprintf('\ntext.attributeinfo{\nfont-size:%d;\nfill:%s;\n}',  i_fontWidth, sRGB_text ) ];    
        
    s_svg = [s_svg, '  ]]>'];    
    s_svg = [s_svg, '</style>'];        
      

    
    
    % write image
    s_svg = [s_svg, '"<!-- original image ========================================================== -->"'];
    s_img = sprintf('<image width="%d" height="%d" xlink:href="%s" />', i_width, i_height, s_fn_orig);
    s_svg = [s_svg, s_img];
    
    
    % write bounding boxes
    s_svg = [s_svg, '"<!-- bounding boxes ========================================================== -->"'];

    
    boxes = str_detected_faces.i_face_regions';
    if ( ~isempty(boxes) )
      i_num_boxes = size(boxes, 2);
      
      for i = 1:i_num_boxes
        x_left   = boxes(1,i);
        y_top    = boxes(2,i);
        i_width_box    = boxes(3,i);
        i_height_box   = boxes(4,i);       
        
        s_svg = [s_svg, sprintf( '<rect x="%d" y="%d" width="%d" height="%d" class="detection" />', x_left, y_top, i_width_box, i_height_box ) ];
        
      end
      
    end    
    
    % write text boxes
    s_svg = [s_svg, '"<!-- identification and attributes ========================================================== -->"'];
   
    
    for idx=1:size(str_detected_faces.i_face_regions,1)

        s_text = sprintf('<text x="%d" y="%d" class="attributeinfo">%s</text>' , ...
            str_detected_faces.i_face_regions(idx,1), ...
            str_detected_faces.i_face_regions(idx,2)-round(i_fontWidth/3), ...
            s_est_attributes_combined{idx} ...
            ); 
        s_svg = [s_svg, s_text];

    end    

    s_svg = [s_svg, '</svg>'];

    %% write everything
    h = fopen(s_fn_dest_svg,'w+');
    cellfun( @(c)fprintf(h,'%s\n', c), s_svg);
    fclose(h);

end