function str_results_all = test_pipeline_ground_truth

    %% set up required directories

    s_cacheDir = './pipeline/cache/';

    if ( ~(exist( s_cacheDir, 'dir' ) ) )
        mkdir ( s_cacheDir );
    end

    %% settings for 1 - detect and localize faces
    str_detection = [];

    str_face_detector                   = struct('name', 'ground truth', 'mfunction', @face_detector_ground_truth );
    str_settings_tmp                    = [];
    str_settings_tmp.s_fn               = '';
    str_settings_tmp.b_show_detections  = false;
    %
    str_settings_tmp.str_settings_detection ...
                                        = str_settings_tmp;
    %                                
    str_face_detection.str_face_detector  ...
                                        = str_face_detector;
    str_face_detection.str_settings_face_detection ...
                                        = str_settings_tmp;                                
    %
    str_settings.str_face_detection     = str_face_detection;



    %% settings for 2 - extract features of every face
    str_feature_extraction  = [];% that's the overall struct for everything which is identification-related
    % we always need to extract features... so no need for a separate flag
    
    % this is the actual method
    % the actual choice doesn't matter if we read ground truth
    % information...
    str_feature_extractor   = struct('name', 'Raw image pixels', 'mfunction', @feature_extractor_image_pixels );
    
    % this will be the config struct
    str_settings_tmp        = []; 
    
    % set method and config to overall struct
    str_feature_extraction.str_feature_extractor  ...
                                          = str_feature_extractor;
    str_feature_extraction.str_settings_feature_extraction ...
                                          = str_settings_tmp;
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_feature_extraction   = str_feature_extraction;


    %% settings for 3.1 - decide for known/unknown of each face hypothesis (open-set)
    str_settings_novelty = [];% that's the overall struct for everything which is identification-related
    str_settings_novelty.b_do_novelty_detection  = false;

    % this is the actual method
    str_novelty_detector        = struct('name', 'Ground Truth Novelty', 'mfunction', @novelty_detector_ground_truth );

    % this will be the config struct
    str_settings_tmp   = []; 

    % set method and config to overall struct
    str_novelty_detection.str_novelty_detector = str_novelty_detector;
    str_novelty_detection.str_settings_novelty_detection ...
                                               = str_settings_tmp;
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_novelty_detection         = str_novelty_detection;

    %% settings for 3.2 - classify each face hypothesis (closed-sed)
    str_identification = []; % that's the overall struct for everything which is identification-related
    str_identification.b_do_identification  = true;


    % this is the actual method
    str_identifier                    = struct('name', 'Ground Truth IDs', 'mfunction', @face_identifier_ground_truth );

    % this will be the config struct
    str_settings_tmp   = []; 

    % set method and config to overall struct
    str_identification.str_identifier       = str_identifier;
    str_identification.str_settings_identification ...
                                            = str_settings_tmp;
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_identification         = str_identification;



    %% settings for 4 estimate age of each face hypothesis
    str_age_estimation = []; % that's the overall struct for everything which is identification-related
    str_age_estimation.b_do_age_estimation  = true;



    % this is the actual method
    str_age_estimator = struct('name', 'Ground Truth Age', 'mfunction', @age_estimator_ground_truth );

    % this will be the config struct
    str_settings_tmp   = [];

    % set method and config to overall struct
    str_age_estimation.str_age_estimator  ...
                                      = str_age_estimator;
    str_age_estimation.str_settings_age_estimation ...
                                      = str_settings_tmp;
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_age_estimation   = str_age_estimation;

    %% settings for 5 estimate age group of each face hypothesis
    str_age_group_estimation = []; % that's the overall struct for everything which is identification-related
    str_age_group_estimation.b_do_age_group_estimation  = true;

    % this is the actual method
    str_age_group_estimator = struct('name', 'Ground Truth Age Group', 'mfunction', @age_group_classifier_ground_truth );

    % this will be the config struct
    str_settings_tmp   = [];

    % set method and config to overall struct
    str_age_group_estimation.str_age_group_estimator  ...
                                      = str_age_group_estimator;
    str_age_group_estimation.str_settings_age_group_estimation ...
                                      = str_settings_tmp;
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_age_group_estimation   = str_age_group_estimation;


    %% settings for 6 estimate gender of each face hypothesis
    str_gender_estimation = []; % that's the overall struct for everything which is identification-related
    str_gender_estimation.b_do_gender_estimation  = true;

    % this is the actual method
    str_gender_estimator = struct('name', 'Ground Truth Gender', 'mfunction', @gender_classifier_ground_truth );

    % this will be the config struct
    str_settings_tmp   = [];

    % set method and config to overall struct
    str_gender_estimation.str_gender_estimator  ...
                                       = str_gender_estimator;
    str_gender_estimation.str_settings_gender_estimation ...
                                       = str_settings_tmp;
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_gender_estimation = str_gender_estimation;


    %% general options
    str_settings.b_visualize_results = true;
    str_settings.b_write_results     = true;
    %s_dest_results_main              = '/home/freytag/experiments/2016-03-15-chimpanzee-detection-and-identification/ChimpZoo/';
    s_dest_results_main              = '/home/freytag/experiments/2016-03-24-chimpanzee-pipeline_results_with_gt_boxes/gt_infos/ChimpZoo/';
    str_settings.f_timeToWait        = 0;


    %% specify the test image 
    % %option 1
    % %first face is in training set - this is the corresponding image
    % s_fn  = '/home/dbv/datasets/schimpansen_leipzig/ChimpZoo/Alex_25-06-10_T00_02_09.png';
    %
    % %option 2
    % %the fourth face is not in training set - this is the corresponding image
    % s_fn  = '/home/dbv/datasets/schimpansen_leipzig/ChimpZoo/Alex_30-06-10_1_T00_00_00_Jahaga.png';
    %
    % %option 3
    % loop over all images


    s_destDatasetUncropped                = '/home/freytag/experiments/2015-11-18-schimpansen-leipzig/images/filelist_ChimpZoo.txt';
    % fileId value - open the file
    fid = fopen( s_destDatasetUncropped );
    % reads data from open test file into cell array (%s -> read string)
    s_images = textscan(fid, '%s', 'Delimiter','\n');
    % get all images
    s_images = s_images{1};
    %
    fclose ( fid );


    str_results_all = {};
    for i_imgIdx=1:length( s_images )
        s_fn        = s_images { i_imgIdx };
        image       = imread ( s_fn ); 

        % adapt nasty image-fn-specific gt-settings
        str_settings.str_face_detection.str_settings_face_detection.s_fn             = s_fn;
        str_settings.str_feature_extraction.str_settings_feature_extraction.s_fn     = s_fn;    
        str_settings.str_novelty_detection.str_settings_novelty_detection.s_fn       = s_fn;    
        str_settings.str_identification.str_settings_identification.s_fn             = s_fn;    
        str_settings.str_age_estimation.str_settings_age_estimation.s_fn             = s_fn;
        str_settings.str_age_group_estimation.str_settings_age_group_estimation.s_fn = s_fn;    
        str_settings.str_gender_estimation.str_settings_gender_estimation.s_fn       = s_fn;
        
        if ( str_settings.b_write_results )
            idxDot   = strfind ( s_fn, '.' );
            idxSlash = strfind ( s_fn, '/'  );
            s_image_name = s_fn( (idxSlash(end)+1) : (idxDot(end)-1) );
            str_settings.s_dest_to_save = sprintf( '%s%s', s_dest_results_main, s_image_name);
        end        


        % go go go ...
        str_results = pipeline_all_about_apes ( image, str_settings );
        str_results_all{i_imgIdx} = str_results_all;
    end
end