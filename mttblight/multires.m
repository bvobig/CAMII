function multires(filename)
% Computes MTTB analysis using various window lengths (from 1 to 6 s.) and
% displays all together
% multires(filename) computes the analysis for the file filename

figure, hold on
for wlen = 1:6
    y = mttb_light(filename,.1,wlen);
    plot(mean([y.t_start,y.t_end]'),y.dens1)
end