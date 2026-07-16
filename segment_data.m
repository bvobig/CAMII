function segments = segment_data (data, bend_threshold)

names = string(fieldnames(data.smoothed));
varnames = names(3:end-3); %begin after Time measurement and end before Property entries

    for i = 1:height(varnames)

        var = varnames(i); %define variable name
    
    seg_data = data.smoothed.(var); %extract data for segmentation
        extrema = get_extrema(seg_data); %get extrema segments
        bends = get_bends(seg_data, bend_threshold); %get bend segments
    
    all_segments = sortrows([extrema; bends]); %gather results from bend and extrema segmentation
    
    segments.total.(var) = all_segments.idx; %assign to result struct
    segments.direction.(var) = all_segments.direction;
    segments.type.(var) = all_segments.type;

    end

end