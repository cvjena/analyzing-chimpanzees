function writeTextToImage ( s_text, f_position )
%function writeTextToImage ( s_text, f_position )
% FIXME more settings!


    text('units','normalized',...
         'position',f_position,...
         'fontsize',12, ...
         'Color','red', ...
         'string',s_text...
        )

end