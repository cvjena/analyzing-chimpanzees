function str_out = face_identifier_ground_truth ( image, str_boxes, str_settings )
% 
%  BRIEF:
% 
%  INPUT:
% 
%  OUTPUT:
%     str_out.s_ids = estimated names of the detected chimpansees in the image

     s_namesTmp  = getStringDataSingleImage ( s_fn, 'Identity' );


    %% assign output variables
    str_out = str_regions;        
    
end