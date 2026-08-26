function feats = featcalc(data, segments, zerothresh)
% calculates several features for each segment, needs preprocessed data and segments, provided by segment_data plus crossings as points of recontextualisation

%% extract relevant data
improdata=data.smoothed;
diffdata=data.smootheddiff;
rangetotal=data.rangetotalsmoothed;
ranges=data.rangesmoothed;

%% Define Feature and Actor names for indexing
feature_names = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"]';
actor_names = ["C", "T"]';

%% Initiate Single Actor Feature Calculations
for f=1:height(feature_names)
    feat = feature_names(f);
    for a = 1:height(actor_names)
        actor = actor_names(a);
        var = strcat(feat, actor); %define data column from feat and actor

        actor_str = repmat(actor, height(segments.(feat).(actor)), 1);
        action_str = repmat("act", height(segments.(feat).(actor)), 1);
        cross_str = repmat("crossing", height(segments.(feat).crossings), 1);

        %% Single Actor Calculations

        % toown
        % transform action idx, times and actor to table
        times = improdata.Time(segments.(feat).(actor).idx);
        feature_table=table(segments.(feat).(actor).idx, segments.(feat).(actor).type, times , actor_str, action_str, VariableNames=["idx", "segtype", "time", "actor", "type"]);
        % calculate differences between own actions plus time until last action ends
        feature_table_diff=table([diff(improdata.Time(feature_table.idx)); improdata.Time(data.(strcat("end", actor)))-improdata.Time(feature_table.idx(end))]);
        % concatenate both into a table
        feature_table=[feature_table, feature_table_diff];
        feature_table=renamevars(feature_table, "Var1", "toown");     % rename Var1 to own time
        % add values at segments
        feature_table.value = improdata.(var)(feature_table.idx);

        % fromown
        feature_table.fromown = [NaN; diff(times)];

        % Direction calculated directly in segmentation
        feature_table.direction=segments.(feat).(actor).direction;

        % abschgvalue (Absolute Change Value)
        % differences between next and current entry (difference to next), positive = ascending curve, negative = descending curve
        notEndMask = ~isnan(feature_table.direction(1:end-1));
        stepChange = feature_table.value(2:end) - feature_table.value(1:end-1);
        abschgval = NaN(height(feature_table)-1, 1);
        abschgval(notEndMask) = stepChange(notEndMask);
        abschgval=[abschgval; improdata.(var)(data.(strcat("end", actor)))-feature_table.value(end)];
        
        % assign abschgvalue to table
        feature_table.abschgvalue=abschgval;

        % chngfactor
        changevalues = NaN(height(feature_table)-1, 1);
        stepFactor = feature_table.value(2:end) ./ feature_table.value(1:end-1);
        changevalues(notEndMask) = stepFactor(notEndMask);
        changevalues=[changevalues; improdata.(var)(data.(strcat("end", actor)))/feature_table.value(end)];
        % assign changevalues to table
        feature_table.cchngfactor=changevalues;

        % rangepercent, totalrangepercent
        % percentage of change compared to total range
        feature_table.rangepercent=feature_table.abschgvalue/ranges.(var);
        feature_table.totalrangepercent=feature_table.abschgvalue/rangetotal.(feat);

        % indivintensity, totalintensity, absintensity
        % calculate rangepercent vs. time - intensity value. change in percentage of range per second
        feature_table.indivintensity=feature_table.rangepercent./feature_table.toown;
        feature_table.totalintensity=feature_table.totalrangepercent./feature_table.toown;
        feature_table.absintensity=feature_table.abschgvalue./feature_table.toown;

        % zero Direction calculation as in/decrease smaller than 0.01 intensity (1 positive, -1 negative, 0 neutral)
        % segmentsc.direction(segments.intensity > -0.01 & segments.intensity < 0.01) = 0;
        % only assign zero if the original value is not NaN, so that ends aren't reinterpreted
        feature_table.direction(abs(feature_table.indivintensity) < zerothresh & ~isnan(feature_table.direction)) = 0;
        feature_table = renamevars(feature_table, string(feature_table.Properties.VariableNames(6:end)) , strcat(lower(actor), string(feature_table.Properties.VariableNames(6:end)))); %rename actor specific features
        features.(actor) = feature_table;
    end

    %% Concatenation of Therapist and Client tables
    tblwidth=width(features.C);
    % prepare ctable for concatenation
    tblsegmentsc=[features.C, array2table(NaN(height(features.C), tblwidth-5))];
    tblsegmentst=[features.T, array2table(NaN(height(features.T), tblwidth-5))];
    segmentwidth=width(tblsegmentsc);
    tblsegmentsc.Properties.VariableNames(tblwidth+1:segmentwidth)=features.T.Properties.VariableNames(6:16);
    % prepare ttable for concatenation
    tblsegmentst.Properties.VariableNames(tblwidth+1:segmentwidth)=features.C.Properties.VariableNames(6:16);
    % concatenate both tables
    segmentsct=sortrows([tblsegmentsc; tblsegmentst], "time", "ascend");

    %% Calculate fromother
    % preallocation
    fromother=NaN(height(segmentsct), 1);
    % find beginning of interaction
    interactionbegin=find(segmentsct.actor~=(segmentsct.actor(1)), 1, "first");

    timeCol = segmentsct.time;
    actorColCT = segmentsct.actor;
    for i=interactionbegin:height(segmentsct)
        if actorColCT(i)==actorColCT(i-1) % if last actor was the same actor
            fromother(i)=(timeCol(i)-timeCol(i-1))+fromother(i-1); % extend fromother value
        elseif actorColCT(i)~=actorColCT(i-1) % if last actor was another actor
            fromother(i)=timeCol(i)-timeCol(i-1); % create new time
        end
    end
    segmentsct.fromother=fromother;

    %% Prepare and insert Crossings
    % create array of crossings plus empty columns for variables for later concatenation
    crossingsarray=segments.(feat).crossings{:, 1:2};
    empty=NaN(height(crossingsarray), 1);
    crossarray4tbl=[empty, empty, segments.(feat).crossings{:, 1}, empty, empty, empty, segments.(feat).crossings{:, 2}, NaN(height(segments.(feat).crossings{:, 1:2}), (segmentwidth-6))];
    crosstable=array2table(crossarray4tbl, "VariableNames", segmentsct.Properties.VariableNames);
    crosstable.type=cross_str;
    % concatenate and sort both into single table
    segmentstotal=sortrows([segmentsct; crosstable], "time", "ascend");
    % Relational Change Values for client and therapist(positive for affirmative, negative for contradictive)

    %% Combined Actor Calculations
    % Fill movement information (doubles)

    % fill crossing information for therapist
    segmentstotal.tvalue(segmentstotal.type=="crossing")=segmentstotal.cvalue(segmentstotal.type=="crossing");
    % client side
    segmentstotal.cvalue(segmentstotal.actor=="T")=improdata.(strcat(feat,"C"))(segmentstotal.idx(segmentstotal.actor=="T"));

    clientCols = segmentstotal{:, 9:16};
    cvalueCol = segmentstotal.cvalue;
    actorCol = segmentstotal.actor;
    cdirCol = segmentstotal.cdirection;
    for x=1:width(clientCols) % double values for client movement information
        for i=2:height(segmentstotal)
            if isnan(clientCols(i,x)) && ~isnan(cvalueCol(i)) && ~(actorCol(i)=="C" && isnan(cdirCol(i))) % if current entry is empty, but theres a value and current entry is no end of play
                clientCols(i,x)=clientCols(i-1,x);
            end
        end
    end

    segmentstotal{:, 9:16} = clientCols;

    % therapist side
    segmentstotal.tvalue(segmentstotal.actor=="C")=improdata.(strcat(feat,"T"))(segmentstotal.idx(segmentstotal.actor=="C"));
    therapistCols = segmentstotal{:, 20:27};
    tvalueCol = segmentstotal.tvalue;
    tdirCol = segmentstotal.tdirection;
    for x=1:width(therapistCols) % double values for therapist movement information
        for i=2:height(segmentstotal)
            if isnan(therapistCols(i,x)) && ~isnan(tvalueCol(i)) && ~(actorCol(i)=="T" && isnan(tdirCol(i))) % if current entry is empty, but theres a value and current entry is no end of play
                therapistCols(i,x)=therapistCols(i-1,x);
            end
        end
    end
    segmentstotal{:, 20:27} = therapistCols;

    % erase ending sequence movement information
    endC_rows = segmentstotal.segtype=="end" & segmentstotal.actor=="C";
    endT_rows = segmentstotal.segtype=="end" & segmentstotal.actor=="T";
    segmentstotal{endC_rows, 9:16} = NaN;
    segmentstotal{endT_rows, 20:27} = NaN;

    % relchgtendencies
    n = height(segmentstotal);
    cdir = segmentstotal.cdirection;
    tdir = segmentstotal.tdirection;
    cval = segmentstotal.cvalue;
    tval = segmentstotal.tvalue;
    isCrossing = segmentstotal.type == "crossing";

    % Client
    crelchgtendency = strings(n, 1); % rows that match nothing stay "" (converted to missing below, same as original)
    soloMask = ~isnan(cdir) & isnan(tdir);
    crossMask = ~isnan(cdir) & ~isnan(tdir) & isCrossing;
    neutralMask = ~isnan(cdir) & ~isnan(tdir) & ~isCrossing & cdir==0;
    belowMask = ~isnan(cdir) & ~isnan(tdir) & ~isCrossing & cdir~=0 & cval<tval;
    aboveMask = ~isnan(cdir) & ~isnan(tdir) & ~isCrossing & cdir~=0 & cval>tval;
    crelchgtendency(soloMask) = "solo"; % if client is playing without therapist - solo
    crelchgtendency(crossMask) = "crossing"; % if both are crossing
    crelchgtendency(neutralMask) = "neutral"; % if movement is 0
    crelchgtendency(belowMask & cdir==1) = "affirmative"; % client below therapist and increasing
    crelchgtendency(belowMask & cdir==-1) = "contradictive"; % client below therapist and decreasing
    crelchgtendency(aboveMask & cdir==1) = "contradictive"; % client above therapist and increasing
    crelchgtendency(aboveMask & cdir==-1) = "affirmative"; % client above therapist and decreasing
    segmentstotal.crelchgtendency=crelchgtendency; % assign vector to table
    segmentstotal.crelchgtendency(segmentstotal.crelchgtendency=="")=missing; % insert missing values

    % Therapist (mirrored)
    trelchgtendency = strings(n, 1);
    soloMaskT = ~isnan(tdir) & isnan(cdir);
    crossMaskT = ~isnan(tdir) & ~isnan(cdir) & isCrossing;
    neutralMaskT = ~isnan(tdir) & ~isnan(cdir) & ~isCrossing & tdir==0;
    belowMaskT = ~isnan(tdir) & ~isnan(cdir) & ~isCrossing & tdir~=0 & tval<cval;
    aboveMaskT = ~isnan(tdir) & ~isnan(cdir) & ~isCrossing & tdir~=0 & tval>cval;
    trelchgtendency(soloMaskT) = "solo"; % if therapist is playing without client - solo
    trelchgtendency(crossMaskT) = "crossing"; % if both are crossing
    trelchgtendency(neutralMaskT) = "neutral"; % if movement is 0
    trelchgtendency(belowMaskT & tdir==1) = "affirmative"; % therapist below client and increasing
    trelchgtendency(belowMaskT & tdir==-1) = "contradictive"; % therapist below client and decreasing
    trelchgtendency(aboveMaskT & tdir==1) = "contradictive"; % therapist above client and increasing
    trelchgtendency(aboveMaskT & tdir==-1) = "affirmative"; % therapist above client and decreasing
    segmentstotal.trelchgtendency=trelchgtendency; % assign vector to table
    segmentstotal.trelchgtendency(segmentstotal.trelchgtendency=="")=missing; % insert missing values

    % Change crossing string values
    relCols = segmentstotal{:, 29:30};
    typeCol = segmentstotal.type;
    for f=1:2 % loop for changing of crossings strings (columns 29:30 = crelchgtendency, trelchgtendency)
        for i=2:height(segmentstotal) % start from 2 for backwards comparison
            if typeCol(i)=="crossing" % if current entry is crossing, change the last entries relchgtendencies for current
                if relCols(i-1,f)=="affirmative"
                    relCols(i,f)="contradictive";
                elseif relCols(i-1,f)=="contradictive"
                    relCols(i,f)="affirmative";
                elseif relCols(i-1,f)=="neutral"
                    relCols(i,f)="neutral";
                end
            end
        end
    end
    segmentstotal{:, 29:30} = relCols;

    % Relchgvalues / relational intensity / relational absolute intensity
    segmentstotal.crelchgvalue = relFromTendency(segmentstotal.crelchgtendency, segmentstotal.cabschgvalue);
    segmentstotal.trelchgvalue = relFromTendency(segmentstotal.trelchgtendency, segmentstotal.tabschgvalue);
    segmentstotal.crelintensity = relFromTendency(segmentstotal.crelchgtendency, segmentstotal.ctotalintensity);
    segmentstotal.trelintensity = relFromTendency(segmentstotal.trelchgtendency, segmentstotal.ttotalintensity);
    segmentstotal.cabsrelintensity = relFromTendency(segmentstotal.crelchgtendency, segmentstotal.cabsintensity);
    segmentstotal.tabsrelintensity = relFromTendency(segmentstotal.trelchgtendency, segmentstotal.tabsintensity);

    % Add Time to next action (tonext)
    timediff=diff(segmentstotal.time);
    % time of last action
    lasttime=improdata.Time(data.endtotal)-segmentstotal.time(end);
    % add time until next to table
    segmentstotal.tonext=[timediff; lasttime];

    % add Time from last Action (fromlast)
    firsttime=segmentstotal.time(1)-improdata.Time(data.begintotal);
    segmentstotal.fromlast=[firsttime; timediff];

    % featdelta, featdeltadifferences and percentages plus meandelta Differences (Delta) of Feature between players at indexes calculation of featdelta as current difference between client and therapist value extract values of client and therapist
    segmentstotal.featdelta = segmentstotal.cvalue-segmentstotal.tvalue;

    % calculate percentage of delta in relation to common total range of feature
    segmentstotal.featdeltapercent=segmentstotal.featdelta/rangetotal.(feat);

    % Delta Tendencies between each index (absolute) last inter(action) isn't followed by another action - therefore no difference to the next
    segmentstotal.featdeltadifference = [diff(segmentstotal.featdelta); NaN];

    % Delta Tendencies Percentage
    % calculate percentage of delta tendencies in relation to common total range of feature
    segmentstotal.featdeltapercentdiff=segmentstotal.featdeltadifference/rangetotal.(feat);

    % calculate mean delta value for current segment
    featdeltamean = []; % explicit fresh start each feature iteration (was implicitly relying on clearvars for this before)
    diffCol = diffdata.(strcat(feat, "Diff"));
    smoothedTime = data.smoothed.Time;
    for h=1:(height(segmentstotal)-1) % loop from beginning until last segment
        begintime=segmentstotal.time(h);
        endtime=segmentstotal.time(h+1);
        between=(begintime < smoothedTime) & (smoothedTime < endtime); % extract time idxs between current and next interaction
        betweendata=diffCol(between); % extract data between actions
        deltadata=[segmentstotal.featdelta(h); betweendata; segmentstotal.featdelta(h+1)]; % concatenate and calculate mean of data in between plus the single entries - slightly unprecise measure for crossings as they are calculated as if .1s duration
        featdeltamean(h)=mean(deltadata);
    end
    featdeltamean=featdeltamean';

    % add last value
    begintime=segmentstotal.time(end); % last time value is beginning
    endtime=smoothedTime(find(~isnan(smoothedTime), 1, "last")); % end is the end of the impro data (last non NaN entry)
    between=(begintime < smoothedTime) & (smoothedTime <= endtime); % extract time idxs util end
    betweendata=diffCol(between); % extract data until end
    deltadata=[segmentstotal.featdelta(end); betweendata]; % concatenate beginning and remaining data
    featdeltamean(end+1)=mean(deltadata); % calculate mean of concatenated data
    segmentstotal.featdeltamean=featdeltamean;
    % featdeltameanpercent
    segmentstotal.featdeltameanpercent=segmentstotal.featdeltamean/data.rangetotal.(feat);

    %% show resulting table, sort and assign to new struct for features
    feats.(feat)=segmentstotal(:, ["idx", "time", "segtype", "type", "actor", "fromother", "tonext", "cvalue", "cdirection", "cabsintensity", "ctotalintensity", "crelintensity", "crelchgtendency", "tvalue", "tdirection", "tabsintensity", "ttotalintensity", "trelintensity", "trelchgtendency","featdeltapercent", "featdeltapercentdiff", "featdeltameanpercent"]);
end
end

%% ------------------------------------------------------------------
function relvalue = relFromTendency(tendency, magnitude)

relvalue = NaN(height(tendency), 1);
relvalue(tendency == "affirmative") = abs(magnitude(tendency == "affirmative"));
relvalue(tendency == "contradictive") = -abs(magnitude(tendency == "contradictive"));
relvalue(tendency == "neutral" | tendency == "solo") = 0;
end