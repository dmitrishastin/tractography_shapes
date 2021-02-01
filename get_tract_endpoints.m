function [out_file1, out_file2] = get_tract_endpoints(tck_file, temp_folder, dgn)

    %output shortcuts
    out_file1 = [temp_folder filesep 'endpts1.tck'];
    out_file2 = [temp_folder filesep 'endpts2.tck'];
    
    %read in the streamlines
    mrtrix_T = read_mrtrix_tracks(tck_file); 
    
    %check for empty files
    if ~mrtrix_T.count
        [out_file1, out_file2] = deal(NaN);
        return
    end    
    
    streamlines = mrtrix_T.data;
    nsl = length(streamlines);
    [endpts1, endpts2] = deal(zeros(nsl,3));
    
    %identify the endpoints
    for i = 1:nsl

        endpts1(i,:) = streamlines{i}(1,:);
        endpts2(i,:) = streamlines{i}(end,:);
        
    end
    
    %calculate the initial centroids
    c = [mean(endpts1, 1); mean(endpts2, 1)];
    all_points = [endpts1(:,1:3); endpts2(:,1:3)];
    attempts = 0;
    
    %loop through kmeans until hopefully successful - has always worked so
    %far but should ideally be rewritten properly
    while attempts < 100
        
        %perform kmeans
        idx = kmeans(all_points, 2, 'Start', c);
        
        %check if for any streamline both endpoints are in the same cluster
        smcl = idx(1:nsl) == idx(1+nsl:end);
        
        %exit the loop if not
        if ~all(smcl)
            break
        end
        
        %flip the membership of the start points whose end points are in
        %the same cluster
        idx(smcl) = -idx(smcl) + 3;
        
        %recalculate centroids
        c1 = all_points(idx == 1, :);
        c2 = all_points(idx == 2, :);
        c = [mean(c1, 1); mean(c2, 1)];
        
        %go again
        attempts = attempts + 1;
        
    end    
    
    if attempts >= 100 && dgn
        disp('kmeans may not have done the best job, check the results')
    end
    
    %divvy up
    endpts1 = all_points(idx == 1, :); 
    endpts2 = all_points(idx == 2, :);
    
    [end1, end2] = deal({});
    
    %a bit of a hack here - creates a 2-point streamline for each for
    %tckmap to work - ideally dependence on tckmap should be avoided
    for i = 1:size(endpts1, 1)
        end1{end+1} = [endpts1(i, :); endpts1(i, :) + 10E-7];
    end
    
    for i = 1:size(endpts2, 1)
        end2{end+1} = [endpts2(i, :); endpts2(i, :) + 10E-7];
    end
    
    %save the results
    a.data = end1; 
    a.count = length(end1);
    write_mrtrix_tracks(a, out_file1);        
    
    b.data = end2;   
    b.cound = length(end2);
    write_mrtrix_tracks(b, out_file2);
        
end