function bend_table = get_bends(data, threshold_angle_deg, scale_method)
%retrieves curve bend segments based on a slope-angle threshold

arguments
    data (:,1) double
    threshold_angle_deg (1,1) double {mustBePositive} = 1
    scale_method (1,1) string {mustBeMember(scale_method, ["zscore","mad","none"])} = "zscore"
end

%% normalize scale so the angle is comparable regardless of the feature's original units/magnitude
switch scale_method
    case "zscore"
        s = std(data, 'omitnan');
        if s == 0 || isnan(s)
            s = 1; % constant/degenerate series -> no scaling needed
        end
        data_scaled = (data - mean(data, 'omitnan')) / s;
    case "mad"
        m = mad(data, 1); % median absolute deviation
        if m == 0 || isnan(m)
            m = 1;
        end
        data_scaled = (data - median(data, 'omitnan')) / m;
    case "none"
        data_scaled = data;
end

%% calculate first derivation (assumes equidistant sampling, dx = 1)
slopes = [NaN; diff(data_scaled)];
n = height(slopes);
% segment angle in degrees: atand is defined everywhere (even at
% slope=0), unlike the division used in the factor approach
theta = atand(slopes);

%% gather all local extrema to omit when detecting bends
extrema_idx = sort([find(islocalmax(data, "FlatSelection", "all")); ...
    find(islocalmin(data, "FlatSelection", "all"))]);
is_extremum = false(n, 1);
is_extremum(extrema_idx) = true;

%% angle difference between consecutive segments
delta_theta = NaN(n, 1);
stepMask = ~is_extremum(1:n-1);
stepDelta = theta(2:n) - theta(1:n-1);
delta_theta([stepMask; false]) = stepDelta(stepMask);

%% extract relevant slopes
bend = abs(delta_theta) > threshold_angle_deg;
bend_idx = find(bend);

%% detect direction based on slope after idx value
direction = NaN(numel(bend_idx), 1);
validNext = (bend_idx + 1) <= n;
direction(validNext) = sign(slopes(bend_idx(validNext) + 1));

%% add segmentation type
bend_table = table(bend_idx, direction, 'VariableNames', {'idx', 'direction'});
bend_table.type(1:height(bend_table)) = "bend";
bend_table = bend_table(:, {'idx', 'type', 'direction'});
end