function [ idxTrain, idxTest, idxUnused ] = split_chimpansees_for_gender_classification (  dataset, i_numTrainPerGender, i_numMinPerGender, i_numTestPerGender, b_idxToUse )
%function [ idxTrain, idxTest, idxUnused ] = split_chimpansees_for_gender_classification (  dataset, i_numTrainPerGender, i_numMinPerGender, i_numTestPerGender, b_idxToUse )
%
% INPUT
%  dataset               -- struct with at least the following fields:
%     f_genders        -- nx1 vector, integer
%  i_numTrainPerGender -- 1x1 scalar, integer or float ( only in [0,1) ),
%                           a float value indicates the ratio used for
%                           training
%  i_numMinPerGender   -- 1x1 scalar, integer, number of absolute
%                          individuals which an age group must contain to be
%                          used for training and testing. Otherwise, the
%                          corresponding inviduals are placed in idxUnused
%  i_numTestPerGender  -- 1x1 scalar, integer, if empty, all non-training
%                           images are considered for testing
%  b_idxToUse            -- optional, boolean nx1 vector indicating which
%                           elements to use
%
% OUTPUT
%  idxTrain              -- (#classes *i_numTrainPerCategory) x 1 vector, int-indices
%  idxTest               -- (#classes *i_numTestPerCategory)  x 1 vector, int-indices
%  idxUnused             -- (i_k)  x 1 vector, int-indices, i_k is as large
%                           as there as individuals which belong to classes
%                           with less then i_numMinPerGender examples
% 

    if ( nargin < 5 )
        b_idxToUse = true ( size ( dataset.f_genders ) );
    end


    f_genders = unique(dataset.f_genders);
    i_nog       = length(f_genders); % number of age groups
    
    idxTrain   = [];
    idxTest    = [];     
    idxUnused  = [];    

    
    for idx=1:i_nog
        f_gender = f_genders(idx);
        
        b_idxOfGenderExamples = (dataset.f_genders ==  f_gender )    & ...      
                                   dataset.b_idxValid  &  ...
                                   b_idxToUse;               

        i_idxOfGenderExamples = find(  b_idxOfGenderExamples  );
        
         % security check
         if sum(b_idxOfGenderExamples) < (i_numMinPerGender )
             idxUnused = [idxUnused; i_idxOfGenderExamples];
             continue;
         end              
                      
        i_perm = randperm( length(i_idxOfGenderExamples) ); 
        
        if ( i_numTrainPerGender < 1)
        	i_numTrain = floor ( i_numTrainPerGender * length(i_idxOfGenderExamples) );
        else
            i_numTrain = i_numTrainPerGender;
        end        
        
        idxTrain = [ idxTrain; i_idxOfGenderExamples( i_perm (1:i_numTrain) )]; 
        
             
        if ( (nargin >= 2 ) && (~isempty(i_numTestPerGender) ) && (~isinf( i_numTestPerGender )) )
            idxTest( ...
                        ((idx-1)*i_numTestPerGender+1): ...
                        ((idx)*i_numTestPerGender)...
                   ) = ...  
                      i_idxOfGenderExamples( i_perm  ((i_numTrain+1):(i_numTrain + i_numTestPerGender) ) );             
        else
        idxTest = [ idxTest ; ...
                    i_idxOfGenderExamples( i_perm  ((i_numTrain+1):end ) );              ...
                  ];

        end           
             
    end
    
    idxTrain = idxTrain(idxTrain~=0);
    disp(sprintf('Num train ex: %d', length(idxTrain) ) )

end