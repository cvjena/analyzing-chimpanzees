function [ idxTrain, idxTest ] = split_chimpansees_for_age_group_classification (  dataset, i_numTrainPerClass, i_numTestPerClass )
%function [ idxTrain, idxTest ] = split_chimpansees_for_age_group_classification (  dataset, i_numTrainPerClass, i_numTestPerClass )
%
% INPUT
%  dataset               -- struct with at least the following fields:
%     f_ages              -- nx1 vector, integer
%     s_images           -- nx1 cell array of strings
%  i_numTrainPerCategory -- 1x1 scalar, integer or float ( only in [0,1) ),
%                           a float value indicates the ratio used for
%                           training
%  i_numTestPerCategory  -- 1x1 scalar, integer, if empty, all non-training
%                           images are considered more testing
%
% OUTPUT
%  idxTrain              -- (#classes *i_numTrainPerCategory) x 1 vector, int-indices
%  idxTest               -- (#classes *i_numTestPerCategory)  x 1 vector, int-indices
% 

    b_age_groups = unique(dataset.b_age_groups);
    
    idxTrain   = [];
    idxTest    = [];     

    
    for idx=0:1
        b_class = idx;
        
        b_idxOfClassExamples = (dataset.b_age_groups ==  b_class )    & ...      
                                dataset.b_idxValid ;            

        i_idxOfClassExamples = find(  b_idxOfClassExamples  );
        
        % security check
        if sum(b_idxOfClassExamples) < (i_numTrainPerClass )
            continue;
        end                               
                               
        i_perm = randperm( length(i_idxOfClassExamples) ); 
        
        if ( i_numTrainPerClass < 1)
        	i_numTrain = floor ( i_numTrainPerClass * length(i_idxOfClassExamples) );
        else
            i_numTrain = i_numTrainPerClass;
        end        
        
        idxTrain = [ idxTrain; i_idxOfClassExamples( i_perm (1:i_numTrain) )]; 
        
             
        if ( (nargin >= 2 ) && (~isempty(i_numTestPerClass) ) && (~isinf( i_numTestPerClass )) )
            idxTest( ...
                        ((idx-1)*i_numTestPerClass+1): ...
                        ((idx)*i_numTestPerClass)...
                   ) = ...  
                      i_idxOfClassExamples( i_perm  ((i_numTrain+1):(i_numTrain + i_numTestPerClass) ) );             
        else
        idxTest = [ idxTest ; ...
                    i_idxOfClassExamples( i_perm  ((i_numTrain+1):end ) );              ...
                  ];

        end           
             
    end
    

end