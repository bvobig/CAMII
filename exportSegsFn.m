function exportSegsFn(data, feats, s, clno, expformat, outdir)
% Plot and export segments based on chosen segmentation and feature calculation.

%% Prepare Data for Plotting and Define Plotting Variables
feat_names = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

for t = s
    feat = feat_names(t);
    featC = strcat(feat, "C");
    featT = strcat(feat, "T");

    % Define Segment
    for i = 1:height(feats.(feat))
        space = 50; % how many ms before and after for plotting

        % determine plot area
        if i == 1 % if first entry
            areabegin = (feats.(feat).idx(i));
            areaend = feats.(feat).idx(find(feats.(feat).type(i+1:end)~="crossing", 1, "first")+i); % find next "act" entry; adding i due to find function purposes
            areaidx = areabegin:(areaend+space);
        elseif i == height(feats.(feat)) % if last entry
            areabegin = feats.(feat).idx(find(feats.(feat).type(1:i-1)~="crossing", 1, "last")); % find last "act" entry
            areaend = height(data.smoothed.(featC));
            areaidx = (areabegin-space):(areaend+space);
        else % if neither
            switch feats.(feat).type(i)
                case "act"
                    areabegin = feats.(feat).idx(find(feats.(feat).type(1:i-1)~="crossing", 1, "last")); % find last "act" entry
                    areaend = feats.(feat).idx(find(feats.(feat).type(i+1:end)~="crossing", 1, "first")+i); % find next "act" entry; adding i due to find function purposes
                    areaidx = (areabegin-space):(areaend+space);
                case "crossing"
                    areabegin = feats.(feat).idx(find(feats.(feat).type(1:i-1)~="crossing", 1, "last")); % find last "act" entry
                    areaend = feats.(feat).idx(find(feats.(feat).type(i+1:end)~="crossing", 1, "first")+i); % find next "act" entry; adding i due to find function purposes
                    areaidx = (areabegin-space):(areaend+space);
            end
        end

        % shorten area if starts before 1 or ends beyond data range
        if areaidx(1) < 1
            areaidx = areaidx(areaidx>0);
        elseif areaidx(end) > height(data.smoothed)
            areaidx = areaidx(areaidx<=height(data.smoothed));
        end

        %% Extract matching Time and Curve Values
        time = data.smoothed.Time(areaidx); % extract time from beginning of area until end of area in .1s steps
        valuesc = data.smoothed.(featC)(areaidx); % extract client values from smoothed data from first to last area idx entry
        valuest = data.smoothed.(featT)(areaidx); % same for therapist

        % define length and height of plot
        lengthplot = length(areaidx);
        heightplot = 300;

        %% Plot Figure
        fig = figure(Position=[10 10 lengthplot heightplot], Visible="off");
        ax = axes(fig);
        hold(ax, "on")
        plot(ax, time, valuesc, "g", DisplayName="Client Smoothed")
        plot(ax, time, valuest, "k", DisplayName="Therapist Smoothed")
        uplim = max([data.smoothed.(featC); data.smoothed.(featT)])*1.1;
        downlim = min([data.smoothed.(featC); data.smoothed.(featT)])-(data.rangetotalsmoothed.(feat)*0.1);
        ylim(ax, [downlim uplim])
        yline(ax, min(data.smoothed.(featC)), "g:", HandleVisibility="off")
        yline(ax, max(data.smoothed.(featC)), "g:", DisplayName="Client Range")
        yline(ax, min(data.smoothed.(featT)), "k:", HandleVisibility="off")
        yline(ax, max(data.smoothed.(featT)), "k:", DisplayName="Therapist Range")
        xlabel(ax, "Time in Seconds (s)")
        ylabel(ax, feat)

        if ~ismissing(feats.(feat).actor(i))
            actor = feats.(feat).actor(i);
        elseif ismissing(feats.(feat).actor(i))
            actor = "crossing";
        end
        title(ax, feats.(feat).time(i) + "s " + actor)

        % add xline to indicate current actor
        if feats.(feat).actor(i) == "C"
            xline(ax, feats.(feat).time(i), "g", HandleVisibility="off")
        elseif feats.(feat).actor(i) == "T"
            xline(ax, feats.(feat).time(i), "k", HandleVisibility="off")
        elseif ismissing(feats.(feat).actor(i))
            xline(ax, feats.(feat).time(i), "b", HandleVisibility="off")
        end

        % determine segments to mark
        if i == 1
            edge = i:i+1;
        elseif i == height(feats.(feat))
            edge = i-1:i;
        else
            edge = i-1:i+1;
        end

        for x = edge % for relevant segments
            switch feats.(feat).type(x)
                case "act" % if act
                    marker = "square";
                    switch feats.(feat).actor(x)
                        case "C"
                            value = feats.(feat).cvalue(x);
                            switch feats.(feat).cdirection(x)
                                case 1
                                    colour = "g";
                                case -1
                                    colour = "r";
                                case 0
                                    colour = "b";
                            end
                        case "T"
                            value = feats.(feat).tvalue(x);
                            switch feats.(feat).tdirection(x)
                                case 1
                                    colour = "g";
                                case -1
                                    colour = "r";
                                case 0
                                    colour = "b";
                            end
                    end
                case "crossing" % if crossing
                    marker = "o";
                    colour = "k";
                    value = feats.(feat).cvalue(x);
            end
            plot(ax, feats.(feat).time(x), value, Marker=marker, Color=colour, MarkerSize=3, HandleVisibility="off")
        end
        hold(ax, "off")

        %% Export file
        fig.Color = "w";
        ax.FontName = "Times New Roman";
        exportgraphics(fig, fullfile(outdir, clno + "_" + feat + "_" + feats.(feat).time(i)*10000 + "_" + actor + "." + expformat), Resolution=600);
        close(fig)
    end

    filename = clno + "_" + feat + "_feats.xlsx";
    writetable(feats.(feat), filename)
end

beep on; beep;
end