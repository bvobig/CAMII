function exportGraphsFn (data, segments, s, clno, expformat, outdir)

expformat1=strcat("-",expformat);
feat_names=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

%% Prepare Data for Plotting and Define Plotting Variables
% rename time
time=data.impro.Time;

% set information for plotting
lengthplot = 1500;
heightplot = 300;
% LineWidth
lw = 0.5;
% MarkerSize
ms = 5;

for t = s

%% Feature Selector
feat = feat_names(t);
featc = strcat(feat, "C");
featt = strcat(feat, "T");

% insert fitting data for selection
    client = data.impro.(featc);
    csmoothed = data.smoothed.(featc);

    extrema_c_idx = segments.(feat).C.idx(segments.(feat).C.type == "min" | segments.(feat).C.type == "max");
    extrema_c_time = time(extrema_c_idx);
    extrema_c_values = csmoothed(extrema_c_idx);
    bend_c_idx = segments.(feat).C.idx(segments.(feat).C.type =="bend");
    bend_c_time = time(bend_c_idx);
    bend_c_values = csmoothed(bend_c_idx);

    therapist=data.impro.(featt);
    tsmoothed=data.smoothed.(featt);
    
    extrema_t_idx = segments.(feat).T.idx(segments.(feat).T.type == "min" | segments.(feat).T.type == "max");
    extrema_t_time = time(extrema_t_idx);
    extrema_t_values = tsmoothed(extrema_t_idx);
    bend_t_idx = segments.(feat).T.idx(segments.(feat).T.type =="bend");
    bend_t_time = time(bend_t_idx);
    bend_t_values = tsmoothed(bend_t_idx);

    crossings_times = segments.(feat).crossings.time;
    crossings_values = segments.(feat).crossings.value;

% calculate lims
    uplim=max([client; therapist])*1.1;
    downlim=min([client; therapist])-(data.rangetotal.(feat)*0.1);

%% Plot Raw and Smoothed Data Data on each other

%Plot Raw Data

    figure(Visible = "off") 
    plot (time, client, "g", DisplayName="Client", LineWidth=lw)
    hold on
    plot(time, therapist, "k", DisplayName="Therapist", LineWidth=lw)
    hold off
    % xticks(ticks)
    ylim([downlim uplim])
    
    legend (Location="northeast")
    title("Original Data")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig(fullfile(outdir, clno + "_graph_" + feat + "_raw"), expformat1, "-r600");

% Plot Smoothed Data

    figure(Visible = "off") 
    plot (time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    hold on 
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    hold off
    
    ylim([downlim uplim])
    legend (Location="northeast")
    title("Smoothed Data")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig(fullfile(outdir, clno + "_graph_" + feat + "_smoothed"), expformat1, "-r600");

% Plot Raw and Smoothed Data 
    
    figure(Visible = "off") 
    plot(time, client, "g:", DisplayName="Client Raw", LineWidth=lw)
    hold on 
    plot(time, therapist, "k:", DisplayName="Therapist Raw", LineWidth=lw)
    plot(time, csmoothed, "g", LineWidth=lw*1.5, DisplayName="Client Smoothed")
    plot(time, tsmoothed, "k", LineWidth=lw*1.5, DisplayName="Therapist Smoothed")
    hold off
    
    ylim([downlim uplim])
    
    legend (Location="northeast")
    title("Layered Data (Enhanced & Smoothed)")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig(fullfile(outdir, clno + "_graph_" + feat + "_layered"), expformat1, "-r600");

%% Plot Single and Combined Segmentations

% Client Segmentation
    
    figure(Visible = "off") 
    hold on 
    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(extrema_c_time, extrema_c_values, "^g", MarkerSize=ms, DisplayName="Client Extrema") % add ^ for extrema
    plot(bend_c_time, bend_c_values, "squareg", MarkerSize=ms, DisplayName="Client Bends") % add squares for bends
    hold off
    
    ylim([downlim uplim])
    
    title("Client Segmentation" + " (n = " + sum(nnz([extrema_c_idx; bend_c_idx])) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    legend (Location="northeast")
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig(fullfile(outdir, clno + "_graph_" + feat + "_bv_client"), expformat1, "-r600");

% Therapist Segmentation

    figure(Visible = "off")
    hold on 
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(extrema_t_time, extrema_t_values, "^k", MarkerSize=ms, DisplayName="Therapist Extrema") % add ^ for extrema
    plot(bend_t_time, bend_t_values, "squarek", MarkerSize=ms, DisplayName="Therapist Bends") % add squares for bends
    hold off
    
    % xticks(ticks)
    ylim([downlim uplim])
    
    title("Therapist Segmentation" + " (n = " + sum(nnz([extrema_t_idx; bend_t_idx])) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    legend (Location="northeast")
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig(fullfile(outdir, clno + "_graph_" + feat + "_bv_therapist"), expformat1, "-r600");

% Combined (including crossings)

    figure(Visible = "off") 
    hold on 
    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(extrema_c_time, extrema_c_values, "^g", MarkerSize=ms, DisplayName="Client Extrema") % add ^ for extrema
    plot(bend_c_time, bend_c_values, "squareg", MarkerSize=ms, DisplayName="Client Bends") % add squares for bends

    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(extrema_t_time, extrema_t_values, "^k", MarkerSize=ms, DisplayName="Therapist Extrema") % add ^ for extrema
    plot(bend_t_time, bend_t_values, "squarek", MarkerSize=ms, DisplayName="Therapist Bends") % add squares for bends
    
    plot(crossings_times, crossings_values, "or", MarkerSize = ms, DisplayName = "Crossings")

    hold off
    
    ylim([downlim uplim])
    title("Client & Therapist Segmentation" + " (C = " + sum(nnz([extrema_c_idx; bend_c_idx])) + ", T = " + sum(nnz([extrema_t_idx; bend_t_idx])) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    legend (Location="northeast")
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig(fullfile(outdir, clno + "_graph_" + feat + "_bv_both"), expformat1, "-r600");
   
% Combined Graphics

segmentation = figure (Position=[1 1 lengthplot heightplot/2*3], Visible = "off");
tile=tiledlayout(5, 2, TileSpacing="compact", Padding="compact");

nexttile ([2 1])

% Client

    hold on
    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(extrema_c_time, extrema_c_values, "^g", MarkerSize=ms, DisplayName="Client Extrema") % add ^ for extrema
    plot(bend_c_time, bend_c_values, "squareg", MarkerSize=ms, DisplayName="Client Bends") % add squares for bends
    title ("Client")
    ylabel(feat)
    fontname("Times New Roman")
    xlabel("Time in Seconds (s)")
    legend(Location="northeast")
    ylim([downlim uplim])
    hold off
    
    nexttile ([2 1])

% Therapist
 
    hold on
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(extrema_t_time, extrema_t_values, "^k", MarkerSize=ms, DisplayName="Therapist Extrema") % add ^ for extrema
    plot(bend_t_time, bend_t_values, "squarek", MarkerSize=ms, DisplayName="Therapist Bends") % add squares for bends
    title ("Therapist")
    ylabel(feat)
    xlabel("Time in Seconds (s)")
    legend(Location="northeast")
    fontname("Times New Roman")
    ylim([downlim uplim])
    hold off
    
    nexttile ([3 2]);

% Client and Therapist

    hold on

    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(extrema_c_time, extrema_c_values, "^g", MarkerSize=ms, DisplayName="Client Extrema") % add ^ for extrema
    plot(bend_c_time, bend_c_values, "squareg", MarkerSize=ms, DisplayName="Client Bends") % add squares for bends

    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(extrema_t_time, extrema_t_values, "^k", MarkerSize=ms, DisplayName="Therapist Extrema") % add ^ for extrema
    plot(bend_t_time, bend_t_values, "squarek", MarkerSize=ms, DisplayName="Therapist Bends") % add squares for bends

    plot(crossings_times, crossings_values, "or", MarkerSize = ms, DisplayName = "Crossings")

    legend(Location="northeast")
    title ("Client & Therapist")
    ylabel(feat)
    xlabel("Time in Seconds (s)")
    fontname("Times New Roman")
    ylim([downlim uplim])
    hold off
    
    title(tile, "Segmentation Process")
    
        exportgraphics(segmentation, fullfile(outdir, clno + "_graph_" + feat + "_bv_stacked.png"), Resolution=600)        

end

beep on; beep;

end