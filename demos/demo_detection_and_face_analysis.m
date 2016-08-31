function str_results_all = demo_detection_and_face_analysis
% function str_results_all = demo_detection_and_face_analysis
%  BRIEF
%    Demo of the entire pipeline for analyzing ape images:
%    1) YOLO for detecting faces (this takes a lot of time since we load the
%       network into memory upon each detection call)
%    2) Features as CNN codes from AlexNet using Caffe
%    3.1) No novelty detection / rejection
%    3.2) Identification with Linear SVM
%    4) Age regression with Gaussian process regression
%    5) Age group estimation with Linear SVM
%    6) Gender estimation with Linear SVM
%
%  OUTPUT
%      str_results_all
%    
%
%  REQUIREMENTS
%    1) darknet for object detection
%    2) caffe for feature extraction
%    3) LibLinear for classification
%    4) gpml for regression
%    -> see initWorkspaceChimpanzees.m
% 
%  author: Alexander Freytag

    %% set up required directories
    global s_path_to_chimp_repo;

    %% settings for 1 - detect and localize faces
    str_detection = [];
    
 
    % use detection model
    str_face_detector                   = struct('name', 'Run Yolo Detecion Model via Terminal', 'mfunction', @face_detector_yolo_via_terminal );
    str_settings_tmp                    = [];
    str_settings_tmp.s_fn               = '';
    str_settings_tmp.b_show_detections  = false;
    %
    global s_path_to_darknet;
    str_settings_tmp.s_path_to_darknet  = s_path_to_darknet;
    %
    str_settings_tmp.s_path_to_cfg      = sprintf('%sdemos/models/yolo-ape-detection/yolo-for-zoo.cfg', s_path_to_chimp_repo );
    str_settings_tmp.s_path_to_weights  = sprintf('%sdemos/models/yolo-ape-detection/yolo-for-zoo_20000.weights', s_path_to_chimp_repo );
    str_settings_tmp.s_fn_class_labels  = sprintf('%sdemos/models/yolo-ape-detection/classnames_zoo_single_class.txt', s_path_to_chimp_repo );
    str_settings_tmp.s_fn_boxes_tmp     = '/tmp/boxes_tmp.txt';
    str_settings_tmp.f_thresh           = 0.1;
    str_settings_tmp.f_nms              = 0.5;
   

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
    str_feature_extractor       = struct('name', 'Extract CNN activations with Caffe', 'mfunction', @feature_extractor_CNN_activations );


    % this will be the config struct
    str_settings_tmp       = [];        

    % setup caffe framework
    b_useGPU = false; % true for gpu support
    i_idxGPU = 0; % remind that the CUDA device count is 0-based!
    if ( b_useGPU )
        caffe.set_mode_gpu();
        caffe.set_device( i_idxGPU );
    else
        caffe.set_mode_cpu();
    end

    % specify the network of your choice. most of them come shipped with
    % caffe... just go to your caffe installation and select the model
    %
    % Note: however, make sure that the classification models used lateron have
    % been trained on cnn activations for your selected network!s
    %
    global s_path_to_caffe;
    %TODO adapt that!
    s_path_to_caffe_models = '/home/freytag/lib/caffe_models/';
    %
    % select a CNN precomputed from ImageNet
    s_selected_model_deploy  = 'bvlc_reference_caffenet/deploy.prototxt';
    % the caffe models can be downloaded from the caffe webpage
    % https://github.com/BVLC/caffe/wiki/Model-Zoo
    s_selected_model_weights = 'bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel';
    %
    s_pathtodeployfile       =  sprintf( '%s%s', s_path_to_caffe_models, s_selected_model_deploy );
    s_pathtomodel            =  sprintf( '%s%s', s_path_to_caffe_models, s_selected_model_weights );
    %
    s_phase                  = 'test'; % run with phase test (so that dropout isn't applied)    
    %
    %specify the mean file (relative to caffe's matlab directory)
    s_path_to_mean           = '+caffe/imagenet/ilsvrc_2012_mean.mat'; %imagenet_mean.binaryproto';    
    s_meanfile               = sprintf( '%s%s', s_path_to_caffe, s_path_to_mean );
    %    
    % do we want to operate on single images - yes!
    b_reshape_for_single_image_processing = true;

    [net, mean_data]         = caffe_load_network ( s_pathtodeployfile, s_pathtomodel, s_phase, s_meanfile, b_reshape_for_single_image_processing);

    str_settings_tmp.net     = net;
    str_settings_tmp.f_mean  = mean_data;

    %
    % which layer to extract activations from?
    str_settingsCaffe.s_layer = 'pool5';
    %
    % further options to post-process the cnn activations
    %
    % see Freytag et al., GCPR'16 for detailed explanations.
    % for this demo, we de-activate everything....
    str_settingsCaffe.b_apply_bilinear_pooling ...
                              = false;
    str_settingsCaffe.b_skip_normalization_in_bilinear_pooling ...
                              = false;
    str_settingsCaffe.b_apply_log_M ...
                              = false;
    str_settingsCaffe.f_sigma = 1e-5;

    str_settings_tmp.str_settingsCaffe ...
                              = str_settingsCaffe;

    

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
    str_identifier                     = struct('name', 'Linear SVM', 'mfunction', @face_identifier_linear_SVM );

    % this will be the config struct
    str_settings_tmp   = [];     

    s_path_to_idenfication_model = sprintf('%sdemos/models/identification/model_identification_ChimpZoo.mat', s_path_to_chimp_repo );
    load (  s_path_to_idenfication_model, 'svmmodel', 'settingsLibLinear', 's_all_identities' );
    str_settings_tmp.svmmodel          = svmmodel;
    str_settings_tmp.settingsLibLinear = settingsLibLinear;
    str_settings_tmp.s_all_identities  = s_all_identities;

    % set method and config to overall struct
    str_identification.str_identifier  = str_identifier;
    str_identification.str_settings_identification ...
                                       = str_settings_tmp;
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_identification    = str_identification;


    %% settings for 4 estimate age of each face hypothesis
    str_age_estimation = []; % that's the overall struct for everything which is identification-related
    str_age_estimation.b_do_age_estimation  = true;


    % this is the actual method
    str_age_estimator = struct('name', 'GP regression', 'mfunction', @age_regressor_GP );
    
    % this will be the config struct
    str_settings_tmp   = [];     
        
    s_path_to_age_model = sprintf('%sdemos/models/age/model_age_estimation_ChimpZoo.mat', s_path_to_chimp_repo );
    res = load (  s_path_to_age_model, 'model', 'settingsGP', 'idxTrain', 's_destFeat' );  
    
    res.s_destFeat          = sprintf('%s%s', s_path_to_chimp_repo, res.s_destFeat );
    
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
    str_age_group_estimator = struct('name', 'Linear SVM', 'mfunction', @age_group_classifier_linear_SVM );

    % this will be the config struct
    str_settings_tmp   = [];    

    s_path_to_age_group_model = sprintf('%sdemos/models/age-group/model_age_group_classification_ChimpZoo.mat', s_path_to_chimp_repo );
    load (  s_path_to_age_group_model, 'svmmodel', 'settingsLibLinear', 's_possible_age_groups' );  
    
    str_settings_tmp.svmmodel               = svmmodel;
    str_settings_tmp.settingsLibLinear      = settingsLibLinear;
    str_settings_tmp.s_possible_age_groups  = s_possible_age_groups;


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
    str_gender_estimator = struct('name', 'Linear SVM', 'mfunction', @gender_classifier_linear_SVM );

    % this will be the config struct
    str_settings_tmp   = [];    
    
    s_path_to_gender_model = sprintf('%sdemos/models/gender/model_gender_classification_ChimpZoo.mat', s_path_to_chimp_repo );
    load (  s_path_to_gender_model, 'svmmodel', 'settingsLibLinear', 's_all_genders' ); 
    
    str_settings_tmp.svmmodel               = svmmodel;
    str_settings_tmp.settingsLibLinear      = settingsLibLinear;
    str_settings_tmp.s_all_genders          =  s_all_genders;

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
    str_settings.b_write_results     = false;
    s_dest_results_main              = sprintf('%sdemos/results/', s_path_to_chimp_repo );
    str_settings.f_timeToWait        = 5;
    

    %% specify the test image 
    % %option 1 - test on 2 provided images
    s_images = { sprintf( '%sdemos/data/Alex_25-06-10_T00_02_09.png', s_path_to_chimp_repo ), ...
                 sprintf( '%sdemos/data/Alex_30-06-10_1_T00_00_00_Jahaga.png', s_path_to_chimp_repo ) ...
               };

%     % %option 2
%     % loop over images of the original dataset, which will soon be released
% 
%     s_destDatasetUncropped                = '/home/freytag/experiments/2015-11-18-schimpansen-leipzig/images/filelist_ChimpZoo.txt';
%     % fileId value - open the file
%     fid = fopen( s_destDatasetUncropped );
%     % reads data from open test file into cell array (%s -> read string)
%     s_images = textscan(fid, '%s', 'Delimiter','\n');
%     % get all images
%     s_images = s_images{1};
%     %
%     fclose ( fid );


    str_results_all = {};
    
    %FIXME set random seed if desired
    rng(4711);
    
    i_perm = randperm( length( s_images ) );
    for i_imgIdx=1:length( s_images )
        s_fn        = s_images { i_perm(i_imgIdx) };
        image       = imread ( s_fn ); 

        % adapt nasty image-fn-specific gt-settings
        str_settings.str_face_detection.str_settings_face_detection.s_fn             = s_fn;
        
        if ( str_settings.b_write_results )
            idxDot   = strfind ( s_fn, '.' );
            idxSlash = strfind ( s_fn, '/'  );
            s_image_name = s_fn( (idxSlash(end)+1) : (idxDot(end)-1) );
            str_settings.s_dest_to_save = sprintf( '%s%s', s_dest_results_main, s_image_name);
        end


        % go go go ...
        str_results = pipeline_all_about_apes ( image, str_settings );

        str_results_all{ i_perm(i_imgIdx) } = str_results;
    end

    % clear loaded networks and other gpu memory allocated by caffe
    caffe.reset_all;
    
end
