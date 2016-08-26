function str_names  = getNamesSingleImageNewDataLayout ( s_fn, str_settings )
% 
% BRIEF
%  specifically taylored to meta-information provided by chimpansee
%  dataset. 
%  Each image specified by s_fn is supposed to come with an
%  additional file, e.g.,  s_fn.ic
%
% INPUT
%  s_fn         -- char array 
%  str_settings -- struct with the following optional fields:
%        .s_ending ( default: '.xml')
% 
% OUTPUT
%   str_names -- struct, two fields
%     .i_labels     -- nx1 int-valued float array (the class labels), 
%     .s_classnames -- cell array with n entries, (the category names), 
%        n is the number of objects in the frame 

    
    
    %%
    str_names     = [];
    %%
    s_ending      = getFieldWithDefault ( str_settings, 's_ending', '.xml' );    

    s_fnMetaData  =  sprintf('%s%s', s_fn, s_ending );
    
    mystruct      = xml2struct ( s_fnMetaData );
    
    s_fieldnames  = fieldnames( mystruct );
    assert ( length( s_fieldnames) == 1 , 'getStringDataSingleImageNewDataLayout - meta-file provides more than 1 field!' );    

    if ( ~ isfield (mystruct.(s_fieldnames{1}).frames.frame.objects , 'object')  )
        
        fid = fopen( './issues.txt', 'a' );% a -- write with append
        fprintf(fid, '%s\n', s_fn );
        fclose (fid);
        
        str_names.i_labels     = [];
        str_names.s_classnames = [];
        return
    end
    
    i_numObjects      = length ( mystruct.(s_fieldnames{1}).frames.frame.objects.object );    
    i_numUniqueLabels = length ( mystruct.(s_fieldnames{1}).labels.label );
         

    %% differentiate number of objects ... if only one object, accessing data is directly as variable.field. otherwise variable{idx}.field
    %
    if ( i_numObjects == 1 )
        myobjects  = {mystruct.(s_fieldnames{1}).frames.frame.objects.object};
        mymappings = {mystruct.(s_fieldnames{1}).frames.frame.mappings.mapping};
    else
        myobjects  = mystruct.(s_fieldnames{1}).frames.frame.objects.object(:);  
        mymappings = mystruct.(s_fieldnames{1}).frames.frame.mappings.mapping(:);
    end
    if ( i_numUniqueLabels == 1 )
        mylabels   = {mystruct.(s_fieldnames{1}).labels.label};
    else
        mylabels   = mystruct.(s_fieldnames{1}).labels.label(:);
    end
    
    i_labels     = [];
    s_classnames = {};
    
    for idxObjectInXML=1:i_numObjects
        
        % % fetch the id of the object within that image
        %idObject = str2double(myobjects{idxObjectInXML}.Attributes.uid)+1;
        
        % check all mappings and fetch the correct entry to the mapping
        % note: the mappings could directly be used as class index
        for idxMappingInXML=1:i_numObjects
            if ( strcmp ( myobjects{idxObjectInXML}.Attributes.uid, mymappings{idxMappingInXML}.Attributes.object_ref ) )
                %i_mappings( idObject ) = str2double(mymappings{idxMappingInXML}.Attributes.label_ref);
                i_labels( idxObjectInXML )= str2double(mymappings{idxMappingInXML}.Attributes.label_ref);
                break;
            end
        end
        
        % now use the mapping to obtain the correct name (string) 
        
        for idxLabelInXML=1:i_numUniqueLabels
            %if ( strcmp ( i_mappings( idObject ),  mylabels{idxLabelInXML}.Attributes.uid ) )
            if ( i_labels( idxObjectInXML ) ==  str2double(mylabels{idxLabelInXML}.Attributes.uid) )
                 s_classnames{ idxObjectInXML } = mylabels{idxLabelInXML}.Attributes.name;
            end
        end
             
    end   
    
    %% assign outputs
    str_names.i_labels     = i_labels;
    str_names.s_classnames = s_classnames;

end