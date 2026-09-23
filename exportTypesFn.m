function exportTypesFn(data, types, typestotal, s, clno, expformat, outdir)
% Plot and export interaction-type figures per feature.

set(0, 'DefaultFigureColor', 'white');

time = data.impro.Time;
varnames = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
iatypenames = ["Dependent", "Approach", "Follower", "Partner", "Leader", "Resister", "Neutral"];
datanames = data.smoothed.Properties.VariableNames(3:end);
datanameidx = 1:2:25;
ct = ["c", "t"];
lengthplot = 2000;
heightplot = 800;
colorpalette = [1.0000    0.0000    0.0000;
                1.0000    1.0000    0.0000;
                1.0000    0.4118    0.1608;
                0.4667    0.6745    0.1882;
                0         0.4471    0.7412;
                0.4941    0.1843    0.5569;
                0.9020    0.9020    0.9020];

%% Initiate Loops for Plotting
% Feature Loop
for feat = s
    var = varnames(feat);

    %% Combined Figure

    combinedFig = figure(Visible="off", Position=[10 10 lengthplot heightplot+200]);
    tlo = tiledlayout(combinedFig, 2, 3, TileSpacing="compact");

    % Actor Loop
    for actoridx = 1:2
        actor = ct(actoridx);
        cdataname = datanames{datanameidx(feat)};   % extract Dataset names for indexing
        tdataname = datanames{datanameidx(feat)+1}; % extract Dataset names for indexing
        c = data.smoothed.(cdataname); % extract fitting data for c
        t = data.smoothed.(tdataname); % extract fitting data for t

        % Evolution plot (combined)
        axEvo = nexttile(tlo, [1 2]);
        hold(axEvo, "on")
        if actor == "c"
            plot(axEvo, time, c, "g-", DisplayName="Client");
            plot(axEvo, time, t, "k--", DisplayName="Therapist")
        elseif actor == "t"
            plot(axEvo, time, c, "g--", DisplayName="Client");
            plot(axEvo, time, t, "k-", DisplayName="Therapist")
        end
        hold(axEvo, "off")

        plotInteractionRegions(axEvo, actor, var, types, iatypenames, colorpalette, time);

        axEvo.FontName = "Times New Roman";
        switch actor
            case "c"
                title(axEvo, "Client", FontAngle="normal")
                ylabel(axEvo, var, FontAngle="normal")
            case "t"
                title(axEvo, "Therapist", FontAngle="normal")
                ylabel(axEvo, var, FontAngle="normal")
                xlabel(axEvo, "Time in Seconds (s)", FontAngle="normal")
        end
        legend(axEvo, Location="eastoutside", FontAngle="normal")

        % Distribution bar (combined)
        axBar = nexttile(tlo, [1 1]);
        statbar = bar(axBar, 1:7, typestotal.(actor).(var){1, :}, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
        axBar.FontName = "Times New Roman";
        ylabel(axBar, "Decimal Percentage", FontAngle="normal")
        ylim(axBar, [0 (max(typestotal.(actor).(var){1, :})+0.1)])
        xticks(axBar, 1:7)
        xlim(axBar, [0, 8])
        xticklabels(axBar, iatypenames)
        axBar.XAxis.FontSize = 10;
        xtips1 = statbar.XEndPoints;
        ytips1 = statbar.YEndPoints;
        labels1 = string(statbar.YData);
        text(axBar, xtips1, ytips1, labels1, HorizontalAlignment="center", VerticalAlignment="bottom")
        switch actor
            case "c"
                title(axBar, "Client", FontAngle="normal")
            case "t"
                title(axBar, "Therapist", FontAngle="normal")
        end
    end

    exportgraphics(tlo, fullfile(outdir, clno + "_iatypes_" + var + "_distribution." + expformat), Resolution=600)
    close(combinedFig)

    %% Visualise Difference between Client and Therapist
    typesdiff = typestotal.c.(var){1,:} - typestotal.t.(var){1,:}; % positive = client direction, negative = therapist direction

    diffFig = figure(Visible="off", Position=[10 10 lengthplot/3, heightplot/2]);
    ax = axes(diffFig);

    statbar = bar(ax, 1:7, typesdiff, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
    ax.FontName = "Times New Roman";
    ylabel(ax, "Difference in Decimal Percentage", FontAngle="normal")

    % symmetric limits so negative (therapist) bars stay visible
    ylimit = max(abs(typesdiff)) + 0.1;
    ylim(ax, [-ylimit, ylimit])
    xticks(ax, 1:7)
    xticklabels(ax, iatypenames)
    xlim(ax, [0, 8])

    % data labels above/below each bar, depending on sign
    xtips1 = statbar.XEndPoints;
    ytips1 = statbar.YEndPoints;
    labels1 = string(round(statbar.YData, 2));

    for i = 1:numel(typesdiff)
        if typesdiff(i) >= 0
            vAlign = "bottom";
        else
            vAlign = "top";
        end
        text(ax, xtips1(i), ytips1(i), labels1(i), ...
            HorizontalAlignment="center", VerticalAlignment=vAlign)
    end

    % "Therapist ... Client" direction label, outside the axes on the right
    yl = ylim(ax);
    text(ax, 8.2, yl(2)/2, "Client", Rotation=90, ...
        HorizontalAlignment="center", VerticalAlignment="middle", ...
        FontName="Times New Roman", Clipping="off")
    text(ax, 8.2, yl(1)/2, "Therapist", Rotation=90, ...
        HorizontalAlignment="center", VerticalAlignment="middle", ...
        FontName="Times New Roman", Clipping="off")

    exportgraphics(diffFig, fullfile(outdir, clno + "_iatypes_" + var + "_comparison." + expformat), Resolution=600)
    close(diffFig)

    %% Single Visualisations
    for actoridx = 1:2
        actor = ct(actoridx);

        % --- Evolution plot (single) ---
        evoFig = figure(Visible="off", Position=[10 10 lengthplot (heightplot/2)]);
        axEvoSingle = axes(evoFig);

        hold(axEvoSingle, "on")
        if actor == "c"
            plot(axEvoSingle, time, c, "g-", DisplayName="Client");
            plot(axEvoSingle, time, t, "k--", DisplayName="Therapist")
        elseif actor == "t"
            plot(axEvoSingle, time, c, "g--", DisplayName="Client");
            plot(axEvoSingle, time, t, "k-", DisplayName="Therapist")
        end
        hold(axEvoSingle, "off")

        plotInteractionRegions(axEvoSingle, actor, var, types, iatypenames, colorpalette, time);

        axEvoSingle.FontName = "Times New Roman";
        switch actor
            case "c"
                title(axEvoSingle, "Client", FontAngle="normal")
                ylabel(axEvoSingle, var, FontAngle="normal")
            case "t"
                title(axEvoSingle, "Therapist", FontAngle="normal")
                ylabel(axEvoSingle, var, FontAngle="normal")
                xlabel(axEvoSingle, "Time in Seconds (s)", FontAngle="normal")
        end
        legend(axEvoSingle, Location="eastoutside", FontAngle="normal")

        exportgraphics(evoFig, fullfile(outdir, clno + "_iatypes_" + var + "_" + actor + "_evolution." + expformat), Resolution=600)
        close(evoFig)

        % Distribution bar chart (single)
        distFig = figure(Visible="off", Position=[10 10 lengthplot/3, heightplot/2]);
        axDistSingle = axes(distFig);

        statbar = bar(axDistSingle, 1:7, typestotal.(actor).(var){1, :}, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
        axDistSingle.FontName = "Times New Roman";
        ylabel(axDistSingle, "Decimal Percentage", FontAngle="normal")
        ylim(axDistSingle, [0 (max(typestotal.(actor).(var){1, :})+0.1)])
        xticks(axDistSingle, 1:7)
        xlim(axDistSingle, [0, 8])
        xticklabels(axDistSingle, iatypenames)
        xtips1 = statbar.XEndPoints;
        ytips1 = statbar.YEndPoints;
        labels1 = string(statbar.YData);
        text(axDistSingle, xtips1, ytips1, labels1, HorizontalAlignment="center", VerticalAlignment="bottom")
        switch actor
            case "c"
                title(axDistSingle, "Client", FontAngle="normal")
            case "t"
                title(axDistSingle, "Therapist", FontAngle="normal")
        end

        exportgraphics(distFig, fullfile(outdir, clno + "_iatypes_" + var + "_" + actor + "_distribution." + expformat), Resolution=600)
        close(distFig)
    end
end
end

function plotInteractionRegions(ax, actor, var, types, iatypenames, colorpalette, time)
% Identify and colourise interaction-type regions in the given axes.
for iatypeidx = 1:width(iatypenames) % counter for visualisation of each interactiontype
    ident = types.(actor).(var) == iatypenames(iatypeidx); % identify regions of interactiontypes
    beginnings = strfind(ident', [0 1]); % find beginning sequences in the middle
    beginnings = beginnings + 1; % add 1 for exact point in time
    ends = strfind(ident', [1 0]); % find ending sequences in the middle
    if ident(1) == 1 % if first interaction is of analysed type (begins on type)
        beginnings = [1, beginnings];
    elseif ident(end) == 1 % if last interaction is of analysed type (ends on type)
        ends(end+1) = height(ident); % last entry is end of improvisation
    end
    iaindexes = [beginnings; ends]'; % concatenate beginnings and ends in right format
    iaindexes = sort(iaindexes); % sort indexes ascending
    if nnz(iaindexes) == 2 % if only 2 entries exist (result in different ordering)
        regiontimes = time(iaindexes)'; % extract times related with indexes and change dimension to horizontal
    else
        regiontimes = time(iaindexes); % extract times related with indexes and keep original dimensions
    end
    if ~isempty(regiontimes)
        for reg = 1:height(iaindexes)
            region = xregion(ax, regiontimes(reg, :), FaceColor=colorpalette(iatypeidx, :), FaceAlpha=0.1);
            if reg == 1
                region.DisplayName = iatypenames(iatypeidx);
            else
                region.HandleVisibility = "off";
            end
        end
    end
end
end