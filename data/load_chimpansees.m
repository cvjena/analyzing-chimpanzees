function dataset_chimpansees = load_chimpansees ( s_destData, settings )
% function dataset_chimpansees = load_chimpansees ( s_destData, settings )
% 
%  INPUT:
%  s_destData               - string, mandatory
%  settings                 - struct with optional boolean fields
%      .b_load_age          - default: true, requires s_destData/age_information.mat
%      .b_load_gender       - default: true, requires s_destData/gender_information.mat
%      .b_load_age_group    - default: true, requires s_destData/age_group_information.mat
%      .b_load_identity     - default: true, requires s_destData/identity_information.mat
%      .b_load_dataset_name - default: false, requires s_destData/sdataset_names_information.mat
%      .b_load_image_fns    - default: true, requires s_destData/filelist_face_images.txt
% 
% OUTPUT:
%     dataset_chimpansees   - struct with optional fields
%      .f_ages              - only if b_load_age, double vector     
%      .b_genders           - only if b_load_gender, boolean vector
%      .b_age_groups        - only if b_load_age_group, boolean vector    
%      .f_labels            - only if b_load_identity, double vector     
%      .s_dataset_names     - only if b_load_dataset_name, cell array of strings
%      .s_all_datasets      - only if b_load_dataset_name, cell array of strings
%      .s_images            - only if b_load_image_fns, cell array of strings
%      .b_idxValid          - boolean vector

    
    if ( nargin < 1 )
        settings = [];
    end
    
    %% load previously curated data
    
    b_load_age                 = getFieldWithDefault ( settings, 'b_load_age',          true );
    b_load_gender              = getFieldWithDefault ( settings, 'b_load_gender',       true );
    b_load_age_group           = getFieldWithDefault ( settings, 'b_load_age_group',    true );
    b_load_identity            = getFieldWithDefault ( settings, 'b_load_identity',     true );
    b_load_dataset_name        = getFieldWithDefault ( settings, 'b_load_dataset_name', false );    
    b_load_image_fns           = getFieldWithDefault ( settings, 'b_load_image_fns',    true );   
    
    if ( b_load_age )
        ageInfo                = load( sprintf( '%sage_information.mat', s_destData ) );
    end
    
    if ( b_load_gender )    
        genderInfo             = load( sprintf( '%sgender_information.mat', s_destData ) );    
    end

    if ( b_load_age_group )    
        ageGroupInfo           = load( sprintf( '%sage_group_information.mat', s_destData ) );    
    end
    
    if ( b_load_identity )    
        identity_information   = load( sprintf( '%sidentity_information.mat', s_destData ) );    
    end
    
    if ( b_load_dataset_name )    
        dataset_information    = load( sprintf( '%sdataset_names_information.mat', s_destData ) );   
    end
       
    if ( b_load_image_fns ) 
        % fileId value - open the file
        s_filelist = sprintf( '%sfilelist_face_images.txt', s_destData );
        fid = fopen( s_filelist );

        % reads data from open test file into cell array (%s -> read string)
        s_images = textscan(fid, '%s', 'Delimiter','\n');

        % get all images
        s_images = s_images{1};

        fclose ( fid );
    end
    
    %% sanity check
    b_validyChecks = {};

    if ( b_load_age )
        b_idxAgeValid      = ~isnan ( ageInfo.f_ages);
        b_validyChecks{end+1}     = b_idxAgeValid;
    end
        
    if ( b_load_gender )    
        b_idxGenderValid   = ~isnan ( genderInfo.b_genders );
        b_validyChecks{end+1}     = b_idxGenderValid;
    end
    
    if ( b_load_age_group )
        b_idxAgeGroupValid = ~isnan ( ageGroupInfo.b_age_groups );    
        b_validyChecks{end+1}     = b_idxAgeGroupValid;        
    end
    
    if ( b_load_identity )
        b_validyChecks{end+1}     = identity_information.b_is_id_reliable;
    end
    
    b_idxValid = [];
    for idxValCheck = 1:length(b_validyChecks)
        if ( isempty ( b_idxValid ) )
            b_idxValid = b_validyChecks{idxValCheck};
        else
            b_idxValid = b_idxValid & b_validyChecks{idxValCheck};
        end
    end

    
    %% set output
    dataset_chimpansees  = [];
    
    if ( b_load_age )
        dataset_chimpansees.f_ages           = ageInfo.f_ages;        
    end    

    if ( b_load_gender )
        dataset_chimpansees.b_genders        = genderInfo.b_genders;        
    end    
    
    if ( b_load_age_group )
        dataset_chimpansees.b_age_groups     = ageGroupInfo.b_age_groups;           
    end
    
    if ( b_load_identity )
        dataset_chimpansees.f_labels         = identity_information.f_labels;           
    end
    
    if ( b_load_dataset_name )
        dataset_chimpansees.s_dataset_names  = dataset_information.s_dataset_names;
        dataset_chimpansees.s_all_datasets   = dataset_information.s_all_datasets;        
    end    
    
    if ( b_load_image_fns )
        dataset_chimpansees.s_images         = s_images;
    end
     
    dataset_chimpansees.b_idxValid           = b_idxValid;  


end