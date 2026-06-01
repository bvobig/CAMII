function exportGraphsFn (data, segments, s, clno, expformat1, expformat2)

%% Prepare Data for Plotting and Define Plotting Variables
% rename time
time=data.impro.Time;

% Run crossing calculation
crossings=crossingcalc(data, 1);

% Run Segmentation
% segmentbv (data, raw/smoothed, no sens (0) /individual sens (1))
segmentsbv=segments;

% Variable Names for indexing
fieldname=fieldnames(segmentsbv.direction);
varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

% set information for plotting
lengthplot=1500;
heightplot=300;
% LineWidth
lw=0.5;
% MarkerSize
ms=3;

%% Feature Selector

for t=s

% insert fitting data for selection
    client=data.impro.(fieldname{t});
    csmoothed=data.smoothed.(fieldname{t});
    segsc=segmentsbv.total.(fieldname{t});
    segsctime=time(segmentsbv.total.(fieldname{t}));
    therapist=data.impro.(fieldname{t+1});
    tsmoothed=data.smoothed.(fieldname{t+1});
    segst=segmentsbv.total.(fieldname{t+1});
    segsttime=time(segmentsbv.total.(fieldname{t+1}));
    crosstimes=crossings.(varnames((t+1)/2))(1, :);
    crossvals=crossings.(varnames((t+1)/2))(2, :);

    z=(t+1)/2;
    var=varnames(z);

% calculate lims
    uplim=max([client; therapist])*1.1;
    downlim=min([client; therapist])-(data.rangetotal.(var)*0.1);

%% Plot Raw and Smoothed Data Data on each other

%Plot Raw Data

    figure(Visible="off") 
    plot (time, client, "g", DisplayName="Client", LineWidth=lw)
    hold on
    plot(time, therapist, "k", DisplayName="Therapist", LineWidth=lw)
    hold off
    % xticks(ticks)
    ylim([downlim uplim])
    
    legend (Location="northeast")
    title("Original Data")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_raw"), expformat1, "-r1000");

% Plot Smoothed Data

    figure(Visible="off") 
    plot (time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    hold on 
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    hold off
    
    ylim([downlim uplim])
    legend (Location="northeast")
    title("Smoothed Data")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_smoothed"), expformat1, "-r1000");

% Plot Raw and Smoothed Data 
    
    figure(Visible="off") 
    plot(time, client, "g:", DisplayName="Client", LineWidth=lw)
    hold on 
    plot(time, therapist, "k:", DisplayName="Therapist", LineWidth=lw)
    plot(time, csmoothed, "g", LineWidth=lw*1.5, DisplayName="Client Smoothed")
    plot(time, tsmoothed, "k", LineWidth=lw*1.5, DisplayName="Therapist Smoothed")
    hold off
    
    ylim([downlim uplim])
    
    legend (Location="northeast")
    title("Layered Data (Enhanced & Smoothed)")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_layered"), expformat1, "-r1000");

%% Plot Single and Combined Segmentations

% Client Smoothed
    
    figure(Visible="off") 
    hold on 
    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(segsctime, csmoothed(segsc), "squareg", MarkerSize=ms, DisplayName="Client Segments") % add squares for segments 
    hold off
    
    ylim([downlim uplim])
    
    title("Client (BV)" + " (C=" + nnz(segsc) + ", T=" + nnz(segst) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    
    legend (Location="northeast")
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_bv_client"), expformat1, "-r1000");

% Client Raw

    figure(Visible="off")
    hold on 
    plot(time, client, "g", LineWidth=lw, DisplayName = "Client Original")
    plot(segsctime, client(segsc), "squareg", MarkerSize=ms, DisplayName = "Client Segments")
    hold off

    ylim([downlim uplim])
    
    title("Client (BV)" + " (C=" + nnz(segsc) + ", T=" + nnz(segst) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    
    legend (Location="northeast")
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_bv_client_raw"), expformat1, "-r1000");

% Therapist

    figure(Visible="off")
    hold on 
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Client Smoothed")
    plot(segsttime, tsmoothed(segst), "squarek", MarkerSize=ms, DisplayName="Therapist Segments") % add squares for segments 
    hold off
    
    % xticks(ticks)
    ylim([downlim uplim])
    
    title("Therapist (BV)" + " (C=" + nnz(segsc) + ", T=" + nnz(segst) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    
    legend (Location="northeast")
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_bv_therapist"), expformat1, "-r1000");

% Combined

    figure(Visible="off") 
    hold on 
    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(segsctime, csmoothed(segsc), "squareg", MarkerSize=ms, DisplayName="Client Segments") % add squares for segments
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(segsttime, tsmoothed(segst), "squarek", MarkerSize=ms, DisplayName="Therapist Segments") % add squares for segments 
    hold off
    
    ylim([downlim uplim])
    title("Both (BV)" + " (C=" + nnz(segsc) + ", T=" + nnz(segst) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    legend (Location="northeast")
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_bv_both"), expformat1, "-r1000");

% Crossings

    figure(Visible="off")
    plot(time, client, "g:", DisplayName="Client")
    hold on 
    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(time, therapist, "k:", DisplayName="Therapist")
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(crosstimes, crossvals, "or", MarkerSize=ms, DisplayName="Crossings")
    hold off
    
    ylim([downlim uplim])
    title("Crossings (n=" + nnz(crosstimes) + ")")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    legend (Location="northeast")
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
        export_fig((clno + "_graph_" + varnames((t+1)/2) + "_crossings"), expformat1, "-r1000");

% Everything

    figure(Visible="off")
    hold on 
    plot(time, csmoothed, "g", LineWidth=lw, DisplayName="Client Smoothed")
    plot(time, tsmoothed, "k", LineWidth=lw, DisplayName="Therapist Smoothed")
    plot(crosstimes, crossvals, "or", MarkerSize=ms, DisplayName="Crossings")
    plot(segsctime, csmoothed(segsc), "squareg", MarkerSize=ms, DisplayName="Client Segments")
    plot(segsttime, tsmoothed(segst), "squarek", MarkerSize=ms, DisplayName="Therapist Segments")
    hold off
    
    ylim([downlim uplim])
    title("BV Segmentation, total")
    xlabel("Time in Seconds (s)")
    ylabel(varnames((t+1)/2))
    legend (Location="northeast")
    
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    set (gca, fontname="Times New Roman")
    
       export_fig((clno + "_graph_" + varnames((t+1)/2) + "_bv_total"), expformat1, "-r1000");
    
% Combined Graphics

figure (Position=[1 1 lengthplot heightplot/2*3], Visible="off")
tile=tiledlayout(5, 2, TileSpacing="compact", Padding="compact");

nexttile ([2 1])

% Client
 
    plot(time, csmoothed, "g", DisplayName="Client")
    hold on
    plot(segsctime, csmoothed(segsc), "squareg", MarkerSize=ms, DisplayName="Client Segments")
    title ("Client")
    ylabel(var)
    fontname("Times New Roman")
    xlabel("Time in Seconds (s)")
    legend(Location="northeast")
    ylim([downlim uplim])
    hold off
    
    nexttile ([2 1])

% Therapist
 
    plot(time, tsmoothed, "k", DisplayName="Therapist")
    hold on
    plot(segsttime, tsmoothed(segst),  "squarek", MarkerSize=ms, DisplayName="Therapist Segments")
    title ("Therapist")
    ylabel(var)
    xlabel("Time in Seconds (s)")
    legend(Location="northeast")
    fontname("Times New Roman")
    ylim([downlim uplim])
    hold off
    
    nexttile ([3 2]);

% Client and Therapist

    plot(time, csmoothed, "g", DisplayName="Client")
    hold on 
    plot(time, tsmoothed, "k", DisplayName="Therapist")
    plot(segsctime, csmoothed(segsc), "squareg", MarkerSize=ms, DisplayName="Client Segments")
    plot(segsttime, tsmoothed(segst),  "squarek", MarkerSize=ms, DisplayName="Therapist Segments")
    plot(crosstimes, crossvals, "or", MarkerSize=ms, DisplayName="Crossings")
    legend(Location="northeast")
    title ("Client & Therapist")
    ylabel(var)
    xlabel("Time in Seconds (s)")
    fontname("Times New Roman")
    ylim([downlim uplim])
    hold off
    
    title(tile, "Segmentation Process")
    
        print((clno + "_graph_" + varnames((t+1)/2) + "_bv_stacked"),expformat2, "-r1000")


end

beep on; beep;

end