function segexport (data, segments, feats, s, clno, expformat)
% plot and export segments based on chosen segmentation and feature calculation

%% Prepare Data for Plotting and Define Plotting Variables
 
fieldname=fieldnames(segments.direction);
varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
 
for t=s
z=(t+1)/2;
var=varnames(z);
fieldC=fieldname{t};
fieldT=fieldname{t+1};
 
% Define Segment
for i=1:height(feats.(var))

space=50; % how many ms before and after for plotting
 
% determine plot area
if i==1 % if first entry
        areabegin=(feats.(var).idx(i));
        areaend=feats.(var).idx(find(feats.(var).type(i+1:end)~="crossing", 1, "first")+i); % find next "act" entry; adding i due to find function purposes 
        areaidx=areabegin:(areaend+space);
elseif i==height(feats.(var)) % if last entry
        areabegin=feats.(var).idx(find(feats.(var).type(1:i-1)~="crossing", 1, "last")); % find last "act" entry
        areaend=height(data.smoothed.(fieldC));
        areaidx=(areabegin-space): (areaend+space);
else % if neither
switch feats.(var).type(i)
    case "act"
        areabegin=feats.(var).idx(find(feats.(var).type(1:i-1)~="crossing", 1, "last")); % find last "act" entry
        areaend=feats.(var).idx(find(feats.(var).type(i+1:end)~="crossing", 1, "first")+i); % find next "act" entry; adding i due to find function purposes 
        areaidx=(areabegin-space): (areaend+space);
    case "crossing"
        areabegin=feats.(var).idx(find(feats.(var).type(1:i-1)~="crossing", 1, "last")); % find last "act" entry
        areaend=feats.(var).idx(find(feats.(var).type(i+1:end)~="crossing", 1, "first")+i); % find next "act" entry; adding i due to find function purposes 
        areaidx=(areabegin-space): (areaend+space);
end
end
 
% shorten area if starts before 1 or ends beyond data range
if areaidx(1)<1
    areaidx=areaidx(areaidx>0);
elseif areaidx(end)>height(data.smoothed)
    areaidx=areaidx(areaidx<=height(data.smoothed));
end

%% Extract matching Time and Curve Values 

time=data.smoothed.Time(areaidx); % extract time from beginning of area until end of area in .1s steps
valuesc=data.smoothed.(fieldC)(areaidx); % extract client values from smoothed data from first to last area idx entry
valuest=data.smoothed.(fieldT)(areaidx); % same for therapist
 
% define length and height of plot
lengthplot=length(areaidx);
heightplot=300;

%% Plot Figure
figure(Position=[10 10 lengthplot heightplot], Visible="off")
    hold on 
    plot(time, valuesc, "g", DisplayName="Client Smoothed")
    plot(time, valuest, "k", DisplayName="Therapist Smoothed")

    uplim=max([data.smoothed.(fieldC); data.smoothed.(fieldT)])*1.1;
    downlim=min([data.smoothed.(fieldC); data.smoothed.(fieldT)])-(data.rangetotalsmoothed.(var)*0.1);
    ylim([downlim uplim])
    
    yline(min(data.smoothed.(fieldC)), "g:", HandleVisibility="off")
    yline(max(data.smoothed.(fieldC)), "g:", DisplayName="Client Range")
    yline(min(data.smoothed.(fieldT)), "k:", HandleVisibility="off")
    yline(max(data.smoothed.(fieldT)), "k:", DisplayName="Therapist Range")
    
    xlabel("Time in Seconds (s)")
    ylabel(var)
if ~ismissing(feats.(var).actor(i))
    actor=feats.(var).actor (i);
elseif ismissing (feats.(var).actor(i))
    actor="crossing";
end
    title(feats.(var).time(i) + "s " + actor)

% add xline to indicate current actor
    if feats.(var).actor(i)=="C"
        xline(feats.(var).time(i), "g", HandleVisibility="off")
    elseif feats.(var).actor(i)=="T"
        xline(feats.(var).time(i), "k", HandleVisibility="off")
    elseif ismissing(feats.(var).actor(i))
        xline(feats.(var).time(i), "b", HandleVisibility="off")
    end

% determine segments to mark
    if i==1
        edge = i:i+1;
    elseif i==height(feats.(var))
        edge = i-1:i;
    else
        edge = i-1:i+1;
    end
for x=edge % for relevant segments
switch feats.(var).type(x)
    case "act" % if act
        marker="square";
        switch feats.(var).actor(x)
            case "C"
                value=feats.(var).cvalue(x);
                switch feats.(var).cdirection(x)
                    case 1
                        colour="g";
                    case -1
                        colour="r";
                    case 0
                        colour="b";
                end
            case "T"
                value=feats.(var).tvalue(x);
                switch feats.(var).tdirection(x)
                    case 1 
                        colour="g";
                    case -1
                        colour="r";
                    case 0
                        colour="b";
                end
        end
    case "crossing" % if crossing
        marker="o";
        colour="k";
        value=feats.(var).cvalue(x);
end
plot(feats.(var).time(x), value, Marker=marker, Color=colour, MarkerSize=3, HandleVisibility="off")

%% Export files

    set(gcf, Color="w")
    set(gca, fontname="Times New Roman")
    export_fig((clno + "_" + var + "_" + feats.(var).time(i)*10000 + "_" + actor), expformat, "-r600");
end
hold off
 
end

filename=clno + "_" + var + "_feats.xlsx";
writetable (feats.(var), filename)

end

beep on; beep;

end