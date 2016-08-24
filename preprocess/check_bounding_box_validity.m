function b_is_crop_valid = check_bounding_box_validity ( i_img_size, xleft, xright, ytop, ybottom)
% function b_is_crop_valid = check_bounding_box_validity ( i_img_size, xleft, xright, ytop, ybottom)
% 
%  BRIEF
%    Validity check for a given rectangle hypothesis wrt. to an image,
%    i.e., would imcrop result in a useful output?
%    
%  INPUT
%    i_img_size -- integer array, 1st dim -> height, 2nd dim -> width
%    xleft      -- integer scalar 
%    xright     -- integer scalar, assumed to be larger than xleft
%    ytop       -- integer scalar
%    ybottom     -- integer scalar, assumed to be larger than ytop
% 
%  OUTPUT
%    b_is_crop_valid -- scalar bool
% 

    b_is_crop_valid = true;
    
    if ( (xleft < 0) || ( ytop < 0 ) || ...
         (xright > i_img_size(2)) || (ybottom > i_img_size(1)) || ...
         ( (xright-xleft) < 1) || ( (ybottom-ytop) < 1)...
       )
         b_is_crop_valid = false;
    end
end