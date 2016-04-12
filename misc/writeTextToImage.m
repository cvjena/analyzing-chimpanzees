function writeTextToImage ( s_text, f_position, str_settings )
%function writeTextToImage ( s_text, f_position, str_settings )
% FIXME more settings!

    if ( nargin < 3 )
        str_settings = [] ;
    end


    c_color_text = getFieldWithDefault ( str_settings, 'c_color_text', 'red' );
    c_color_bg   = getFieldWithDefault ( str_settings, 'c_color_bg', 'none' );
    i_fontsize   = getFieldWithDefault ( str_settings, 'i_fontsize', 12 );
    

    text('units','normalized',...
         'position',f_position,...
         'fontsize',i_fontsize, ...
         'Color', c_color_text, ...
         'string',s_text, ...
         'BackgroundColor', c_color_bg ...
        )

end