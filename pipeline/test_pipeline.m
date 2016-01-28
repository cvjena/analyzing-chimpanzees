%% set up required directories

s_cacheDir = './pipeline/cache/';

if ( ~(exist( s_cacheDir, 'dir' ) ) )
    mkdir ( s_cacheDir );
end

%% settings for 1 - detect and localize faces
str_detection = [];

str_face_detector                   = struct('name', 'ground truth', 'mfunction', @face_detector_ground_truth );
str_settings_tmp                    = [];
str_settings_tmp.s_fn               = '';%s_fn;
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
str_settings_tmp.s_fn       = '';
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

str_identifier                     = struct('name', 'Linear SVM', 'mfunction', @face_identifier_linear_SVM );


load ( './pipeline/cache/model_identification_ChimpZoo.mat' , 'svmmodel', 'settingsLibLinear', 's_all_identities' );
str_settings_tmp.svmmodel          = svmmodel;
str_settings_tmp.settingsLibLinear = settingsLibLinear;
str_settings_tmp.s_all_identities  = s_all_identities;

%
str_identification.str_identifier  ...
                                  = str_identifier;
str_identification.str_settings_identification ...
                                  = str_settings_tmp;
%
str_settings.str_identification   = str_identification;


%% settings for 4 estimate age of each face hypothesis
str_age_estimation = [];
str_settings_tmp   = [];

str_settings_tmp.b_do_age_estimation = true;

str_age_estimator = struct('name', 'GP regression', 'mfunction', @age_regressor_GP );
res = load ( './pipeline/cache/model_age_estimation_ChimpZoo.mat', 'model', 'settingsGP', 'idxTrain', 's_destFeat' );

featCNN = load ( res.s_destFeat );
if ( isfield ( featCNN, 'struct_feat' ) ) % compatibility with MatConvNet
    featCNN = cell2mat(featCNN.struct_feat);
elseif ( isfield ( featCNN, 'feat' ) && isfield ( featCNN.feat, 'name' ) )   % compatibility with Caffe
    featCNN = featCNN.feat.(featCNN.feat.name);
else
    error ( 'CNN features not readable!' )
end
featTrain = featCNN( :, res.idxTrain );

str_settings_tmp.gpmodel    = res.model;
str_settings_tmp.settingsGP = res.settingsGP;
str_settings_tmp.dataTrain  = featTrain;
clear 'featCNN';
clear 'res';

%
str_age_estimation.str_age_estimator  ...
                                  = str_age_estimator;
str_age_estimation.str_settings_age_estimation ...
                                  = str_settings_tmp;
%
str_settings.str_age_estimation   = str_age_estimation;

%% settings for 5 estimate age group of each face hypothesis
str_age_group_estimator = [];
str_settings_tmp        = [];

str_settings_tmp.b_do_age_group_estimation = true;



str_age_group_estimator = struct('name', 'Linear SVM', 'mfunction', @age_group_classifier_linear_SVM );


load ( './pipeline/cache/model_age_group_classification_ChimpZoo.mat' , 'svmmodel', 'settingsLibLinear', 's_possible_age_groups' );
str_settings_tmp.svmmodel               = svmmodel;
str_settings_tmp.settingsLibLinear      = settingsLibLinear;
str_settings_tmp.s_possible_age_groups  = s_possible_age_groups;


%
str_age_group_estimation.str_age_group_estimator  ...
                                  = str_age_group_estimator;
str_age_group_estimation.str_settings_age_group_estimation ...
                                  = str_settings_tmp;
%
str_settings.str_age_group_estimation   = str_age_group_estimation;


%% settings for 6 estimate gender of each face hypothesis
str_gender_estimator = [];
str_settings_tmp     = [];

str_settings_tmp.b_do_gender_estimation = true;

str_gender_estimator = struct('name', 'Linear SVM', 'mfunction', @gender_classifier_linear_SVM );

load ( './pipeline/cache/model_gender_classification_ChimpZoo.mat' , 'svmmodel', 'settingsLibLinear', 's_possible_genders' );
str_settings_tmp.svmmodel               = svmmodel;
str_settings_tmp.settingsLibLinear      = settingsLibLinear;
str_settings_tmp.s_all_genders          =  s_all_genders;

%
str_gender_estimation.str_gender_estimator  ...
                                   = str_gender_estimator;
str_gender_estimation.str_settings_gender_estimation ...
                                   = str_settings_tmp;
%
str_settings.str_gender_estimation = str_gender_estimation;


%% general options
str_settings.b_visualize_results = true;


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
    str_settings.str_face_detection.str_settings_face_detection.s_fn         = s_fn;
    str_settings.str_feature_extraction.str_settings_feature_extraction.s_fn = s_fn;    
    
    
    % go go go ...
    str_results = pipeline_all_about_apes ( image, str_settings );
    str_results_all{i_imgIdx} = str_results_all;
end
