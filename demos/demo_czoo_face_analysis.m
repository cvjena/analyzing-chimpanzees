function str_results_all = demo_czoo_face_analysis
% function str_results_all = demo_czoo_face_analysis
%  BRIEF
%    
%    1) Loop over all images within CZoo
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
%    1) czoo dataset
%    2) caffe for feature extraction
%    3) LibLinear for classification
%    4) gpml for regression
%    -> see initWorkspaceChimpanzees.m
% 
%  author: Alexander Freytag

    %% set up required directories
    global s_path_to_chimp_repo;
    s_cacheDir = sprintf('%spipeline/cache/', s_path_to_chimp_repo );

    if ( ~(exist( s_cacheDir, 'dir' ) ) )
        mkdir ( s_cacheDir );
    end

    %% settings for 1 - detect and localize faces
    str_detection = [];
    
 
        % use detection model
    str_face_detector                   = struct('name', 'Assume entire image is as face', 'mfunction', @face_detector_entire_image );
    str_settings_tmp                    = [];
    str_settings_tmp.b_show_detections  = false;
    %
    
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
    s_images = { sprintf( '%sdemos/data/img-id1-object-1.png', s_path_to_chimp_repo ), ...
                 sprintf( '%sdemos/data/img-id4-object-1.png', s_path_to_chimp_repo ) ...
               };

%     % %option 2
%     % loop over images of the CZoo dataset
%     
%     % set the folder which contains the data we sent in february
%     % requires the *_information.mat and filelist_face_images.txt
%     %
%     global s_path_to_chimp_face_datasets;
%     
%     s_destCZoo          = sprintf( '%s/datasets_cropped_chimpanzee_faces/data_CZoo/', s_path_to_chimp_face_datasets );
%     
%     % in this demo, we only need the image's filenames, since we
%     % do not compare against GT values
%     settingsLoad.b_load_age                      = false;
%     settingsLoad.b_load_gender                   = false;
%     settingsLoad.b_load_age_group                = false;
%     settingsLoad.b_load_identity                 = false;
%     settingsLoad.b_load_keypoint_information     = false;
%     dataset_chimpansees                          = load_chimpansees( s_destCZoo, settingsLoad );
% 
%     s_destSplits   = sprintf( '%s/demo_access_data/dataset_splits_CZoo.mat' , s_path_to_chimp_face_datasets);
% 
%     load ( s_destSplits,  'dataset_splits' );
% 
%     % use first split    
%     datasplits = dataset_splits{1};
%     idxTrain   = datasplits.idxTrain;
%     idxTest    = datasplits.idxTest;        
% 
%     % these are the file names to the cropped images, i.e., they only
%     % contain bounding boxes of the ape's faces
%     s_fn_images_train = dataset_chimpansees.s_images( idxTrain );
%     s_fn_images_test  = dataset_chimpansees.s_images( idxTest );
% 
%     % let's work on test images only in this demo.
%     s_images = s_fn_images_test;

    str_results_all = {};
    
    %FIXME set random seed if desired
    rng(4711);
    
    i_perm = randperm( length( s_images ) );
    for i_imgIdx=1:length( s_images )
        s_fn        = s_images { i_perm(i_imgIdx) };
        image       = imread ( s_fn ); 
        
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
