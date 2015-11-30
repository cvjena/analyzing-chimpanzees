function addPathSafely ( s_path, b_recursive, b_overwrite )
    if ( ~isempty(strfind(path, [s_path , pathsep])) )
        if ( b_overwrite )
            if ( b_recursive )
                rmpath( genpath( s_path ) );
            else
                rmpath( s_path );
            end
        else
            fprintf('initWSChimp - %s already in your path but overwriting de-activated.\n', s_path);
            return;
        end
    end
    
    if ( b_recursive )
        addpath( genpath( s_path ) );
    else
        addpath( s_path );
    end
end