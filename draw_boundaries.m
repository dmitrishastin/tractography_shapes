function [outvol] = draw_boundaries(vol, conn, bmode)

    %identifies boundary voxels based on connectivity with neighbours
    
    %% set up
    outvol = vol * 0;
    
    %shape the connectivity kernel
    switch conn
        case 6
            conn = conndef(3,'minimal');
        case 18
            conn = zeros(3, 3, 3);
            [conn(:, :, 1), conn(:, :, 3)]=  deal(conndef(2, 'minimal'));
            conn(:, :, 2) = ones(3);
        case 26
            conn = conndef(3, 'maximal');
        otherwise
            error('Boundary kernel type wrong')
    end
    
    %bmode (-1 or 1) decides if the inner or outer surface is sampled 
    %for -1, the outer voxels of the volume are sampled;
    %for 1, a voxel-thick layer around is added

    %% commence
    
    %go through all non-negative voxels    
    cds = vol2cds(vol);
    
    for cv = 1 : size(cds, 1)
       
        i = cds(cv, 1);
        j = cds(cv, 2);
        k = cds(cv, 3);
    
        %explore the whole structuring element
        for a=-1:1
        for b=-1:1
        for c=-1:1

            %take each non-negative element in connectivity array
            if conn(2+a, 2+b, 2+c)==1
                
                d = i+a; e = j+b; f = k+c;

                %make sure the borders of the volume are not exceeded
                if d >= 1 && d <= size(vol, 1)
                if e >= 1 && e <= size(vol, 2)
                if f >= 1 && f <= size(vol, 3)                         

                    if ~vol(d, e, f)
                        if bmode == 1
                            outvol(d, e, f) = 1;
                        elseif bmode == -1
                            outvol(i, j, k) = 1;
                        else 
                            error('wrong arguments')
                        end
                    end
                end
                end
                end
            end
        end
        end
        end
    end
end   