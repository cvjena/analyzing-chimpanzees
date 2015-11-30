function [ idxTrain, idxTest ] = split_chimpansees_for_identification (  dataset, i_numTrainPerClass, i_numTrainMinPerClass, i_numTestPerClass, b_idxToUse )
%function [ idxTrain, idxTest ] = split_chimpansees_for_identification (  dataset, i_numTrainPerClass, i_numTestPerClass, b_idxToUse )
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
%  b_idxToUse            -- optional, boolean nx1 vector indicating which
%                           elements to use
%
% OUTPUT
%  idxTrain              -- (#classes *i_numTrainPerCategory) x 1 vector, int-indices
%  idxTest               -- (#classes *i_numTestPerCategory)  x 1 vector, int-indices
% 

    if ( nargin < 5)
        b_idxToUse = true ( size ( dataset.f_labels ) );
    end
    f_labels = unique( dataset.f_labels(b_idxToUse) );
    i_noc    = length(f_labels);
    idxTrain = [];
    idxTest  = [];
  

    
    for idx=1:i_noc
        f_class = f_labels(idx);
        
        b_idxOfClassExamples = (dataset.f_labels ==  f_class )    & ...      
                                dataset.b_idxValid  &  ...
                                b_idxToUse;            

        i_idxOfClassExamples = find(  b_idxOfClassExamples  );
        
         % security check
         if sum(b_idxOfClassExamples) < (i_numTrainMinPerClass )
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
    
    
    idxTrain = idxTrain(idxTrain~=0);
    disp(sprintf('Num train ex: %d', length(idxTrain) ) )
    
    

end
