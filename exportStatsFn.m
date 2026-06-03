function exportStatsFn (data, stats, s, clno, expformat, outdir)

expformat1=strcat("-", expformat);

%% Prepare Data for Plotting and Define Plotting Variables

varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

interactiontypenameslvl1=stats.c.MeanVelocity.percenttable1.Properties.VariableNames;
interactiontypenameslvl2=stats.c.MeanVelocity.percenttable2.Properties.VariableNames;
interactiontypenameslvl3=stats.c.MeanVelocity.percenttable3.Properties.VariableNames;

orange=[0.8500 0.3250 0.0980];
orangelight=[1.0000 0.7059 0.5804];
black=[0 0 0];
grey=[0.6510 0.6510 0.6510];
blue=[0 0.4470 0.7410];
bluelight=[0.4510 0.6902 0.9020];

graphcolors1=[orange;orange;orange; orangelight;orangelight;orangelight; black;black;black; grey;grey;grey; blue;blue;blue; bluelight;bluelight;bluelight];
graphcolors2=[orange; orangelight; black; grey; blue; bluelight];
graphcolors3=[orange; black; blue];

lengthplot=1500;%height(data.impro)/5;
heightplot=300;
ct=["c","t"];
CT=["Client","Therapist"];

%% Initiate Loops for Plotting along Actors and chosen Feature

% Actor Loop

for actoridx=1:2
    act=ct(actoridx);

% Feature Selection / Loop

for t=s
var=varnames(t);

% Combined Graphs

figure (Visible="off") % Level 1
    plot(data.impro.Time, stats.(act).(var).percenttable1{:, :})
    linestyleorder(["-"; "--"; ":"])
    colororder(graphcolors1)
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    ylim([0 1.1])
    %legend(interactiontypenameslvl1, "Location","southoutside", Orientation="horizontal", NumColumns=10)
    xlabel("Time in Seconds (s)")
    ylabel("Decimal Percentage")
    title("Action Type Evolution - Level 1 " + "(" + CT(actoridx) + ")")
        set (gca, fontname="Times New Roman")
        export_fig(fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_total_lvl1"), expformat1, "-r600");

figure (Visible="off") % Level 2
    plot(data.impro.Time, stats.(act).(var).percenttable2{:, :})
    colororder(graphcolors2)
    linestyleorder(["-"; "--"])
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    ylim([0 1.1])
    legend(interactiontypenameslvl2, "Location","northeast")
    xlabel("Time in Seconds (s)")
    ylabel("Decimal Percentage")
    title("Action Type Evolution - Level 2 " + "(" + CT(actoridx) + ")")
        set (gca, fontname="Times New Roman")
        export_fig(fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_total_lvl2"), expformat1, "-r600");

figure (Visible="off") % Level 3
    plot(data.impro.Time, stats.(act).(var).percenttable3{:, :})
    colororder(graphcolors3)
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    ylim([0 1.1])
    legend(interactiontypenameslvl3, "Location","northeast")
    xlabel("Time in Seconds (s)")
    ylabel("Decimal Percentage")
    title("Action Type Evolution - Level 3 " + "(" + CT(actoridx) + ")")
        set (gca, fontname="Times New Roman")
        export_fig(fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_total_lvl3"), expformat1, "-r600");

% Separated Graphs

figure (Visible="off") % Affirmative
    plot(data.impro.Time, stats.(act).(var).percenttable2{:,1}, Color=orange, DisplayName="A.I")
    hold on 
    plot(data.impro.Time, stats.(act).(var).percenttable2{:,2}, Color=orangelight, DisplayName="A.II", LineStyle="--")
    hold off
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    ylim([0 1.1])
    xlabel("Time in Seconds (s)")
    ylabel("Decimal Percentage")
    title("Affirmative Action Type Evolution - I and II " + "(" + CT(actoridx) + ")")
        set (gca, fontname="Times New Roman")
        export_fig(fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_single_Affirmative_lvl2"), expformat1, "-r600");

figure (Visible="off") % Contradictive
    plot(data.impro.Time, stats.(act).(var).percenttable2{:,5}, Color=[0 0.4470 0.7410], DisplayName="C.I")
    hold on 
    plot(data.impro.Time, stats.(act).(var).percenttable2{:,6}, Color=[0.4510 0.6902 0.9020], DisplayName="C.II", LineStyle="--")
    hold off
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    ylim([0 1.1])
    %legend(Location="eastoutside")
    xlabel("Time in Seconds (s)")
    ylabel("Decimal Percentage")
    title("Contradictive Action Type Evolution - I and II " + "(" + CT(actoridx) + ")")
        set (gca, fontname="Times New Roman")
        export_fig(fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_single_Contradictive_lvl2"), expformat1, "-r600");

figure (Visible="off") % Neutral
    plot(data.impro.Time, stats.(act).(var).percenttable2{:,3}, Color=[0 0 0], DisplayName="N.I")
    hold on 
    plot(data.impro.Time, stats.(act).(var).percenttable2{:,4}, Color=[0.6510 0.6510 0.6510], DisplayName="N.II", LineStyle="--")
    hold off
    set (gcf, 'position', [10 10 lengthplot heightplot], Color="w")
    ylim([0 1.1])
    %legend(Location="eastoutside")
    xlabel("Time in Seconds (s)")
    ylabel("Decimal Percentage")
    title("Neutral Action Type Evolution - I and II " + "(" + CT(actoridx) + ")")
        set (gca, fontname="Times New Roman")
        export_fig(fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_single_Neutral_lvl2"), expformat1, "-r600");

% Total Action Type Distribution

barcolors=[0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980; 1.0000 0.7059 0.5804; 0 0.4470 0.7410; 0 0.4470 0.7410; 0.4510 0.6902 0.9020; 0 0 0; 0 0 0; 0.6510 0.6510 0.6510];

bardata=[stats.(act).(var).totalstats3{1, 1}, stats.(act).(var).totalstats2{1, 1}, stats.(act).(var).totalstats2{1, 2};
        stats.(act).(var).totalstats3{1, 2}, stats.(act).(var).totalstats2{1, 3}, stats.(act).(var).totalstats2{1, 4}
        stats.(act).(var).totalstats3{1, 3}, stats.(act).(var).totalstats2{1, 5}, stats.(act).(var).totalstats2{1, 6}];

figure (Visible="off")
    b = bar(bardata, FaceColor="flat");
    
    b(1).CData(1,:)=barcolors(1, :);
    b(2).CData(1,:)=barcolors(2, :);
    b(3).CData(1,:)=barcolors(3, :);
    
    b(1).CData(2,:)=barcolors(7, :);
    b(2).CData(2,:)=barcolors(8, :);
    b(3).CData(2,:)=barcolors(9, :);
    
    b(1).CData(3,:)=barcolors(4, :);
    b(2).CData(3,:)=barcolors(5, :);
    b(3).CData(3,:)=barcolors(6, :);
    
    xticklabels(["A     A.I    A.II", "N    N.I    N.II", "C     C.I    C.II"])
    b(3).LineStyle="--";
    
    title ("Total Action Type Distribution " + "(" + CT(actoridx) + ")")
    ylabel("Decimal percentage")
    xlabel("Types")
        set (gca, fontname="Times New Roman")
        set (gcf, Color="w")
        export_fig(fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_global"), expformat1, "-r600");

end
end