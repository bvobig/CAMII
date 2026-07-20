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

    combinedFig = figure(Visible="off", Position=[10 10 lengthplot heightplot]);
    tlo = tiledlayout(combinedFig, 2, 3, TileSpacing="tight");

    % Actor Loop
    for actoridx = 1:2
        actor = ct(actoridx);
        cdataname = datanames{datanameidx(feat)};   % extract Dataset names for indexing
        tdataname = datanames{datanameidx(feat)+1}; % extract Dataset names for indexing
        c = data.smoothed.(cdataname); % extract fitting data for c
        t = data.smoothed.(tdataname); % extract fitting data for t

        axEvo = nexttile(tlo, [1 2]);
        plotEvolution(axEvo, actor, time, c, t);
        plotInteractionRegions(axEvo, actor, var, types, iatypenames, colorpalette, time);
        styleEvolutionAxes(axEvo, actor, var);

        axBar = nexttile(tlo, [1 1]);
        plotDistributionBar(axBar, actor, var, typestotal, iatypenames, colorpalette);
    end

    exportgraphics(tlo, fullfile(outdir, clno + "_iatypes_" + var + "_distribution." + expformat), Resolution=600)
    close(combinedFig)

    %% Visualise Difference between Client and Therapist
    typesdiff = typestotal.c.(var){1,:} - typestotal.t.(var){1,:}; % positive values - client direction, negative values, therapist direction
    diffFig = figure(Visible="off");
    axDiff = axes(diffFig);
    bar(axDiff, 1:7, typesdiff, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
    xticklabels(axDiff, iatypenames)
    ylabel(axDiff, "Difference in Decimal Percentage")
    axis(axDiff, [0, 7, -1, 1])
    yyaxis(axDiff, "right")
    yticks(axDiff, [])
    set(axDiff, YColor="k")
    ylabel(axDiff, "Therapist                         Client", Color="k")
    yyaxis(axDiff, "left")
    title(axDiff, "Gradient Prevalence Comparison")
    axDiff.FontName = "Times New Roman";

    exportgraphics(diffFig, fullfile(outdir, clno + "_iatypes_" + var + "_comparison." + expformat), Resolution=600)
    close(diffFig)

    %% Single Visualisations
    for actoridx = 1:2
        actor = ct(actoridx);

        % Evolution plot
        evoFig = figure(Visible="off", Position=[10 10 lengthplot (heightplot/2)]);
        axEvoSingle = axes(evoFig);

        plotEvolution(axEvoSingle, actor, time, c, t);
        plotInteractionRegions(axEvoSingle, actor, var, types, iatypenames, colorpalette, time);
        styleEvolutionAxes(axEvoSingle, actor, var);

        exportgraphics(evoFig, fullfile(outdir, clno + "_iatypes_" + var + "_" + actor + "_evolution." + expformat), Resolution=600)
        close(evoFig)

        % Distribution bar chart
        distFig = figure(Visible="off");
        axDistSingle = axes(distFig);
        plotDistributionBar(axDistSingle, actor, var, typestotal, iatypenames, colorpalette);

        exportgraphics(distFig, fullfile(outdir, clno + "_iatypes_" + var + "_" + actor + "_distribution." + expformat), Resolution=600)
        close(distFig)
    end
end
end

function plotEvolution(ax, actor, time, c, t)
% Plot client/therapist evolution lines into the given axes handle.
hold(ax, "on")
if actor == "c"
    plot(ax, time, c, "g-", DisplayName="Client");  % plot smoothed data above each other
    plot(ax, time, t, "k--", DisplayName="Therapist")
elseif actor == "t"
    plot(ax, time, c, "g--", DisplayName="Client");
    plot(ax, time, t, "k-", DisplayName="Therapist")
end
hold(ax, "off")
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

function styleEvolutionAxes(ax, actor, var)
% Add fitting title/labels/legend to an evolution-plot axes.
ax.FontName = "Times New Roman";
switch actor
    case "c"
        title(ax, "Client", FontAngle="normal")
        ylabel(ax, var, FontAngle="normal")
    case "t"
        title(ax, "Therapist", FontAngle="normal")
        ylabel(ax, var, FontAngle="normal")
        xlabel(ax, "Time in Seconds (s)", FontAngle="normal")
end
legend(ax, Location="eastoutside", FontAngle="normal")
end

function statbar = plotDistributionBar(ax, actor, var, typestotal, iatypenames, colorpalette)
% Plot the whole-feature-percentage bar chart into the given axes.
statbar = bar(ax, 1:7, typestotal.(actor).(var){1, :}, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
ax.FontName = "Times New Roman";
ylabel(ax, "Decimal Percentage", FontAngle="normal")
ylim(ax, [0 (max(typestotal.(actor).(var){1, :})+0.1)])
xticklabels(ax, iatypenames)
xtips1 = statbar.XEndPoints;
ytips1 = statbar.YEndPoints;
labels1 = string(statbar.YData);
text(ax, xtips1, ytips1, labels1, HorizontalAlignment="center", VerticalAlignment="bottom")
switch actor
    case "c"
        title(ax, "Client", FontAngle="normal")
    case "t"
        title(ax, "Therapist", FontAngle="normal")
end
end