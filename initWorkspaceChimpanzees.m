function initWorkspaceChimpanzees
% function initWorkspaceChimpanzees
% 
% Author: Alexander Freytag
% 
% BRIEF:
%   Add local subfolders and 3rd party libraries to Matlabs work space.
%   Needs to be adapted to your system!
% 
% 
%   Exemplary call from external position:
%        CHIMPDIR   = '/place/to/this/repository/';
%        currentDir = pwd;
%        cd ( CHIMPDIR );
%        initWorkspaceChimpanzees;
%        cd ( currentDir );
% 



    %% setup paths of 3rd-party libraries in a user-specific manner

    LIBLINEARDIR        = [];
    LIBLINEARWRAPPERDIR = [];    
        
    if strcmp( getenv('USER'), 'freytag')     
        [~, s_hostname]       = system( 'hostname' );
        s_hostname            = s_hostname ( 1:(length(s_hostname)-1) ) ;    
        s_dest_liblinearbuild = sprintf( '%smatlab-%s', '/home/freytag/code/3rdParty/liblinear-1.93/', s_hostname );    
        LIBLINEARDIR          = s_dest_liblinearbuild;
        
        LIBLINEARWRAPPERDIR   =  '/home/freytag/code/matlab/classifiers/liblinearWrapper/';
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
    % load data, splits, etc.
    b_recursive             = true; 
    b_overwrite             = true;
    s_pathData              = fullfile(pwd, 'data');
    addPathSafely ( s_pathData, b_recursive, b_overwrite )
    clear ( 's_pathData' );       
    
    
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
    

        
    
    %% 3rd party, untouched   
    
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
      
    
    %% clean up    
    clear( 'LIBLINEARDIR' ); 
    
        
end
