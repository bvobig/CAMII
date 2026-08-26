function segments = segment_data (data, threshold_angle_deg)
% segment_data splits each feature/actor's smoothed time series into extrema, bend and crossing segments, gathered into a struct per feature (fields C/T/crossings)

feature_names = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"]';
actor_names = ["C", "T"]';
for i = 1:numel(feature_names) % feature loop
    feat = feature_names(i);
    for a = 1:2 % actor loop
        actor = actor_names(a);
        % single actor calculations
        var = strcat(feat, actor); % define variable name
        seg_data = data.smoothed.(var); % extract data for segmentation
        extrema = get_extrema(seg_data); % get extrema segments
        bends = get_bends(seg_data, threshold_angle_deg); % get bend segments
        all_segments = sortrows([extrema; bends]); % gather results from bend and extrema segmentation
        segments.(feat).(actor) = all_segments; % assign to result struct
    end
    segments.(feat).crossings = get_crossings(data.impro.Time, data.smoothed.(strcat(feat, "C")), data.smoothed.(strcat(feat, "T")));
end
end