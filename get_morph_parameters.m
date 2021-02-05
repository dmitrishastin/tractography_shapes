function log = get_morph_parameters(tck_file, vol_file, varargin)

% Extract morphological parameters for a tract
%
% Based on the interpretation of the following paper for 
% Brainhack 2020 Micro2Macro, please cite: 
%
% Shape analysis of the human association pathways.
% Yeh, Fang-Cheng. Neuroimage 223 (2020): 117329.
%
% tck_file:     shortcut to a mrtrix tractography file
% vol_file:     shortcut to a respective volume file (B0, FA, etc)
% 
% optional arguments (pass as 'name', 'value'):
% 
% vox_size:     voxel size in one dimension - volumetric measurements occur
%               on a voxel grid with voxels of that size. Default: 0.625 mm
% temp_folder:  directory to create a temporary folder in. Default: same as vol_file
% verbose:      show mrtrix logs - does not need a value. Default: off
%
% Uses MD-MRI scripts to read and write nifti files:
% https://github.com/markus-nilsson/md-dmri
% And a couple of helper functions from Dr Greg Parker (included).


    %% prepare
        
    inp = parsed_params(vol_file, varargin); log = {};
    
    %% get the masks
    
    %get the logical mask
    [tract_mask, vdims] = get_volume_mask(tck_file, vol_file, inp.vox_size, inp.temp_folder, inp.verbose);
    
    %get the endpoint masks
    [endpts1_file, endpts2_file] = get_tract_endpoints(tck_file, inp.temp_folder, inp.verbose);
    
    if isnan(endpts1_file)
        disp('an error has occurred')
        return
    end
        
    end1 = get_volume_mask(endpts1_file, vol_file, inp.vox_size, inp.temp_folder, inp.verbose, 1);
    end2 = get_volume_mask(endpts2_file, vol_file, inp.vox_size, inp.temp_folder, inp.verbose, 1);
    
    %% produce parameters
    
    %length
    [len, nsl] = get_tract_length(tck_file);
    
    %span
    span = get_tract_span(tck_file);
    
    %curl
    curl = len / span;
    
    %volume    
    vol = sum(tract_mask(:)) * inp.vox_size ^ 3;
    
    %diameter
    diam = 2 * sqrt(vol / (pi * len));
    
    %elongation
    elon = len / diam;
    
    %surface area
    surf = logical(draw_boundaries(tract_mask, 18, -1));
    surf_area = sum(surf(:)) * inp.vox_size ^ 2;
    
    %irregularity
    irreg_vol = surf_area / (pi * diam * len);
    
    %% deal with the two ends
    
    %get some auxilliary metrics and order the ends
    endcds{1} = vol2cds(end1);
    endcds{2} = vol2cds(end2);
    
    centroid{1} = mean(endcds{1},1);
    centroid{2} = mean(endcds{2},1);
    
    %find the dimension with the biggest value difference
    [~, C] = max(abs(diff([centroid{1}; centroid{2}])));
    
    %define the end with the greater value in that dimension as the first end
    if centroid{2}(C) > centroid{1}(C)
        temp = end2; end2 = end1; end1 = temp;
        endcds = flip(endcds);
        centroid = flip(centroid);
    end
    
    %end surface area
    esa(1) = sum(end1(:)) * inp.vox_size ^ 2;
    esa(2) = sum(end2(:)) * inp.vox_size ^ 2;
    
    %radius    
    [~, enddist{1}] = dsearchn(centroid{1}, endcds{1});
    [~, enddist{2}] = dsearchn(centroid{2}, endcds{2});
    
    rads(1) = 1.5 * mean(enddist{1}) * inp.vox_size;
    rads(2) = 1.5 * mean(enddist{2}) * inp.vox_size;
    
    %surface irregularity
    irreg_surf(1) = pi * rads(1) ^ 2 / esa(1);
    irreg_surf(2) = pi * rads(2) ^ 2 / esa(2);    
    
    %% reporting structure
    
    log =     { 'number of streamlines:'        nsl;
                'mean length(mm):'              len;
                'span(mm):'                     span;
                'diameter(mm):'                 diam;
                'radius of end area1(mm):'      rads(1);
                'radius of end area2(mm):'      rads(2);
                'surface area(mm^2):'           surf_area;
                'end area 1(mm^2):'             esa(1);
                'end area 2(mm^2):'             esa(2);
                'volume(mm^3):'                 vol;
                'curl:'                         curl;
                'elongation:'                   elon;
                'irregularity:'                 irreg_vol;
                'irregularity of end area1:'    irreg_surf(1);
                'irregularity of end area2:'    irreg_surf(2)};       
    
    %% clean up
    
    cd(inp.old_dir);
    system(['rm ' inp.temp_folder ' -R']);
    
end
