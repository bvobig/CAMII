function exportTypesFn (data, types, typestotal, s, clno, expformat, outdir)

set(0, 'DefaultFigureColor', 'white');

expformat1 = strcat("-", expformat);
%%
time=data.impro.Time;
varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
iatypenames=["Dependent", "Approach", "Follower", "Partner", "Leader", "Resister", "Neutral"];
datanames=data.smoothed.Properties.VariableNames(3:end);
datanameidx=1:2:25;
ct=["c", "t"];

lengthplot = 2000;
lengthbar = 2000;
heightplot = 800;
colorpalette =  [1.0000    0.0000    0.0000; 
                 1.0000    1.0000    0.0000;
                 1.0000    0.4118    0.1608;
                 0.4667    0.6745    0.1882;
                 0         0.4471    0.7412;
                 0.4941    0.1843    0.5569;
                 0.9020    0.9020    0.9020;];
%% Initiate Loops for Plotting

% Feature Loop

for feat=s
    var=varnames(feat);
%%
%%Combined Figure

distributionFig = tiledlayout(2, 3, "TileSpacing","tight", Visible="off");

% Actor Loop

for actoridx=1:2
    actor=ct(actoridx);

    cdataname=datanames{datanameidx(feat)}; % extract Dataset names for indexing
    tdataname=datanames{datanameidx(feat)+1}; % extract Dataset names for indexing

    c=data.smoothed.(cdataname);% extract fitting data for c
    t=data.smoothed.(tdataname);% extract fitting data for t

nexttile ([1 2])

    if actor =="c"
    plot(time, c, "g-", DisplayName="Client"); % plot smoothed data above each other
    hold on 
    plot(time, t, "k--", DisplayName="Therapist")
    

    elseif actor =="t"
    plot(time, c, "g--", DisplayName="Client"); % plot smoothed data above each other
    hold on 
    plot(time, t, "k-", DisplayName="Therapist")
    end

%Identify and Colourise Interactiontype Regions

for iatypeidx=1:width(iatypenames) % counter for visualisation of each interactiontype

ident=types.(actor).(var)==iatypenames(iatypeidx); % identify regions of interactiontypes

beginnings=strfind(ident', [0 1]); % find beginning sequences in the middle
beginnings=beginnings+1; % add 1 for exact point in time
ends=strfind(ident', [1 0]); % find ending sequences in the middle

if ident(1)==1 % if first interaction is of analysed type (begins on type)
    beginnings=[1, beginnings];
elseif ident(end)==1 % if last interaction is of analysed type (ends on type)
    ends(end+1)=height(ident);% last entry is end of improvisation
end

iaindexes=[beginnings; ends]'; % concatenate beginnings and ends in right format
iaindexes=sort(iaindexes); % sort indexes ascending

if nnz(iaindexes)==2 % if only 2 entries exist (result in different ordering)
    regiontimes=time(iaindexes)'; % extract times related with indexes and change dimension to horizontal
    else
    regiontimes=time(iaindexes); % extract times related with indexes and keep original dimensions
end

if ~isempty(regiontimes)
    for reg=1:height(iaindexes)
        region=xregion(regiontimes(reg, :), FaceColor=colorpalette(iatypeidx, :), FaceAlpha=0.1);
        if reg==1
            region.DisplayName=iatypenames(iatypeidx);
        else
            region.HandleVisibility="off";
        end
    end
end

clear regiontimes indexes ends beginnings ident iaindexes

end

hold off

switch actor % Add fitting Title and labels
    case "c"

    fontname("Times New Roman")
    title("Client", FontAngle="normal")
    ylabel(var, FontAngle="normal")
    set (gcf, 'position', [10 10 lengthplot heightplot])
    legend(Location="eastoutside", FontAngle="normal")

    case"t"

    fontname("Times New Roman")
    title("Therapist", FontAngle="normal")
    ylabel(var, FontAngle="normal")
    xlabel("Time in Seconds (s)", FontAngle="normal")
    set (gcf, 'position', [10 10 lengthplot heightplot])
    legend(Location="eastoutside", FontAngle="normal")

end

%Plot whole Feature Percentage

nexttile ([1 1])
    statbar=bar(1:7, typestotal.(actor).(var){1, :}, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
    fontname("Times New Roman")
    ylabel("Decimal Percentage", FontAngle="normal")
    ylim([0 (max(typestotal.(actor).(var){1, :})+0.1)])
    xticklabels(iatypenames)

    xtips1 = statbar.XEndPoints;
    ytips1 = statbar.YEndPoints;
    labels1 = string(statbar.YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

switch actor
    case "c"
        xticklabels(iatypenames)
        title("Client", FontAngle="normal")
    case "t"
        xticklabels(iatypenames)
        title("Therapist", FontAngle="normal")
end
end

    exportgraphics(distributionFig, fullfile(outdir, clno + "_iatypes_" + var + "_distribution.png"), Resolution=600)

%Visualise Difference between Client and Therapist

typesdiff=typestotal.c.(var)-typestotal.t.(var); % positive values - client direction, negative values, therapist direction

figure (Visible="off")
    bar(1:7, typesdiff{1, :}, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
    xticklabels(iatypenames)
    ylabel("Difference in Decimal Percentage")
    axis([0, 7, -1, 1])
    yyaxis right
    yticks([])
    set (gca, "YColor", "k")
    ylabel ("Therapist                         Client", Color="k")
    yyaxis left
    title ("Gradient Prevalence Comparison")
    set(gca, fontname="Times New Roman")

    export_fig(fullfile(outdir, clno + "_iatypes_" + (var) + "_comparison"), expformat1, "-r600")

    %%
%%Single Visualisations

for actoridx=1:2
    actor=ct(actoridx);

figure (Visible="off")
    if actor =="c"
    plot(time, c, "g-", DisplayName="Client"); % plot smoothed data above each other
    hold on 
    plot(time, t, "k--", DisplayName="Therapist")
    

    elseif actor =="t"
    plot(time, c, "g--", DisplayName="Client"); % plot smoothed data above each other
    hold on 
    plot(time, t, "k-", DisplayName="Therapist")
    end

%Identify and Colourise Interactiontype Regions

for iatypeidx=1:width(iatypenames) % counter for visualisation of each interactiontype

ident=types.(actor).(var)==iatypenames(iatypeidx); % identify regions of interactiontypes

beginnings=strfind(ident', [0 1]); % find beginning sequences in the middle
beginnings=beginnings+1; % add 1 for exact point in time
ends=strfind(ident', [1 0]); % find ending sequences in the middle

if ident(1)==1 % if first interaction is of analysed type (begins on type)
    beginnings=[1, beginnings];
elseif ident(end)==1 % if last interaction is of analysed type (ends on type)
    ends(end+1)=height(ident);% last entry is end of improvisation
end

iaindexes=[beginnings; ends]'; % concatenate beginnings and ends in right format
iaindexes=sort(iaindexes); % sort indexes ascending

if nnz(iaindexes)==2 % if only 2 entries exist (result in different ordering)
    regiontimes=time(iaindexes)'; % extract times related with indexes and change dimension to horizontal
    else
    regiontimes=time(iaindexes); % extract times related with indexes and keep original dimensions
end

if ~isempty(regiontimes)
    for reg=1:height(iaindexes)
        region=xregion(regiontimes(reg, :), FaceColor=colorpalette(iatypeidx, :), FaceAlpha=0.1);
        if reg==1
            region.DisplayName=iatypenames(iatypeidx);
        else
            region.HandleVisibility="off";        end
    end
end

clear regiontimes indexes ends beginnings ident iaindexes

end


hold off

switch actor % Add fitting Title and labels
    case "c"

    fontname("Times New Roman")
    title("Client", FontAngle="normal")
    ylabel(var, FontAngle="normal")
    set (gcf, 'position', [10 10 lengthplot (heightplot/2)])
    legend(Location="eastoutside", FontAngle="normal")

    case"t"

    fontname("Times New Roman")
    title("Therapist", FontAngle="normal")
    ylabel(var, FontAngle="normal")
    xlabel("Time in Seconds (s)", FontAngle="normal")
    set (gcf, 'position', [10 10 lengthplot (heightplot/2)])
    legend(Location="eastoutside", FontAngle="normal")

end 

    export_fig(fullfile(outdir, clno + "_iatypes_" + (var) + "_" + actor + "_evolution"), expformat1, "-r600")     

%Plot whole Feature Percentage

figure (Visible="off")
    statbar=bar(1:7, typestotal.(actor).(var){1, :}, FaceColor="flat", CData=colorpalette, FaceAlpha=0.1);
    fontname("Times New Roman")
    ylabel("Decimal Percentage", FontAngle="normal")
    ylim([0 (max(typestotal.(actor).(var){1, :})+0.1)])
    xticklabels(iatypenames)

    xtips1 = statbar.XEndPoints;
    ytips1 = statbar.YEndPoints;
    labels1 = string(statbar.YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

switch actor
    case "c"
        xticklabels(iatypenames)
        title("Client", FontAngle="normal")
    case "t"
        xticklabels(iatypenames)
        title("Therapist", FontAngle="normal")
end

    export_fig(fullfile(outdir, clno + "_iatypes_" + (var) + "_" + actor + "_distribution"), expformat1, "-r600")

end
%%
end