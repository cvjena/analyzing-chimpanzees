function str_out = age_regressor_GP ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.f_age = estimated age of the detected chimpansees in the image

    %% check inputs
    gpmodel          = getFieldWithDefault ( str_settings, 'gpmodel',    [] );
    settingsGP       = getFieldWithDefault ( str_settings, 'settingsGP', [] );
    dataTrain        = getFieldWithDefault ( str_settings, 'dataTrain',  [] );
    
    assert ( isfield ( gpmodel, 'alpha' ) ,        'age_regressor_GP -- no alpha in given model found');
    assert ( isfield ( settingsGP, 'covFunc' ) ,   'age_regressor_GP -- no covFunc in given model found');
    assert ( isfield ( settingsGP, 'loghyper' ) ,  'age_regressor_GP -- no loghyper in given model found');
    assert ( ~isempty ( 'dataTrain' ) , 'age_regressor_GP -- no dataTrain provided');    
    
    %% estimate age
    Ks      = feval( settingsGP.covFunc, settingsGP.loghyper.cov, dataTrain', str_extracted_features.features');
    age_est = Ks'*gpmodel.alpha;
   
    %% assign outputs
    str_out       = [];
    str_out.f_age = age_est;
    
end