function initWorkspaceChimpanzees
% function initWorkspaceChimpanzees
% 
% Author: Alexander Freytag
% 
% BRIEF:
%   Add local subfolders and 3rd party libraries to Matlabs work space.
%   NEEDS TO BE ADAPTED TO YOUR SYSTEM!
% 
% 
%   Exemplary call from external position:
%        CHIMPDIR   = '/place/to/this/repository/';
%        currentDir = pwd;
%        cd ( CHIMPDIR );
%        initWorkspaceChimpanzees;
%        cd ( currentDir );
% 
%   Provides s_path_to_chimp_face_datasets as global variable.
% 
%   Author: Alexander Freytag

    %% make current path known as global variable
    % useful for demos etc.
    global s_path_to_chimp_repo;
    s_path_to_chimp_repo = sprintf( '%s/', fullfile(pwd) );


    %% setup paths of 3rd-party libraries in a user-specific manner

    % feature extraction
    CAFFETOOLSDIR       = [];    
    
    % identification
    LIBLINEARDIR        = [];
    LIBLINEARWRAPPERDIR = [];  
    % age regression
    GPMLDIR             = [];
    
    % face detection
    DARKNETDIR          = []; 
    
    % datasets
    CHIMPFACEDATASETDIR = [];
        
    if strcmp( getenv('USER'), 'freytag')     
        [~, s_hostname]       = system( 'hostname' );
        s_hostname            = s_hostname ( 1:(length(s_hostname)-1) ) ;    
        
        % feature extraction
        CAFFETOOLSDIR         = '/home/freytag/code/matlab/caffe_tools/';
        
        % identification
        s_dest_liblinearbuild = sprintf( '%smatlab-%s', '/home/freytag/code/3rdParty/liblinear-1.93/', s_hostname );    
        LIBLINEARDIR          = s_dest_liblinearbuild;
        
        LIBLINEARWRAPPERDIR   = '/home/freytag/code/matlab/classifiers/liblinearWrapper/';
        
        % age regression
        GPMLDIR               = '/home/freytag/code/matlab/gpml/';
        
        % face detection
        DARKNETDIR            = sprintf( '/home/freytag/lib/darknet_%s/', s_hostname );
        
        % datasets
        CHIMPFACEDATASETDIR   =  '/home/freytag/data/chimpanzee_faces/';
        
    elseif strcmp( getenv('USER'), 'alex') 
        
        CAFFETOOLSDIR         = '/home/alex/code/matlab/caffe_tools/';
        
        LIBLINEARDIR          = '/home/alex/code/matlab/liblinearwrapper/';
        
        LIBLINEARWRAPPERDIR   = '/home/alex/code/matlab/libsvmwrapper/';
        
        GPMLDIR               = '/home/alex/code/matlab/matlabChair/gpml/';
        
        DARKNETDIR            = '/home/alex/lib/darknet/';
        
    elseif strcmp( getenv('USER'), 'rodner')
        [~, s_hostname]       = system( 'hostname' );
        s_hostname            = s_hostname ( 1:(length(s_hostname)-1) ) ;

        CAFFETOOLSDIR         = '/home/freytag/code/matlab/caffe_tools/';

        s_dest_liblinearbuild = '/home/freytag/code/3rdParty/liblinear-1.93/matlab-pollux/';
        LIBLINEARDIR          = s_dest_liblinearbuild;

        LIBLINEARWRAPPERDIR   = '/home/freytag/code/matlab/classifiers/liblinearWrapper/';

        GPMLDIR               = '/home/freytag/code/matlab/gpml/';

    elseif strcmp( getenv('USER'), 'simon')     
                
        CAFFETOOLSDIR         = '/home/freytag/code/matlab/caffe_tools/';    
        
    else          
        fprintf('Unknown user %s and unknown default settings', getenv('USER') ); 
    end

    %% add paths which come with this repository
    
    %%
    % add main path
    b_recursive = false; 
    b_overwrite = true;
    s_pathMain  = fullfile(pwd);
    addPathSafely ( s_pathMain, b_recursive, b_overwrite )
    clear ( 's_pathMain' );
    
    %%
    % stuff for preprocessing of provided data
    b_recursive = true; 
    b_overwrite = true;
    s_pathPreProcess = fullfile(pwd, 'preprocess');
    addPathSafely ( s_pathPreProcess, b_recursive, b_overwrite )
    clear ( 's_pathPreProcess' );    

    %%    
    % some useful tiny scripts
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathMisc              = fullfile(pwd, 'misc');
    addPathSafely ( s_pathMisc, b_recursive, b_overwrite )
    clear ( 's_pathMisc' );       
       
    %%    
    % evaluation measures
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathEval              = fullfile(pwd, 'evaluation');
    addPathSafely ( s_pathEval, b_recursive, b_overwrite )
    clear ( 's_pathEval' );    
    
    %%    
    % everything for identification of chimpansees
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathIdent             = fullfile(pwd, 'identification');
    addPathSafely ( s_pathIdent, b_recursive, b_overwrite )
    clear ( 's_pathIdent' );      
    
    %%    
    % everything for gender classification of chimpansees
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathGender            = fullfile(pwd, 'gender_classification');
    addPathSafely ( s_pathGender, b_recursive, b_overwrite )
    clear ( 's_pathGender' );  
    
    %%    
    % everything for age estimation of chimpansees
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathAgeReg            = fullfile(pwd, 'age_regression');
    addPathSafely ( s_pathAgeReg, b_recursive, b_overwrite )
    clear ( 's_pathAgeReg' );  
    
    %%    
    % everything for age group estimation
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathAgeGroupEst       = fullfile(pwd, 'age_group_classification');
    addPathSafely ( s_pathAgeGroupEst, b_recursive, b_overwrite )
    clear ( 's_pathAgeGroupEst' );      
    
    %%    
    % everything for face detection
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathFaceDetect        = fullfile(pwd, 'face_detection');
    addPathSafely ( s_pathFaceDetect, b_recursive, b_overwrite )
    clear ( 's_pathFaceDetect' );  
    
    %%    
    % everything for feature extraction
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathFeatExtract       = fullfile(pwd, 'feature_extraction');
    addPathSafely ( s_pathFeatExtract, b_recursive, b_overwrite )
    clear ( 's_pathFeatExtract' );    
    
    %%    
    % everything for the entire pipeline
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathPipeline          = fullfile(pwd, 'pipeline');
    addPathSafely ( s_pathPipeline, b_recursive, b_overwrite )
    clear ( 's_pathPipeline' );      
    
    %%    
    % everything for our nice demos
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathDemos             = fullfile(pwd, 'demos');
    addPathSafely ( s_pathDemos, b_recursive, b_overwrite )
    clear ( 's_pathDemos' );       

        
    
    %% 3rd party, untouched   
    
    if ( isempty(CAFFETOOLSDIR) )
        fprintf('initWSChimp-WARNING - no CAFFETOOLSDIR dir found on your machine. Code is available at git@dbv.inf-cv.uni-jena.de:matlab-tools/caffe_tools.git \n');
    else
        currentDir = pwd;
        cd ( CAFFETOOLSDIR );
        initWorkspaceCaffeTools;
        cd ( currentDir );      
    end
    
    if ( isempty(LIBLINEARDIR) )
        fprintf('initWSChimp-WARNING - no LIBLINEARDIR dir found on your machine. Code is available at https://www.csie.ntu.edu.tw/~cjlin/liblinear/ \n');
    else
        b_recursive             = true; 
        b_overwrite             = true;
        addPathSafely ( LIBLINEARDIR, b_recursive, b_overwrite );        
    end  
    
    
    if ( isempty(LIBLINEARWRAPPERDIR) )
        fprintf('initWSChimp-WARNING - no LIBLINEARWRAPPERDIR dir found on your machine. Code is available at cvgj-gitlab \n');
    else
       currentDir = pwd;
       cd ( LIBLINEARWRAPPERDIR );
       initWorkspaceLibLinear;
       cd ( currentDir );       
    end     
    
    if ( isempty(GPMLDIR) )
        fprintf('initWSChimp-WARNING - no GPMLDIR dir found on your machine. Code is available at http://www.gaussianprocess.org/gpml/code/matlab/doc/ \n');
    else
        b_recursive             = true; 
        b_overwrite             = true;
        addPathSafely ( GPMLDIR, b_recursive, b_overwrite );     
    end      
    
    if ( isempty(DARKNETDIR) )
        fprintf('initWSChimp-WARNING - no DARKNETDIR dir found on your machine. Code is available at https://github.com/cvjena/darknet \n');
    else
        % check if darknet has already been compiled successfully
        if ( exist( sprintf( '%sdarknet', DARKNETDIR) ,'file') )
            global s_path_to_darknet;
            s_path_to_darknet = DARKNETDIR;        
            % NOTE
            % If we should every write a Matlab interface to Darknet,
            % then add the paths here accordingly
        else
            fprintf('initWSChimp-WARNING - Darknet not yet compiled! \n');
        end
    end    
    
    % datasets
    if ( isempty(CHIMPFACEDATASETDIR) )
        fprintf('initWSChimp-WARNING - no ChimpFaces dataset found. The dataset with loading functionality is available at git@github.com:cvjena/chimpanzee_faces.git \n');
    else
        % make loading functionality known to matlab
        currentDir = pwd;
        cd ( CHIMPFACEDATASETDIR );
        initWorkspaceChimpanzeeFacesDataset;
        cd ( currentDir );
    end     
          
    
    %% clean up    
    %
    % feature extraction
    clear( 'CAFFETOOLSDIR' );  
    % identification    
    clear( 'LIBLINEARDIR' ); 
    clear( 'LIBLINEARWRAPPERDIR' );
    % age regression
    clear( 'GPMLDIR' );
    % face detection
    clear( 'DARKNETDIR' );
    % datasets
    clear( 'CHIMPFACEDATASETDIR' );

        
end
