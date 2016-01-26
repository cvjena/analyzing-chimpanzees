function show_boxes( hAxes, boxes )
% function show_boxes( hAxes, boxes )
%  BRIEF
%    
%  boxes given as xleft, ytop, width, height in 4 x numBoxes array

    if ( ~isempty(boxes) )
      i_num_boxes = size(boxes, 2);
      
      for i = 1:i_num_boxes
        x_left   = boxes(1,i);
        y_top    = boxes(2,i);
        width    = boxes(3,i);
        height   = boxes(4,i);       
        x_right  = x_left + width;
        y_bottom = y_top + height;
        
        line([x_left x_left x_right x_right x_left]',...
             [y_top y_bottom y_bottom y_top y_top]',...
             'Color','r',...
             'Linewidth',5,  ...
             'Parent', hAxes ...
            );
      end
      
    end
    drawnow;
end
