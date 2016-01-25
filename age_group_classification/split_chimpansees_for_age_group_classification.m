function [ idxTrain, idxTest, idxUnused ] = split_chimpansees_for_age_group_classification (  dataset, i_numTrainPerAgeGroup, i_numMinPerAgeGroup, i_numTestPerAgeGroup, b_idxToUse )
%function [ idxTrain, idxTest, idxUnused ] = split_chimpansees_for_age_group_classification (  dataset, i_numTrainPerAgeGroup, i_numMinPerAgeGroup, i_numTestPerAgeGroup, b_idxToUse )
%
% INPUT
%  dataset               -- struct with at least the following fields:
%     f_age_groups        -- nx1 vector, integer
%  i_numTrainPerAgeGroup -- 1x1 scalar, integer or float ( only in [0,1) ),
%                           a float value indicates the ratio used for
%                           training
%  i_numMinPerAgeGroup   -- 1x1 scalar, integer, number of absolute
%                          individuals which an age group must contain to be
%                          used for training and testing. Otherwise, the
%                          corresponding inviduals are placed in idxUnused
%  i_numTestPerAgeGroup  -- 1x1 scalar, integer, if empty, all non-training
%                           images are considered for testing
%  b_idxToUse            -- optional, boolean nx1 vector indicating which
%                           elements to use
%
% OUTPUT
%  idxTrain              -- (#classes *i_numTrainPerCategory) x 1 vector, int-indices
%  idxTest               -- (#classes *i_numTestPerCategory)  x 1 vector, int-indices
%  idxUnused             -- (i_k)  x 1 vector, int-indices, i_k is as large
%                           as there as individuals which belong to classes
%                           with less then i_numMinPerAgeGroup examples
% 

    if ( nargin < 5 )
        b_idxToUse = true ( size ( dataset.f_labels_age_groups ) );
    end


    f_age_groups = unique(dataset.f_labels_age_groups);
    i_noag       = length(f_age_groups); % number of age groups
    
    idxTrain   = [];
    idxTest    = [];     
    idxUnused  = [];    

    
    for idx=1:i_noag
        f_age_group = f_age_groups(idx);
        
        b_idxOfAgeGroupExamples = (dataset.f_labels_age_groups ==  f_age_group )    & ...      
                                   dataset.b_idxValid  &  ...
                                   b_idxToUse;               

        i_idxOfAgeGroupExamples = find(  b_idxOfAgeGroupExamples  );
        
         % security check
         if sum(b_idxOfAgeGroupExamples) < (i_numMinPerAgeGroup )
             idxUnused = [idxUnused; i_idxOfAgeGroupExamples];
             continue;
         end              
                      
        i_perm = randperm( length(i_idxOfAgeGroupExamples) ); 
        
        if ( i_numTrainPerAgeGroup < 1)
        	i_numTrain = floor ( i_numTrainPerAgeGroup * length(i_idxOfAgeGroupExamples) );
        else
            i_numTrain = i_numTrainPerAgeGroup;
        end        
        
        idxTrain = [ idxTrain; i_idxOfAgeGroupExamples( i_perm (1:i_numTrain) )]; 
        
             
        if ( (nargin >= 2 ) && (~isempty(i_numTestPerAgeGroup) ) && (~isinf( i_numTestPerAgeGroup )) )
            idxTest( ...
                        ((idx-1)*i_numTestPerAgeGroup+1): ...
                        ((idx)*i_numTestPerAgeGroup)...
                   ) = ...  
                      i_idxOfAgeGroupExamples( i_perm  ((i_numTrain+1):(i_numTrain + i_numTestPerAgeGroup) ) );             
        else
        idxTest = [ idxTest ; ...
                    i_idxOfAgeGroupExamples( i_perm  ((i_numTrain+1):end ) );              ...
                  ];

        end           
             
    end
    
    idxTrain = idxTrain(idxTrain~=0);
    disp(sprintf('Num train ex: %d', length(idxTrain) ) )

end