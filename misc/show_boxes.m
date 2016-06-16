function show_boxes( boxes, hAxes, str_settings )
% function show_boxes( boxes, hAxes, str_settings )
%  BRIEF
%    print boxes on a given axes (e.g., an image)
%
%  INPUT
%    boxes        -- 4 x numBoxes double array, given as xleft, ytop, width, height
%    hAxes        -- handle to previously created axes handle, optional, use gca instead
%    str_settings -- struct, optional, the following fields are supported
%         .c_color_box -- a matlab interpretable color, default 'red'
%         .i_linewidth -- int, default 5
% 
%  author: Alexander Freytag

    %%
    if ( nargin < 3 )
        str_settings = [] ;
    end
    
    if ( nargin < 2 )
        hAxes = gca;
    end
    
    c_color_box = getFieldWithDefault ( str_settings, 'c_color_box', 'red' );
    i_linewidth = getFieldWithDefault ( str_settings, 'i_linewidth', 5 );    

    %%
    if ( ~isempty(boxes) )
      i_num_boxes = size(boxes, 2);
      
      for i = 1:i_num_boxes
        x_left   = boxes(1,i);
        y_top    = boxes(2,i);
        width    = boxes(3,i);
        height   = boxes(4,i);       
        x_right  = x_left + width;
        y_bottom = y_top + height;
        
        if ( isempty ( hAxes ) )
            line([x_left x_left x_right x_right x_left]',...
                 [y_top y_bottom y_bottom y_top y_top]',...
                 'Color',     c_color_box,...
                 'Linewidth', i_linewidth  ...
                );            
        else
            line([x_left x_left x_right x_right x_left]',...
                 [y_top y_bottom y_bottom y_top y_top]',...
                 'Color',     c_color_box,...
                 'Linewidth', i_linewidth,  ...
                 'Parent', hAxes ...
                );
        end
      end
      
    end
    drawnow;
end