function [len, nsl, sll] = get_tract_length(tck_file);

    mrtrix_T = read_mrtrix_tracks(tck_file);    
    nsl = length(mrtrix_T.data);
    sll = zeros(nsl, 1);
    
    for i = 1:nsl
        d = diff(mrtrix_T.data{i});
        sll(i) = sum(sqrt(sum(d.^2, 2)));
    end
    
    len = sum(sll) / nsl;

end