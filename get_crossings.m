function crossings_table = get_crossings(time, data_c, data_t)
% get_crossings finds the time/value points where the client and
% therapist curves (data_c, data_t) intersect, via InterX, and returns
% them as a table with idx-free time/value columns plus NaN direction
% and "crossing" type columns to match the get_extrema/get_bends output
% format for concatenation.

crossings = InterX([time'; data_c'], [time'; data_t']);
crossTime = crossings(1, :)';
crossValue = crossings(2, :)';
crossings_table = table(crossTime, crossValue, VariableNames=["time" "value"]);
crossings_table.direction(1:height(crossings_table)) = NaN;
crossings_table.type(1:height(crossings_table)) = "crossing";

end