function results = chimpansee_identification( dataset_chimpansees, settings )

    if ( nargin < 2 ) 
        settings = [];
    end
    
    settingsData = getFieldWithDefault( settings, 'settingsData', [] );
    datasplits = getFieldWithDefault ( settings, 'datasplits', struct( 'idxTrain', {}, 'idxTest', {} ) );    
    results    = struct ( 's_name', {}, 'f_arr', {}, 'datasplits', datasplits);
    
    b_verbose  =  getFieldWithDefault ( settings, 'b_verbose', true );
    
    %% load data split
    if ( ~isempty(  datasplits ) )
        idxTrain = getFieldWithDefault( datasplits,   'idxTrain', [] );
        idxTest  = getFieldWithDefault( datasplits,   'idxTest', [] ); 
    else
        idxTrain = [];
        idxTest  = [];            
    end    
    
    if ( isempty ( idxTrain ) || isempty ( idxTest ) ) 
        i_numTrainPerClass     = getFieldWithDefault ( settingsData, 'i_numTrainPerClass', 0.9 );
        i_numTrainMinPerClass  = getFieldWithDefault ( settingsData, 'i_numTrainMinPerClass', 25 );
        i_numTestPerClass      = getFieldWithDefault ( settingsData, 'i_numTestPerClass', '' );

        % TODO show histogram of class frequencies...
        [ idxTrain, idxTest ] = split_chimpansees_for_identification (  ...
                dataset_chimpansees, ...
                i_numTrainPerClass, ...
                i_numTrainMinPerClass, ...
                i_numTestPerClass ...
                );
        if ( getFieldWithDefault ( settingsData, 'b_data_reclassif', false ) )    
            idxTest = idxTrain;
        end
    end    
    
    %% prepare data
    if ( ~isfield ( settings, 's_destFeat' ) )
        error ( 's_destFeat not specified in settings!') 
    end
    featCNN = load ( settings.s_destFeat);
    if ( isfield ( featCNN, 'struct_feat' ) ) % compatibility with MatConvNet
        featCNN = cell2mat(featCNN.struct_feat);
    elseif ( isfield ( featCNN, 'feat' ) && isfield ( featCNN.feat, 'name' ) )   % compatibility with Caffe
        featCNN = featCNN.feat.(featCNN.feat.name);
    else
        error ( 'CNN features not readable!' )
    end

    dataTrain     = featCNN( :,idxTrain );
    labelsTrain   = dataset_chimpansees.f_labels( idxTrain )';

    dataTest      = featCNN( :,idxTest );
    labelsTest    = dataset_chimpansees.f_labels( idxTest )';

    % make labels consecutive if necessary
    f_uniqueLabels  = unique ( labelsTrain );
    if ( max ( f_uniqueLabels) ~= length (f_uniqueLabels) ) 
        if ( max(f_uniqueLabels) ~= length(f_uniqueLabels) )
            for runCl=1:length(f_uniqueLabels)
                b_idxLabel = (labelsTrain == f_uniqueLabels(runCl) );
                labelsTrain ( b_idxLabel ) = runCl;

                b_idxLabel = (labelsTest == f_uniqueLabels(runCl) );
                labelsTest ( b_idxLabel ) = runCl;
            end
        end
    end
     
    
    %% train classification model

    b_recursive = true;
    b_overwrite = true;

%     [~, s_hostname] = system( 'hostname' );
%     s_hostname = s_hostname ( 1:(length(s_hostname)-1) ) ;    
%     s_dest_liblinearbuild = sprintf( '%smatlab-%s', '/home/freytag/code/3rdParty/liblinear-1.93/', s_hostname );    
%     addPathSafely( s_dest_liblinearbuild, b_recursive, b_overwrite);   


%     % nice wrapper which allows using a settings-struct
%     addPathSafely( '/home/freytag/code/matlab/patchesAndStuff/discriminativePatches/misc/liblinearWrapper/', b_recursive, b_overwrite); 

    settingsLibLinear             =  getFieldWithDefault ( settings, 'settingsLibLinear', [] );
    settingsLibLinear.i_svmSolver =  getFieldWithDefault ( settingsLibLinear, 'i_svmSolver', 2 );
    settingsLibLinear.b_verbose   =  getFieldWithDefault ( settingsLibLinear, 'b_verbose', false );

    settingsLibLinear.b_cross_val = getFieldWithDefault ( settingsLibLinear, 'b_cross_val', true );
    
    if ( settingsLibLinear.b_cross_val )
    
        f_paramC = -5:1:5;
        f_paramC = (10*ones(size(f_paramC))).^(f_paramC);

        scoresC = zeros (size(f_paramC));

        progressbar ( 0 );
        for idxParam=1:length(f_paramC)
            settingsLibLinear.f_svm_C     =  f_paramC(idxParam);
            scoresC(idxParam) = liblinear_train ( labelsTrain', sparse(double(dataTrain')), settingsLibLinear );
            progressbar ( idxParam/double(length(f_paramC)) );
        end
        progressbar ( 1 );
        
        [~,idxBestC] = max ( scoresC );
        settingsLibLinear.f_svm_C     =  f_paramC(idxBestC);        
    else
        settingsLibLinear.f_svm_C     =  10000;        
    end
    
    % run train method
    % now really ensure model training!
    settingsLibLinear.b_cross_val = false;
    svmmodel = liblinear_train ( labelsTrain', sparse(double(dataTrain')), settingsLibLinear );
    
    
    

    
        
    %% apply classification model to test data

    [predicted_label, f_arr, scores] = liblinear_test ( labelsTest', sparse(double(dataTest')), svmmodel, settingsLibLinear );

    if ( b_verbose )
        disp(sprintf('f_arr: %f', f_arr))
    end 
    

    results                 = [];
    results.f_arr           = f_arr;        
    %
    mydatasetsplit.idxTrain = idxTrain;
    mydatasetsplit.idxTest  = idxTest;    
    results.datasplits      = mydatasetsplit;    
    %
    results.predicted_label = predicted_label;    
    results.labelsTest      = labelsTest;    
    results.labelsTrain     = labelsTrain;        
    
    
  

    
end
