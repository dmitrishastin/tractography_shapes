function [mask,vdims] = get_volume_mask(tck_file, vol_file, usvox, temp_folder, dgn, varargin)
    
    %figure out the flags to pass to mrtrix based on the context
    ep = '-precise ';
    if ~isempty(varargin)
        ep = '-ends_only ';
    end
    
    %convert for passing into mrtrix
    usvox = num2str(usvox);
    
    %shortcuts for later   
    mvol_file = [temp_folder filesep 'm_volume.nii.gz'];
    usvol_file = [temp_folder filesep 'US_volume.nii.gz'];
    
    %mask based on per-streamline contrast in a "white" volume
    %not sure if works better than simply getting a tdi map, doing just in case
    [nii, hdr] = mdm_nii_read(vol_file);
    nii(:) = 256;
    hdr.datatype = 2;
    hdr.bitpix = 8;
    mdm_nii_write(uint8(nii), mvol_file, hdr);   
    
    %upsample the volume    
    command = ['LD_LIBRARY_PATH= mrgrid ' mvol_file ' regrid -voxel ' usvox ' ' usvol_file];
    if dgn
        system(command);
    else
        evalc('system(command);');
    end
    
    %discretise streamlines using tckmap
    tdi_map = [temp_folder filesep 'TDI_map.nii.gz'];
    command = ['LD_LIBRARY_PATH= tckmap -template ' usvol_file ' -contrast scalar_map -image ' usvol_file ' -map_zero ' ep tck_file ' ' tdi_map ' -force'];
    if dgn
        system(command);
    else
        evalc('system(command);');
    end
    [nii, hdr] = mdm_nii_read(tdi_map);
    
    %prepare outputs    
    mask = logical(nii);    
    vdims = hdr.pixdim(2:4)';

end
