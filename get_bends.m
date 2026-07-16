function bend_table = get_bends(data, threshold_slope)

%retrieves curve bend segments based on manually defined threshold slope

% calculate first derivation
slopes = [NaN; diff(data)];

% gather all local extrema to omit when detecting slopes
extrema = sort([find(islocalmax(data, FlatSelection="all")); find(islocalmin(data, FlatSelection="all"))]);

% calculate change factors between slopes
slope_factor(height(slopes)) = NaN; %preallocation

for i = 1:height(slopes)-1 
    if i ~= extrema
        slope_factor(i) = slopes(i+1)/slopes(i); %calculate changing factor from next to current slope value
    end
end

% extract relevant slopes (threshold_slop = default is 3)

bend = abs(slope_factor) > threshold_slope | abs(slope_factor) < 1/threshold_slope & abs(slope_factor) > 0;
bend_idx = find(bend)';
%%
%detect direction
direction(height(bend_idx)) = NaN;

for b = 1:height(bend_idx) %identify direction based on slope after idx value
    if slopes(bend_idx(b)+1) < 0
        direction(b) = -1;
    elseif slopes(bend_idx(b)+1) > 0
        direction(b) = 1;
    end
end

bend_direction = direction';
%%
%add segmentation type
bend_table = table(bend_idx);
bend_table.bend_type(1:height(bend_table)) = "bend";
bend_table.bend_direction = bend_direction;

bend_table = renamevars(bend_table, ["bend_idx", "bend_type", "bend_direction"], ["idx", "type", "direction"]);
%%
end