function results = chimpansee_age_group_glassification( dataset_chimpansees, settings )

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
        i_numTrainPerAge    = getFieldWithDefault ( settingsData, 'i_numTrainPerClass', 0.9 );
        i_numTestPerAge     = getFieldWithDefault ( settingsData, 'i_numTestPerClass', '' );

        % TODO show histogram of class frequencies...
        [ idxTrain, idxTest ] = split_chimpansees_for_age_group_classification (  ...
                dataset_chimpansees, ...
                i_numTrainPerAge, ...
                i_numTestPerAge ...
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
    
    dataTrain   = featCNN( :,idxTrain );
    labelsTrain = dataset_chimpansees.b_age_groups( idxTrain )';
    
    dataTest   = featCNN( :,idxTest );
    labelsTest = dataset_chimpansees.b_age_groups( idxTest )';
    
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
            scoresC(idxParam) = liblinear_train ( (2*labelsTrain-1)', sparse(double(dataTrain')), settingsLibLinear );
            progressbar ( idxParam/double(length(f_paramC)) );
        end
        progressbar ( 1 );
        
        [~,idxBestC] = max ( scoresC );
        settingsLibLinear.f_svm_C     =  f_paramC(idxBestC);        
    else
        settingsLibLinear.f_svm_C     =  1;        
    end
    
    % run train method
    % TODO do some kind of cross validation
    svmmodel = liblinear_train ( (2*labelsTrain-1)', sparse(double(dataTrain')), settingsLibLinear );
    
    % run train method
    % now really ensure model training!
    settingsLibLinear.b_cross_val = false;
    svmmodel = liblinear_train ( (2*labelsTrain-1)', sparse(double(dataTrain')), settingsLibLinear );
      
    
    %% apply model to test data
    
   [~, ~, scores] =liblinear_test ( (2*labelsTest-1)',  sparse(double(dataTest')), svmmodel, settingsLibLinear );
   
   [tp fp] = roc((~labelsTest), scores');
   f_auc   = auroc(tp',fp');
  
    if ( b_verbose ) 
        disp ( sprintf('score (AuROC): %f',f_auc) )
    end   
    
    results                 = [];
    results.f_auc           = f_auc;        
    %
    mydatasetsplit.idxTrain = idxTrain;
    mydatasetsplit.idxTest  = idxTest;    
    results.datasplits      = mydatasetsplit;    
    %
    results.age_group_est   = scores;    
    results.labelsTest      = labelsTest;    
    results.labelsTrain     = labelsTrain;    
   
    
%     %% visualize results
%     figure;
%     scatter ( ~labelsTest, scores' );
    
end


