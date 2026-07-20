function exportStatsFn(data, stats, s, clno, expformat, outdir)
% Plot and export action-type statistics per actor/feature.


%% Prepare Data for Plotting and Define Plotting Variables
varnames = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
interactiontypenameslvl1 = stats.c.MeanVelocity.percenttable1.Properties.VariableNames;
interactiontypenameslvl2 = stats.c.MeanVelocity.percenttable2.Properties.VariableNames;
interactiontypenameslvl3 = stats.c.MeanVelocity.percenttable3.Properties.VariableNames;

orange = [0.8500 0.3250 0.0980];
orangelight = [1.0000 0.7059 0.5804];
black = [0 0 0];
grey = [0.6510 0.6510 0.6510];
blue = [0 0.4470 0.7410];
bluelight = [0.4510 0.6902 0.9020];

graphcolors1 = [orange;orange;orange; orangelight;orangelight;orangelight; black;black;black; grey;grey;grey; blue;blue;blue; bluelight;bluelight;bluelight];
graphcolors2 = [orange; orangelight; black; grey; blue; bluelight];
graphcolors3 = [orange; black; blue];

lengthplot = 1500; %height(data.impro)/5;
heightplot = 300;
ct = ["c", "t"];
CT = ["Client", "Therapist"];

%% Initiate Loops for Plotting along Actors and chosen Feature
% Actor Loop
for actoridx = 1:2
    act = ct(actoridx);

    % Feature Selection / Loop
    for t = s
        var = varnames(t);

        %% Combined Graphs
        % Level 1
        fig1 = figure(Visible="off", Position=[10 10 lengthplot heightplot], Color="w");
        ax1 = axes(fig1);
        plot(ax1, data.impro.Time, stats.(act).(var).percenttable1{:, :})
        linestyleorder(ax1, ["-"; "--"; ":"])
        colororder(ax1, graphcolors1)
        ylim(ax1, [0 1.1])
        %legend(ax1, interactiontypenameslvl1, Location="southoutside", Orientation="horizontal", NumColumns=10)
        xlabel(ax1, "Time in Seconds (s)")
        ylabel(ax1, "Decimal Percentage")
        title(ax1, "Action Type Evolution - Level 1 " + "(" + CT(actoridx) + ")")
        ax1.FontName = "Times New Roman";
        exportgraphics(fig1, fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_total_lvl1." + expformat), Resolution=600);
        close(fig1)

        % Level 2
        fig2 = figure(Visible="off", Position=[10 10 lengthplot heightplot], Color="w");
        ax2 = axes(fig2);
        plot(ax2, data.impro.Time, stats.(act).(var).percenttable2{:, :})
        colororder(ax2, graphcolors2)
        linestyleorder(ax2, ["-"; "--"])
        ylim(ax2, [0 1.1])
        legend(ax2, interactiontypenameslvl2, Location="northeast")
        xlabel(ax2, "Time in Seconds (s)")
        ylabel(ax2, "Decimal Percentage")
        title(ax2, "Action Type Evolution - Level 2 " + "(" + CT(actoridx) + ")")
        ax2.FontName = "Times New Roman";
        exportgraphics(fig2, fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_total_lvl2." + expformat), Resolution=600);
        close(fig2)

        % Level 3
        fig3 = figure(Visible="off", Position=[10 10 lengthplot heightplot], Color="w");
        ax3 = axes(fig3);
        plot(ax3, data.impro.Time, stats.(act).(var).percenttable3{:, :})
        colororder(ax3, graphcolors3)
        ylim(ax3, [0 1.1])
        legend(ax3, interactiontypenameslvl3, Location="northeast")
        xlabel(ax3, "Time in Seconds (s)")
        ylabel(ax3, "Decimal Percentage")
        title(ax3, "Action Type Evolution - Level 3 " + "(" + CT(actoridx) + ")")
        ax3.FontName = "Times New Roman";
        exportgraphics(fig3, fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_total_lvl3." + expformat), Resolution=600);
        close(fig3)

        %% Separated Graphs
        % Affirmative
        fig4 = figure(Visible="off", Position=[10 10 lengthplot heightplot], Color="w");
        ax4 = axes(fig4);
        hold(ax4, "on")
        plot(ax4, data.impro.Time, stats.(act).(var).percenttable2{:,1}, Color=orange, DisplayName="A.I")
        plot(ax4, data.impro.Time, stats.(act).(var).percenttable2{:,2}, Color=orangelight, DisplayName="A.II", LineStyle="--")
        hold(ax4, "off")
        ylim(ax4, [0 1.1])
        xlabel(ax4, "Time in Seconds (s)")
        ylabel(ax4, "Decimal Percentage")
        title(ax4, "Affirmative Action Type Evolution - I and II " + "(" + CT(actoridx) + ")")
        ax4.FontName = "Times New Roman";
        exportgraphics(fig4, fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_single_Affirmative_lvl2." + expformat), Resolution=600);
        close(fig4)

        % Contradictive
        fig5 = figure(Visible="off", Position=[10 10 lengthplot heightplot], Color="w");
        ax5 = axes(fig5);
        hold(ax5, "on")
        plot(ax5, data.impro.Time, stats.(act).(var).percenttable2{:,5}, Color=blue, DisplayName="C.I")
        plot(ax5, data.impro.Time, stats.(act).(var).percenttable2{:,6}, Color=bluelight, DisplayName="C.II", LineStyle="--")
        hold(ax5, "off")
        ylim(ax5, [0 1.1])
        %legend(ax5, Location="eastoutside")
        xlabel(ax5, "Time in Seconds (s)")
        ylabel(ax5, "Decimal Percentage")
        title(ax5, "Contradictive Action Type Evolution - I and II " + "(" + CT(actoridx) + ")")
        ax5.FontName = "Times New Roman";
        exportgraphics(fig5, fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_single_Contradictive_lvl2." + expformat), Resolution=600);
        close(fig5)

        % Neutral
        fig6 = figure(Visible="off", Position=[10 10 lengthplot heightplot], Color="w");
        ax6 = axes(fig6);
        hold(ax6, "on")
        plot(ax6, data.impro.Time, stats.(act).(var).percenttable2{:,3}, Color=black, DisplayName="N.I")
        plot(ax6, data.impro.Time, stats.(act).(var).percenttable2{:,4}, Color=grey, DisplayName="N.II", LineStyle="--")
        hold(ax6, "off")
        ylim(ax6, [0 1.1])
        %legend(ax6, Location="eastoutside")
        xlabel(ax6, "Time in Seconds (s)")
        ylabel(ax6, "Decimal Percentage")
        title(ax6, "Neutral Action Type Evolution - I and II " + "(" + CT(actoridx) + ")")
        ax6.FontName = "Times New Roman";
        exportgraphics(fig6, fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_single_Neutral_lvl2." + expformat), Resolution=600);
        close(fig6)

        %% Total Action Type Distribution
        barcolors = [0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980; 1.0000 0.7059 0.5804; 0 0.4470 0.7410; 0 0.4470 0.7410; 0.4510 0.6902 0.9020; 0 0 0; 0 0 0; 0.6510 0.6510 0.6510];
        bardata = [stats.(act).(var).totalstats3{1, 1}, stats.(act).(var).totalstats2{1, 1}, stats.(act).(var).totalstats2{1, 2};
                   stats.(act).(var).totalstats3{1, 2}, stats.(act).(var).totalstats2{1, 3}, stats.(act).(var).totalstats2{1, 4}
                   stats.(act).(var).totalstats3{1, 3}, stats.(act).(var).totalstats2{1, 5}, stats.(act).(var).totalstats2{1, 6}];

        fig7 = figure(Visible="off", Color="w");
        ax7 = axes(fig7);
        b = bar(ax7, bardata, FaceColor="flat");
        b(1).CData(1,:) = barcolors(1, :);
        b(2).CData(1,:) = barcolors(2, :);
        b(3).CData(1,:) = barcolors(3, :);
        b(1).CData(2,:) = barcolors(7, :);
        b(2).CData(2,:) = barcolors(8, :);
        b(3).CData(2,:) = barcolors(9, :);
        b(1).CData(3,:) = barcolors(4, :);
        b(2).CData(3,:) = barcolors(5, :);
        b(3).CData(3,:) = barcolors(6, :);
        xticklabels(ax7, ["A     A.I    A.II", "N    N.I    N.II", "C     C.I    C.II"])
        b(3).LineStyle = "--";
        title(ax7, "Total Action Type Distribution " + "(" + CT(actoridx) + ")")
        ylabel(ax7, "Decimal percentage")
        xlabel(ax7, "Types")
        ax7.FontName = "Times New Roman";
        exportgraphics(fig7, fullfile(outdir, clno + "_stats_" + var + "_" + CT(actoridx) + "_global." + expformat), Resolution=600);
        close(fig7)
    end
end
end