function crossings_table = get_crossings(time, data_c, data_t)
%%
crossings = InterX([time'; data_c'], [time'; data_t']);
time = crossings(1, :)';
value = crossings(2, :)';
crossings_table = table(time, value);
crossings_table.direction(1:height(crossings_table)) = NaN;
crossings_table.type(1:height(crossings_table)) = "crossing";
%%
end