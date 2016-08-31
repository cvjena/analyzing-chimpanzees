function str_results_all = demo_czoo_evaluation
% function str_results_all = demo_czoo_evaluation
%  BRIEF
%    
%    1) Loop over all images within CZoo
%    2) Use pre-computed features (CNN codes from AlexNet using Caffe)
%    3.1) No novelty detection / rejection
%    3.2) Identification with Linear SVM
%    4) Age regression with Gaussian process regression
%    5) Age group estimation with Linear SVM
%    6) Gender estimation with Linear SVM
%    X: evaluation against ground truth
%
%  OUTPUT
%      str_results_all
%    
%
%  REQUIREMENTS
%    1) czoo dataset
%    2) pre-computed features
%    3) LibLinear for classification
%    4) gpml for regression
%    -> see initWorkspaceChimpanzees.m
% 
%  author: Alexander Freytag

    %% set up required directories
    global s_path_to_chimp_repo;

    
    %%  Pre-compute features for all images
 
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
    % do we want to operate on single images - no! We want to pass batches
    % of images at once...
    b_reshape_for_single_image_processing = false;

    [net, mean_data]         = caffe_load_network ( s_pathtodeployfile, s_pathtomodel, s_phase, s_meanfile, b_reshape_for_single_image_processing);
    
    %% extract features    

    s_cacheDir = sprintf('%sdemos/cache/', s_path_to_chimp_repo );

    if ( ~(exist( s_cacheDir, 'dir' ) ) )
        mkdir ( s_cacheDir );
    end
    
    s_destSaveFeat = sprintf( '%sChimpZoo/BVLC-reference/', s_cacheDir );
    
    % ChimpZoo    
    global s_path_to_chimp_face_datasets;
    s_filelist_czoo      = sprintf( '%s/datasets_cropped_chimpanzee_faces/data_CZoo/filelist_face_images.txt', s_path_to_chimp_face_datasets );
    
    settings_feat                           = [];
    settings_feat.s_layer                   = 'pool5';
    % the filelist contains only names relative to its position
    settings_feat.s_filename_prefix         = sprintf( '%s/datasets_cropped_chimpanzee_faces/data_CZoo/', s_path_to_chimp_face_datasets );


    s_destSaveFilename = sprintf('%sfeat%s.mat', s_destSaveFeat, settings_feat.s_layer);
    
    if ( ~exist( s_destSaveFilename, 'file' ) )
        
        % create data structure for features
        feat = struct ( 'name', settings_feat.s_layer  );   
        %
        % compute features for all images
        feat.(settings_feat.s_layer) = caffe_features_multiple_images( s_filelist_czoo, mean_data, net, settings_feat );

        % store features at disk
        if ( ~exist ( s_destSaveFeat, 'dir' ) )
            mkdir ( s_destSaveFeat );
        end
        %  
        save ( s_destSaveFilename, 'feat', '-v7.3', 'settings_feat');
        % clean-up
        clear ( 'feat' );         
    end

    % clean-up
    caffe.reset_all();
    
 
    %%  load data from the CZoo dataset
    
    % set the folder which contains the data we sent in february
    % requires the *_information.mat and filelist_face_images.txt
    %
    s_destCZoo          = sprintf( '%s/datasets_cropped_chimpanzee_faces/data_CZoo/', s_path_to_chimp_face_datasets );
    
    % load all ground truth information for verification
    settingsLoad.b_load_age                      = true;
    settingsLoad.b_load_gender                   = true;
    settingsLoad.b_load_age_group                = true;
    settingsLoad.b_load_identity                 = true;
    settingsLoad.b_load_keypoint_information     = false;
    dataset_chimpansees                          = load_chimpansees( s_destCZoo, settingsLoad );

    s_destSplits   = sprintf( '%s/demo_access_data/dataset_splits_CZoo.mat' , s_path_to_chimp_face_datasets);

    load ( s_destSplits,  'dataset_splits' );

    % for demo purpose, use only first split    
    datasplits = dataset_splits{1};
    idxTrain   = datasplits.idxTrain;
    idxTest    = datasplits.idxTest;        

    % these are the file names to the cropped images, i.e., they only
    % contain bounding boxes of the ape's faces
    s_fn_images_train = dataset_chimpansees.s_images( idxTrain );
    s_fn_images_test  = dataset_chimpansees.s_images( idxTest );

    if ( nargout > 0 )
        str_results_all = {};
    end
    
    %% set random seed to specified value for reproduction of results with random splits during cross validation
    rng(123);
    
    %% do evaluation for age group prediction
    % 
    str_settings_age_group.b_verbose         = false;
    %
    settingsLibLinear                        =  [];
    settingsLibLinear.i_svmSolver            =  2;
    settingsLibLinear.f_svm_C                =  1;
    settingsLibLinear.b_verbose              =  false;    
    settingsLibLinear.b_cross_val            =  false;    
    settingsLibLinear.i_num_folds            =  10;        
    str_settings_age_group.settingsLibLinear =  settingsLibLinear;
    %
    %
    settingsData                             = [];
    settingsData.b_data_reclassif            = false;
    str_settings_age_group.settingsData      = settingsData;  
    % use the given split into training and testing
    str_settings_age_group.datasplits        = datasplits;
    %
    %
    str_settings_age_group.s_destFeat = sprintf('%sfeat%s.mat', s_destSaveFeat, settings_feat.s_layer);
    
    disp ( sprintf ( '\nDo evaluation for age group prediction.\n') )
    results_age_group = chimpansee_age_group_glassification( dataset_chimpansees, str_settings_age_group );
    disp ( sprintf ( 'Result of age group prediction: %3.2f%% ARR (expected: 90.51%%) \n', 100*results_age_group.f_arr) )
    
    clear( 'str_settings_age_group' );
    
    if ( nargout > 0 )
        str_results_all.results_age_group = results_age_group;
    end
    
    %% do evaluation for age estimation
    %
    str_settings_age.b_verbose          = false;
    % enable parameter optimization
    str_settings_age.b_do_optimization  = true;
    str_settings_age.f_paramNoise       = (2*ones(size(-7:1:2))).^(-7:1:2);
    str_settings_age.f_paramBW          = 1:10;        
    str_settings_age.i_num_folds        = 5; 
    %      use only one fold for training and n-1 folds for validation?
    str_settings_age.b_use_one_of_n_for_cv   = false;
    % not necessary due to parameter optimization which results in a suitable
    % bandwidth value
    str_settings_age.b_normalize_features_L2 = false;
    
    %
    %
    settingsData                       = [];
    settingsData.b_data_reclassif      = false; 
    str_settings_age.settingsData      = settingsData;
    % use the given split into training and testing
    str_settings_age.datasplits        = datasplits;    
    %
    %
    str_settings_age.s_destFeat        = sprintf('%sfeat%s.mat', s_destSaveFeat, settings_feat.s_layer);    
    
    disp ( sprintf ( '\nDo evaluation for age estimation.\n') )
    results_age = chimpansee_age_regression ( dataset_chimpansees, str_settings_age );
    disp ( sprintf ( 'Result of age estimation: %2.2fy L1 error (expected: 4.17y) \n', results_age.f_error) )     

    
    clear( 'str_settings_age' );
    
    if ( nargout > 0 )
        str_results_all.results_age = results_age;
    end    
     
    %% do evaluation for identification
    str_settings_identification.b_verbose    = false;
    %
    settingsLibLinear                        =  [];
    settingsLibLinear.i_svmSolver            =  2;
    settingsLibLinear.f_svm_C                =  1;
    settingsLibLinear.b_verbose              =  false;    
    settingsLibLinear.b_cross_val            =  false;    
    settingsLibLinear.i_num_folds            =  10;        
    str_settings_identification.settingsLibLinear =  settingsLibLinear;
    %
    %
    settingsData                             = [];
    settingsData.b_data_reclassif            = false;
    str_settings_identification.settingsData = settingsData;  
    % use the given split into training and testing
    str_settings_identification.datasplits   = datasplits;
    %
    %
    str_settings_identification.s_destFeat = sprintf('%sfeat%s.mat', s_destSaveFeat, settings_feat.s_layer);
    
    disp ( sprintf ( '\nDo evaluation for identification.\n') )
    results_identification = chimpansee_identification( dataset_chimpansees, str_settings_identification );
    disp ( sprintf ( 'Result of identification: %2.2f%% ARR (expected: 90.05%%) \n', 100*results_identification.f_arr) )     
    
    clear( 'str_settings_identification' );
    
    if ( nargout > 0 )
        str_results_all.results_identification = results_identification;
    end    
     
    %% do evalaution for gender prediction
    str_settings_gender.b_verbose            = false;
    %
    settingsLibLinear                        =  [];
    settingsLibLinear.i_svmSolver            =  2;
    settingsLibLinear.f_svm_C                =  1;
    settingsLibLinear.b_verbose              =  false;    
    settingsLibLinear.b_cross_val            =  false;    
    settingsLibLinear.i_num_folds            =  10;        
    str_settings_gender.settingsLibLinear    =  settingsLibLinear;
    %
    %
    settingsData                             = [];
    settingsData.b_data_reclassif            = false;
    str_settings_gender.settingsData         = settingsData;  
    % use the given split into training and testing
    str_settings_gender.datasplits           = datasplits;    
    %
    %
    str_settings_gender.s_destFeat           = sprintf('%sfeat%s.mat', s_destSaveFeat, settings_feat.s_layer);    
     
    disp ( sprintf ( '\nDo evaluation for gender prediction.\n') )
    results_gender = chimpansee_gender_estimation( dataset_chimpansees, str_settings_gender );
    disp ( sprintf ( 'Result of gender prediction: %3.2f%% AUC (expected: 96.75%%) \n', 100*results_gender.f_auc) )     
    
    clear( 'str_settings_gender' );
 
    if ( nargout > 0 )
        str_results_all.results_gender = results_gender;
    end    

    % clear loaded networks and other gpu memory allocated by caffe
    caffe.reset_all;
    
end
