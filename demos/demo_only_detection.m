function str_results_all = demo_only_detection
% function str_results_all = demo_only_detection
%  BRIEF
%    Run a pre-trained object detection to detect chimpanzee faces in images. 
%    No further analysis is provided.
%
%    In this demo, we use an object detection network using darknet's YOLO
%    approach. Darknet is called extremely inefficient and the entire network 
%    is loaded from disk for every new image - hence, this is just a
%    what-is-possible showcase. If interfaced properly, yolo-models do
%    offer realtime capability (~30fps for medium-sized models and GPU
%    support).
%
%  INPUT
%    
%    str_settings -- struct, optional, the following fields are supported
%
%  OUTPUT
% 
%  author: Alexander Freytag

    %% set up required directories

    s_cacheDir = './pipeline/cache/';

    if ( ~(exist( s_cacheDir, 'dir' ) ) )
        mkdir ( s_cacheDir );
    end

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
    global s_path_to_chimp_repo;
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

    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_feature_extraction   = str_feature_extraction;


    %% settings for 3.1 - decide for known/unknown of each face hypothesis (open-set)
    str_settings_novelty = [];% that's the overall struct for everything which is identification-related
    str_settings_novelty.b_do_novelty_detection  = false;
    %
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_novelty_detection         = str_settings_novelty;
    
    
    %% settings for 3.2 - classify each face hypothesis (closed-sed)
    str_identification = []; % that's the overall struct for everything which is identification-related
    str_identification.b_do_identification  = false;
    %
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_identification    = str_identification;


    %% settings for 4 estimate age of each face hypothesis
    str_age_estimation = []; % that's the overall struct for everything which is identification-related
    str_age_estimation.b_do_age_estimation  = false;
    %
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_age_estimation   = str_age_estimation;

    %% settings for 5 estimate age group of each face hypothesis
    str_age_group_estimation = []; % that's the overall struct for everything which is identification-related
    str_age_group_estimation.b_do_age_group_estimation  = false;
    %
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_age_group_estimation   = str_age_group_estimation;

    %% settings for 6 estimate gender of each face hypothesis
    str_gender_estimation = []; % that's the overall struct for everything which is identification-related
    str_gender_estimation.b_do_gender_estimation  = false;
    %
    % set this overall struct for identification to the settings struct for the
    % entire pipeline
    str_settings.str_gender_estimation = str_gender_estimation;


    %% general options
    str_settings.b_visualize_results = true;
    str_settings.b_write_results     = false;
    s_dest_results_main              = sprintf('%sdemos/results/', s_path_to_chimp_repo );
    str_settings.f_timeToWait        = 5;
    

    %% specify the test image 
    % %option 1
    % %first face is in training set - this is the corresponding image
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
        str_results_all{ i_perm(i_imgIdx) } = str_results_all;
    end
end
