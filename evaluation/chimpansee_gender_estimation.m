function results = chimpansee_gender_estimation( dataset_chimpansees, settings )

    %% load settings
    if ( nargin < 2 ) 
        settings = [];
    end
    
    settingsData = getFieldWithDefault( settings, 'settingsData', [] );
    datasplits = getFieldWithDefault ( settings, 'datasplits', struct( 'idxTrain', {}, 'idxTest', {} ) );    
    results    = struct ( 's_name', {}, 'f_arr', {}, 'datasplits', datasplits);
    
    b_verbose  =  getFieldWithDefault ( settings, 'b_verbose', true );  
    
    %% load data
    
    if ( ~isempty(  datasplits ) )
        idxTrain = getFieldWithDefault( datasplits,   'idxTrain', [] );
        idxTest  = getFieldWithDefault( datasplits,   'idxTest', [] ); 
    else
        idxTrain = [];
        idxTest  = [];            
    end  
    
    if ( isempty ( idxTrain ) || isempty ( idxTest ) ) 
        i_numTrainPerGender     = getFieldWithDefault ( settingsData, 'i_numTrainPerGender', 0.9 );
        i_numTrainMinPerGender  = getFieldWithDefault ( settingsData, 'i_numTrainMinPerGender', 25 );        
        i_numTestPerGender      = getFieldWithDefault ( settingsData, 'i_numTestPerGender', '' );

        % TODO show histogram of class frequencies...
        [ idxTrain, idxTest ] = split_chimpansees_for_gender_classification (  ...
                dataset_chimpansees, ...
                i_numTrainPerGender, ...
                i_numTrainMinPerGender, ...
                i_numTestPerGender ...
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

    b_normalize_features_L2 = getFieldWithDefault ( settings, 'b_normalize_features_L2', false );
    if ( b_normalize_features_L2 )
        featCNN = featCNN/(diag(sqrt(diag(featCNN'*featCNN))));
    end
    
    dataTrain   = featCNN( :,idxTrain );
    labelsTrain = dataset_chimpansees.f_genders( idxTrain )';
    f_unique_gender = unique ( labelsTrain );    
    labelsTrain = 2*( labelsTrain == f_unique_gender(1) )-1;
    
    dataTest   = featCNN( :,idxTest );
    labelsTest = dataset_chimpansees.f_genders( idxTest )';
    labelsTest = 2*( labelsTest == f_unique_gender(1) )-1;
    
    %% train classification model
    
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
        settingsLibLinear.f_svm_C     =  1;        
    end
        
    % run train method
    % now really ensure model training!
    settingsLibLinear.b_cross_val = false;
    svmmodel = liblinear_train ( labelsTrain', sparse(double(dataTrain')), settingsLibLinear );
      
    
    %% apply model to test data
    % compute scores
    [predicted_gender, f_arr, scores] = liblinear_test ( labelsTest', sparse(double(dataTest')), svmmodel, settingsLibLinear );
    
    % compute auc evaluation
    [tp, fp] = roc(labelsTest==f_unique_gender(1), scores);
    f_auc    = auroc(tp,fp);
   
   
  
    if ( b_verbose ) 
        disp ( sprintf('arr: %f',f_arr) )
        disp ( sprintf('auc: %f',f_auc) )
    end   
    
    results                     = [];
    results.f_arr               = f_arr;        
    results.f_auc               = f_auc;    
    %
    mydatasetsplit.idxTrain     = idxTrain;
    mydatasetsplit.idxTest      = idxTest;    
    results.datasplits          = mydatasetsplit;    
    %
    results.predicted_gender = predicted_gender;    
    results.labelsTest          = labelsTest;    
    results.labelsTrain         = labelsTrain;
    
end


