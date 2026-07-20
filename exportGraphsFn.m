function exportGraphsFn (data, segments, s, clno, expformat, outdir)

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

    extrema_c_idx = segments.(feat).C.idx(segments.(feat).C.type == "min" | segments.(feat).C.type == "max" | segments.(feat).C.type == "begin" | segments.(feat).C.type == "end");
    extrema_c_time = time(extrema_c_idx);
    extrema_c_values = csmoothed(extrema_c_idx);
    bend_c_idx = segments.(feat).C.idx(segments.(feat).C.type =="bend");
    bend_c_time = time(bend_c_idx);
    bend_c_values = csmoothed(bend_c_idx);

    therapist=data.impro.(featt);
    tsmoothed=data.smoothed.(featt);
    
    extrema_t_idx = segments.(feat).T.idx(segments.(feat).T.type == "min" | segments.(feat).T.type == "max" | segments.(feat).T.type == "begin" | segments.(feat).T.type == "end");
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

    rawfig = figure(Visible = "off"); 
    rawfig_ax = axes(rawfig); 

    plot (rawfig_ax, time, client, "g", DisplayName="Client", LineWidth=lw)
    hold (rawfig_ax, "on") 
    plot(time, therapist, "k", DisplayName="Therapist", LineWidth=lw)
    hold (rawfig_ax, "off")
    % xticks(ticks)
    ylim([downlim uplim])
    
    legend (Location="northeast")
    title("Original Data")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    set (rawfig, 'position', [10 10 lengthplot heightplot], Color="w")
    set (rawfig_ax, fontname="Times New Roman")
    
        exportgraphics(rawfig, fullfile(outdir, clno + "_graph_" + feat + "_raw." + expformat), Resolution=600)
        close(rawfig)

% Plot Smoothed Data

    smoothfig = figure(Visible = "off"); 
    smoothfig_ax = axes(smoothfig); 

    plot (smoothfig_ax, time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    hold (smoothfig_ax, "on")
    plot(smoothfig_ax, time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    hold (smoothfig_ax, "off")
    
    ylim([downlim uplim])
    legend (Location="northeast")
    title("Smoothed Data")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    set (smoothfig, 'position', [10 10 lengthplot heightplot], Color="w")
    set (smoothfig_ax, fontname="Times New Roman")
    
        exportgraphics(smoothfig, fullfile(outdir, clno + "_graph_" + feat + "_smoothed." + expformat), Resolution=600)
        close(smoothfig)

% Plot Raw and Smoothed Data 
    
    rawsmoothfig = figure(Visible = "off");
    rawsmoothfig_ax = axes(rawsmoothfig); 

    plot(rawsmoothfig_ax, time, client, "g:", DisplayName="Client Raw", LineWidth=lw)
    hold(rawsmoothfig_ax, "on")
    plot(rawsmoothfig_ax, time, therapist, "k:", DisplayName="Therapist Raw", LineWidth=lw)
    plot(rawsmoothfig_ax, time, csmoothed, "g", LineWidth=lw*1.5, DisplayName="Client Smoothed")
    plot(rawsmoothfig_ax, time, tsmoothed, "k", LineWidth=lw*1.5, DisplayName="Therapist Smoothed")
    hold(rawsmoothfig_ax, "off")
    
    ylim([downlim uplim])
    
    legend (Location="northeast")
    title("Layered Data (Enhanced & Smoothed)")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    set (rawsmoothfig, 'position', [10 10 lengthplot heightplot], Color="w")
    set (rawsmoothfig_ax, fontname="Times New Roman")
    
        exportgraphics(rawsmoothfig, fullfile(outdir, clno + "_graph_" + feat + "_layered." + expformat), Resolution=600)
        close(rawsmoothfig)

%% Plot Single and Combined Segmentations

% Client Segmentation
    
    cseg = figure(Visible = "off"); 
    cseg_ax = axes(cseg);

    hold(cseg_ax, "on")
    plot(cseg_ax, time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(cseg_ax, extrema_c_time, extrema_c_values, "^g", MarkerSize=ms, DisplayName="Client Extrema") % add ^ for extrema
    plot(cseg_ax, bend_c_time, bend_c_values, "squareg", MarkerSize=ms, DisplayName="Client Bends") % add squares for bends
    hold(cseg_ax, "off")
    
    ylim([downlim uplim])
    
    title("Client Segmentation" + " (n = " + sum(nnz([extrema_c_idx; bend_c_idx])) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    legend (Location="northeast")
    set (cseg, 'position', [10 10 lengthplot heightplot], Color="w")
    set (cseg_ax, fontname="Times New Roman")
    
        exportgraphics(cseg, fullfile(outdir, clno + "_graph_" + feat + "_segmented_client." + expformat), Resolution=600)
        close(cseg)

% Therapist Segmentation

    tseg = figure(Visible = "off");
    tseg_ax = axes(tseg);

    hold(tseg_ax, "on")
    plot(tseg_ax, time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(tseg_ax, extrema_t_time, extrema_t_values, "^k", MarkerSize=ms, DisplayName="Therapist Extrema") % add ^ for extrema
    plot(tseg_ax, bend_t_time, bend_t_values, "squarek", MarkerSize=ms, DisplayName="Therapist Bends") % add squares for bends
    hold(tseg_ax, "off")
    
    % xticks(ticks)
    ylim([downlim uplim])
    
    title("Therapist Segmentation" + " (n = " + sum(nnz([extrema_t_idx; bend_t_idx])) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    
    legend (Location="northeast")
    set (tseg, 'position', [10 10 lengthplot heightplot], Color="w")
    set (tseg_ax, fontname="Times New Roman")
    
        exportgraphics(tseg, fullfile(outdir, clno + "_graph_" + feat + "_segmented_therapist." + expformat), Resolution=600)
        close(tseg)

% Combined (including crossings)

    combinedfig = figure(Visible = "off"); 
    combinedfig_ax = axes(combinedfig);

    hold(combinedfig_ax, "on") 
    plot(combinedfig_ax, time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(combinedfig_ax, extrema_c_time, extrema_c_values, "^g", MarkerSize=ms, DisplayName="Client Extrema") % add ^ for extrema
    plot(combinedfig_ax, bend_c_time, bend_c_values, "squareg", MarkerSize=ms, DisplayName="Client Bends") % add squares for bends

    plot(combinedfig_ax, time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(combinedfig_ax, extrema_t_time, extrema_t_values, "^k", MarkerSize=ms, DisplayName="Therapist Extrema") % add ^ for extrema
    plot(combinedfig_ax, bend_t_time, bend_t_values, "squarek", MarkerSize=ms, DisplayName="Therapist Bends") % add squares for bends
    
    plot(combinedfig_ax, crossings_times, crossings_values, "or", MarkerSize = ms, DisplayName = "Crossings")

    hold(combinedfig_ax, "off")
    
    ylim([downlim uplim])
    title("Client & Therapist Segmentation" + " (C = " + sum(nnz([extrema_c_idx; bend_c_idx])) + ", T = " + sum(nnz([extrema_t_idx; bend_t_idx])) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(feat)
    legend (Location="northeast")
    set (combinedfig, 'position', [10 10 lengthplot heightplot], Color="w")
    set (combinedfig_ax, fontname="Times New Roman")
    
        exportgraphics(combinedfig, fullfile(outdir, clno + "_graph_" + feat + "_segmented_both." + expformat), Resolution=600)
        close(combinedfig)

end

beep on; beep;

end