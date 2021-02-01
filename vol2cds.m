function cds = vol2cds(vol)

    %gives an X,Y,Z array of voxels in the volume vol with non-zero values
    posvox = find(logical(vol));
    cds = zeros(length(posvox),3);
    
    for i = 1: length(posvox)
        [cds(i, 1), cds(i, 2), cds(i, 3)] = ind2sub(size(vol), posvox(i));
    end

end