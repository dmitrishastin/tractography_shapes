function [len, ssp] = get_tract_span(tck_file);

    mrtrix_T = read_mrtrix_tracks(tck_file); 
    nsl = length(mrtrix_T.data);
    ssp = zeros(nsl, 1);
    
    for i = 1:nsl
        d = [mrtrix_T.data{i}(1,:); mrtrix_T.data{i}(end,:)];
        ssp(i) = sqrt(sum(diff(d).^2, 2));
    end
    
    len = sum(ssp) / nsl;

end