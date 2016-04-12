function results = chimpansee_age_regression( dataset_chimpansees, settings )

    %% load settings
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
        i_numTrainPerAge    = getFieldWithDefault ( settingsData, 'i_numTrainPerAge', 0.8 );
        i_numTestPerAge     = getFieldWithDefault ( settingsData, 'i_numTestPerAge', '' );
        i_numIntervals      = getFieldWithDefault ( settingsData, 'i_numIntervals', 5);

        % TODO show histogram of class frequencies...
        [ idxTrain, idxTest ] = split_chimpansees_for_regression (  ...
                dataset_chimpansees, ...
                i_numTrainPerAge, ...
                i_numTestPerAge, ...
                i_numIntervals ...
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
    labelsTrain = dataset_chimpansees.f_ages( idxTrain )';
    
    dataTest   = featCNN( :,idxTest );
    labelsTest = dataset_chimpansees.f_ages( idxTest )';
    
    %% train regression model
    
    gpnoise  = getFieldWithDefault ( settings, 'f_gpnoise', 0.1);
    
    infFct   = @infExact; 
    fp_gp_mean_function  = getFieldWithDefault ( settings, 'fp_gp_mean_function', @meanZero);
    covFunc  = getFieldWithDefault ( settings, 'fp_gp_cov_function', @covSEisoU); 
    likFct   = @likGauss;
    
    % default hyper parameters for gp functions
    loghyper.cov  = getFieldWithDefault ( settings, 'f_hyper_cov', 7);
    loghyper.lik  = gpnoise;
    loghyper.mean = getFieldWithDefault ( settings, 'f_hyper_mean', []); 
    %%
    if ( getFieldWithDefault ( settings, 'b_use_mean_age_as_mean', false ) )        
        % estimate mean age of entire population, that's the training phase
        ages_train = dataset_chimpansees.f_ages( idxTrain )';
        loghyper.mean = mean ( ages_train  );        
    end    
    b_do_optimization = true ;
    
    if ( b_do_optimization ) 
        %NOTE the gp implementation leads to useless results due to the
        %normalization by exp(2*noise) during computation of K and alpha.%
        % if we compute everything explicitely, the alpha vector contains
        % stronger variations, but results are significantly better!
        % hence, we perform our own optimization as seen below
        
%         % length  length of the run; if it is positive, it gives the maximum number of
%     %         line searches, if negative its absolute gives the maximum allowed
%     %         number of function evaluations. Optionally, length can have a second
%     %         component, which will indicate the reduction in function value to be
%     %         expected in the first line-search (defaults to 1.0).
%         i_length = -100;        
%         
%         % optimize hyper parameters based on the marginal likelihood
%         [loghyper, ~, ~]  = minimize(loghyper,@gp,i_length, infFct, meanFct, covFunc, likFct, dataTrain', labelsTrain');        

        f_paramNoise = -7:1:2;
        f_paramNoise = (2*ones(size(f_paramNoise))).^(f_paramNoise);
        f_paramBW    = 1:10;
        scoresParam  = zeros ( 1, length(f_paramBW) * length(f_paramNoise) );
        i_numFolds   = 5;
        fold_splits  = zeros(length(labelsTrain), i_numFolds);
        
        for iRun=1:i_numFolds
            fold_splits( :,iRun ) = randperm ( length(labelsTrain) );
        end

        progressbar ( 0 );
        for idxBW = 1:length(f_paramBW)
            loghyper.cov = f_paramBW(idxBW);
            for idxParam=1:length(f_paramNoise)
                loghyper.lik = f_paramNoise(idxParam);

                for iRun=1:i_numFolds
                    
                    b_use_one_of_n_for_cv = getFieldWithDefault ( settings, 'b_use_one_of_n_for_cv', true );
                    if ( ~b_use_one_of_n_for_cv ) 
                        % version 1) use n-1 / n for training and remaining for testing                    
                        idxTrainEnd   = floor( length(labelsTrain) - 1.0/i_numFolds*length(labelsTrain) );
                    else
                        % version 2) use only 1 / n for training and remaining for testing
                        idxTrainEnd  = floor( 1.0/i_numFolds*length(labelsTrain) );
                    end
                    idxTrainFold  = fold_splits(1:idxTrainEnd,iRun);
                    idxTestFold   = fold_splits( (idxTrainEnd+1):end,iRun);
                    K             = feval( covFunc, loghyper.cov, dataTrain(:,idxTrainFold)', dataTrain(:,idxTrainFold)');
                    model.L       = chol(K+gpnoise*eye(length(idxTrainFold)))';
                    % evaluate mean vector (eq. 2.38 in Rasmussen and Williams)
                    f_mean_values = feval(fp_gp_mean_function, loghyper.mean, dataTrain(:,idxTrainFold)'); 
                    model.alpha   = model.L'\(model.L\ (labelsTrain(idxTrainFold)' - f_mean_values ) );      

                    Ks      = feval( covFunc, loghyper.cov, dataTrain(:,idxTrainFold)', dataTrain(:,idxTestFold)');
                    age_est =  max ( 0, Ks'*model.alpha );

                    f_error = sum(power(abs(labelsTrain(idxTestFold)  - age_est'),1))/double(length(idxTestFold));
                     
                    scoresParam( (idxBW-1)*length(f_paramBW) + idxParam ) = scoresParam( (idxBW-1)*length(f_paramBW) + idxParam ) + f_error/i_numFolds;
                end
                progressbar ( ((idxBW-1)*length(f_paramBW) + idxParam) / (length(f_paramBW) * length(f_paramNoise)) );
            end
        end
        progressbar ( 1 );
        
        [~,idxMin] = min(scoresParam);
        [ idxNoise,idxBW ] = ind2sub( [length(f_paramNoise),length(f_paramBW)], idxMin );

        loghyper.cov = f_paramBW(idxBW);
        loghyper.lik = f_paramNoise(idxNoise);

        K           = feval( covFunc, loghyper.cov, dataTrain', dataTrain');
        model.L     = chol(K+exp(2*gpnoise)*eye(length(labelsTrain)))';   %chol ( K/sn2 + eye ); sn2 = exp(2*gpnoise);  model.L'\(model.L\labelsTrain/sn2') 
        % evaluate mean vector (eq. 2.38 in Rasmussen and Williams)
        f_mean_values = feval(fp_gp_mean_function, loghyper.mean, dataTrain');        
        model.alpha = model.L'\(model.L\ (labelsTrain' - f_mean_values ) );  

    else
        K           = feval( covFunc, loghyper.cov, dataTrain', dataTrain');
        model.L     = chol(K+gpnoise*eye(length(labelsTrain)))';
        % evaluate mean vector (eq. 2.38 in Rasmussen and Williams)
        f_mean_values = feval(fp_gp_mean_function, loghyper.mean, dataTrain(:,idxTrainFold)');        
        model.alpha = model.L'\(model.L\ (labelsTrain' - f_mean_values ) );        
    end

    

    
     %% apply regression model to test data
    
    Ks      = feval( covFunc, loghyper.cov, dataTrain', dataTest');
    f_mean  = feval( fp_gp_mean_function, loghyper.mean, dataTest');
    
    % eq. 2.38 in Rasmussen and Williams
    age_est = max ( 0, f_mean + Ks'*model.alpha);

    f_error = sum(power(abs(labelsTest  - age_est'),1))/double(length(labelsTest));
    
    if ( b_verbose ) 
        disp ( sprintf('Regression error L1: %f', f_error) )
    end
    
    
    results                 = [];
    results.scoresParam     = scoresParam;
    results.f_error         = f_error;        
    %
    mydatasetsplit.idxTrain = idxTrain;
    mydatasetsplit.idxTest  = idxTest;    
    results.datasplits      = mydatasetsplit;    
    %
    results.age_est         = age_est;    
    results.labelsTest      = labelsTest;    
    results.labelsTrain     = labelsTrain;
    
    
end
