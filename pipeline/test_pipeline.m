%s_fn = '/home/freytag/experiments/2015-11-18-schimpansen-leipzig/preprocess/data_ChimpZoo/face_images/img-id1-object-1.png';
s_fn = '/home/dbv/datasets/schimpansen_leipzig/ChimpTai/Deschner_01001_00001.png';
image = imread ( s_fn );

%% settings for 1 - detect and localize faces
str_settings_detection = [];

str_face_detector                = struct('name', 'ground truth', 'mfunction', @face_detector_ground_truth, 'settings', [] );
str_face_detector.settings.s_fn               = s_fn;
str_face_detector.settings.b_show_detections  = true;
%
str_settings_detection.str_face_detector      = str_face_detector;
%
str_settings.str_settings_detection           = str_settings_detection;



%% settings for 2 - extract features of every face
str_settings_feature_extraction = [];

str_feature_extractor                = struct('name', 'pre-computed CNN activations', 'mfunction', @feature_extractor_precomputed_CNN_activations, 'settings', [] );
%
str_feature_extractor.settings.s_fn   = s_fn;
%
s_destData = '/home/freytag/experiments/2015-11-18-schimpansen-leipzig/preprocess/data_ChimpTai/';
settingsLoad.b_load_age               = true;
settingsLoad.b_load_gender            = true;
settingsLoad.b_load_age_group         = true;
settingsLoad.b_load_identity          = true;
settingsLoad.b_load_dataset_name      = false;
dataset_chimpansees                   = load_chimpansees( s_destData, settingsLoad );
str_feature_extractor.settings.dataset_chimpansees ...
                                      = dataset_chimpansees;
%
str_settings_feature_extraction.str_feature_extractor  = str_feature_extractor;
%
str_settings.str_settings_feature_extraction           = str_settings_feature_extraction;


% %% settings for 3.1 - decide for known/unknown of each face hypothesis (open-set)
% str_settings.str_settings_novelty = [];
% str_settings_novelty.b_do_novelty_detection = true;
% 
% str_settings_novelty.b_do_novelty_detection = true;
% 
% %% settings for 3.2 - classify each face hypothesis (closed-sed)
% str_settings.str_settings_identification = [];
% str_settings_identification.b_do_identification = true;
% 
% %% settings for 4 estimate age of each face hypothesis
% str_settings.str_settings_age_estimation = [];
% str_settings_age_estimation.b_do_age_estimation = true;
% 
% %% settings for 5 estimate gender of each face hypothesis
% str_settings.str_settings_gender_estimation = [];
% str_settings_gender_estimation.b_do_gender_estimation = true;
% 
%      = getFieldWithDefault ( settings, 'str_settings_detection', []);
%     str_face_detector = getFieldWithDefault ( str_settings_novelty, 'str_face_detector', struct('name', {}, 'mfunction', {}, 'settings', {} ) );
%     
% 
%     str_settings_feature_extraction = getFieldWithDefault ( settings, 'str_settings_feature_extraction', []);
%     
%     %% 
%     str_settings_novelty = getFieldWithDefault ( settings, 'str_settings_novelty', []);
%     
%     b_do_novelty_detection = getFieldWithDefault ( str_settings_novelty, 'b_do_novelty_detection', true );
%     str_novelty_detector = getFieldWithDefault ( str_settings_novelty, 'str_novelty_detector', struct('name', {}, 'mfunction', {}, 'settings', {} ) );
%     
%     %% 
%     str_settings_identification = getFieldWithDefault ( settings, 'str_settings_identification', []);
%     
%     b_do_identification = getFieldWithDefault ( str_settings_identification, 'b_do_identification', true );
%     
%     %% 
%     str_settings_age_estimation = getFieldWithDefault ( settings, 'str_settings_age_estimation', []);
%     
%     b_do_age_estimation = getFieldWithDefault ( str_settings_age_estimation, 'b_do_age_estimation', true );
%     
%     %% 
%     str_settings_gender_estimation = getFieldWithDefault ( settings, 'str_settings_gender_estimation', []);
%     
%     b_do_gender_estimation = getFieldWithDefault ( str_settings_gender_estimation, 'b_do_gender_estimation', true );

str_results = pipeline_all_about_apes ( image, str_settings );
