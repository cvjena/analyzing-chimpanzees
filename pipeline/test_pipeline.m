%% set up required directories

s_cacheDir = './pipeline/cache/';

if ( ~(exist( s_cacheDir, 'dir' ) ) )
    mkdir ( s_cacheDir );
end

%% specify the test image 
%s_fn = '/home/dbv/datasets/schimpansen_leipzig/ChimpTai/Deschner_01001_00001.png';
s_fn  = '/home/dbv/datasets/schimpansen_leipzig/ChimpZoo/Alex_25-06-10_T00_02_09.png';

image = imread ( s_fn );

%% settings for 1 - detect and localize faces
str_detection = [];

str_face_detector                   = struct('name', 'ground truth', 'mfunction', @face_detector_ground_truth );
str_settings_tmp                    = [];
str_settings_tmp.s_fn               = s_fn;
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
str_feature_extraction = [];

str_feature_extractor       = struct('name', 'pre-computed CNN activations', 'mfunction', @feature_extractor_precomputed_CNN_activations );
%
str_settings_tmp            = [];
str_settings_tmp.s_fn       = s_fn;
str_settings_tmp.s_destFeat = '/home/freytag/experiments/2015-11-18-schimpansen-leipzig/features/ChimpZoo/AlexNet/featpool5.mat';
%
s_destData = '/home/freytag/experiments/2015-11-18-schimpansen-leipzig/preprocess/data_ChimpZoo/';
settingsLoad.b_load_age               = false;
settingsLoad.b_load_gender            = false;
settingsLoad.b_load_age_group         = false;
settingsLoad.b_load_identity          = false;
settingsLoad.b_load_dataset_name      = false;
dataset_chimpansees                   = load_chimpansees( s_destData, settingsLoad );
str_settings_tmp.dataset              = dataset_chimpansees;
%
s_destDatasetUncropped                = '/home/freytag/experiments/2015-11-18-schimpansen-leipzig/images/filelist_ChimpZoo.txt';
% fileId value - open the file
fid = fopen( s_destDatasetUncropped );
% reads data from open test file into cell array (%s -> read string)
s_images = textscan(fid, '%s', 'Delimiter','\n');
% get all images
s_images = s_images{1};
%
fclose ( fid );
%
str_settings_tmp.s_imagesUncropped    = s_images;


%
str_feature_extraction.str_feature_extractor  ...
                                      = str_feature_extractor;
str_feature_extraction.str_settings_feature_extraction ...
                                      = str_settings_tmp;
%
str_settings.str_feature_extraction   = str_feature_extraction;


% %% settings for 3.1 - decide for known/unknown of each face hypothesis (open-set)
% str_settings.str_settings_novelty = [];
% str_settings_novelty.b_do_novelty_detection = true;
% 
% str_settings_novelty.b_do_novelty_detection = true;
% 
%% settings for 3.2 - classify each face hypothesis (closed-sed)
str_identification = [];
str_settings_tmp   = [];

str_settings_tmp.b_do_identification = true;

str_identifier                    = struct('name', 'Linear SVM', 'mfunction', @face_identifier_linear_SVM );

%
str_identification.str_identifier  ...
                                  = str_identifier;
str_identification.str_settings_identification ...
                                  = str_settings_tmp;
%
str_settings.str_identification   = str_identification;

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


%% general options
str_settings.b_visualize_results = true;

str_results = pipeline_all_about_apes ( image, str_settings )
