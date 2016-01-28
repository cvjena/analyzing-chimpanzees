function str_out = age_regressor_GP ( str_extracted_features, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.f_age = estimated age of the detected chimpansees in the image

    %% check inputs
    gpmodel          = getFieldWithDefault ( str_settings, 'model', [] );
    
    assert ( isfield ( gpmodel, 'alpha' ) ,     'age_regressor_GP -- no alpha in given model found');
    assert ( isfield ( gpmodel, 'covFunc' ) ,   'age_regressor_GP -- no covFunc in given model found');
    assert ( isfield ( gpmodel, 'loghyper' ) ,  'age_regressor_GP -- no loghyper in given model found');
    assert ( isfield ( gpmodel, 'dataTrain' ) , 'age_regressor_GP -- no dataTrain in given model found');    
    
    %% estimate age
    Ks      = feval( gpmodel.covFunc, gpmodel.loghyper.cov, gpmodel.dataTrain', str_extracted_features');
    age_est = Ks'*gpmodel.alpha;
   
    %% assign outputs
    str_out       = [];
    str_out.f_age = age_est;
    
end