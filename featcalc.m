function feats = featcalc(data, segments, zerothresh)
% calculates several features for each segment, needs preprocessed data and segments, provided by segmentsol or segmentsbv plus crossings as points of recontextualisation
% manual zerodetection entry (1=on, 0=off)

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

    clearvars -except a actor f feat feats var features feature_names actor_names improdata diffdata rangetotal ranges zerothresh segments data mttbdata
   

    %Create actor vectors and action type vectors
        actor_str(1:height(segments.(feat).(actor))) = actor; actor_str = actor_str';
        action_str(1:height(segments.(feat).(actor))) = "act"; action_str = action_str';
        cross_str(1:height(segments.(feat).crossings)) ="crossing"; cross_str = cross_str';
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
        % preallocation
        feature_table.fromown=zeros(height(feature_table), 1);
        feature_table.fromown(1)=NaN;
        for i=2:height(feature_table)
            feature_table.fromown(i)=improdata.Time(feature_table.idx(i))-improdata.Time(feature_table.idx(i-1));
        end

    % Direction
        % calculated directly in segmentation
        feature_table.direction=segments.(feat).(actor).direction;

    % abschgvalue (Absolute Change Value)
        abschgval=NaN(height(feature_table)-1,1); % preallocation
        % differences between next and current entry (difference to next), positive
        % = ascending curve, negative = descending curve
        for i=1:(height(feature_table)-1)
            if ~isnan(feature_table.direction(i)) % if no ending
            abschgval(i)=feature_table.value(i+1)-feature_table.value(i);
            elseif isnan(feature_table.direction(i))
            abschgval(i)=NaN;
            end
        end
        abschgval=[abschgval; improdata.(var)(data.endC)-feature_table.value(end)];
        % assign abschgvalue to table
        feature_table.abschgvalue=abschgval;

    % chngfactor
        changevalues=zeros(height(feature_table)-1, 1); % preallocation
        for i=1:(height(feature_table)-1)
            if ~isnan(feature_table.direction(i)) % if no ending
            changevalues(i)=feature_table.value(i+1)/feature_table.value(i);
            elseif isnan(feature_table.direction(i))
            changevalues(i)=NaN;
            end
        end
        changevalues=[changevalues; improdata.(var)(data.endC)/feature_table.value(end)];
        % assign changevalues to table
        feature_table.cchngfactor=changevalues;

    % rangepercent, totalrangepercent
        % percentage of change compared to total range
        feature_table.rangepercent=feature_table.abschgvalue/ranges.(var);
        feature_table.totalrangepercent=feature_table.abschgvalue/rangetotal.(feat);

    % indivintensity, totalintensity, absintensity
        % calculate rangepercent vs. time - intensity value. change in percentage of
        % range per second
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
for i=interactionbegin:height(segmentsct)
        if segmentsct.actor(i)==segmentsct.actor(i-1) % if last actor was the same actor
            fromother(i)=(segmentsct.time(i)-segmentsct.time(i-1))+fromother(i-1); % extend fromother value
        elseif segmentsct.actor(i)~=segmentsct.actor(i-1) % if last actor was another actor
            fromother(i)=segmentsct.time(i)-segmentsct.time(i-1); % create new time
        end
end

segmentsct.fromother=fromother;

%% Prepare and insert Crossings

% create array of crossings plus empty columns for variables for later
% concatenation
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
    
    for x=9:16 % double values for client movement information
        for i=2:height(segmentstotal)
           if isnan(segmentstotal.(x)(i)) & ~isnan(segmentstotal.cvalue(i)) & ~(segmentstotal.actor(i)=="C" & isnan(segmentstotal.cdirection(i))) % if current entry is empty, but theres a value and current entry is no end of play
               segmentstotal.(x)(i)=segmentstotal.(x)(i-1);
          end
       end
    end
    
    % therapist side
    segmentstotal.tvalue(segmentstotal.actor=="C")=improdata.(strcat(feat,"T"))(segmentstotal.idx(segmentstotal.actor=="C"));
    
    for x=20:27 % double values for therapist movement information
        for i=2:height(segmentstotal)
           if isnan(segmentstotal.(x)(i)) & ~isnan(segmentstotal.tvalue(i)) & ~(segmentstotal.actor(i)=="T" & isnan(segmentstotal.tdirection(i))) % if current entry is empty, but theres a value and current entry is no end of play
               segmentstotal.(x)(i)=segmentstotal.(x)(i-1);
          end
       end
    end
    
    % erase ending sequence movement information
    for endloc=1:height(segmentstotal)
        if segmentstotal.segtype(endloc)=="end"
            if segmentstotal.actor(endloc)=="C"
                segmentstotal{endloc, 9:16}=NaN;
            elseif segmentstotal.actor(endloc)=="T"
                segmentstotal{endloc, 20:27}=NaN;            
            end
        end
    end


% relchgtendencies

    % Client
    
    for i=1:height(segmentstotal)
        if isnan(segmentstotal.cdirection(i))
            crelchgtendency(i)="";
        elseif isnan(segmentstotal.tdirection(i)) % if client is playing without therapist - solo
            crelchgtendency(i) = "solo";
        elseif segmentstotal.type(i) == "crossing" % if both are crossing
            crelchgtendency(i)="crossing";
        elseif segmentstotal.cdirection(i) == 0 % if movement is 0
            crelchgtendency(i) = "neutral";
        elseif segmentstotal.cvalue(i) < segmentstotal.tvalue(i) % if client is below therapist
            if segmentstotal.cdirection(i) == 1 % and increasing
                crelchgtendency(i)="affirmative";
            elseif segmentstotal.cdirection(i) == -1 % and decreasing
                crelchgtendency(i) = "contradictive";
            end
        elseif segmentstotal.cvalue(i) > segmentstotal.tvalue(i) % if client is above therapist
            if segmentstotal.cdirection(i) == 1 % and increasing
                crelchgtendency(i)="contradictive"; 
            elseif segmentstotal.cdirection(i) == -1 % and decreasing
                crelchgtendency(i) = "affirmative";
            end
        end
    end

    segmentstotal.crelchgtendency=crelchgtendency'; % assign vector to table
    segmentstotal.crelchgtendency(segmentstotal.crelchgtendency=="")=missing; % insert missing values
    
    % Therapist
    
    for i=1:height(segmentstotal)
        if isnan(segmentstotal.tdirection(i))
            trelchgtendency(i)="";
        elseif isnan(segmentstotal.cdirection(i))% if therapist is playing without client - solo
            trelchgtendency(i) = "solo";
        elseif segmentstotal.type(i) == "crossing" % if both are crossing
            trelchgtendency(i)="crossing";
        elseif segmentstotal.tdirection(i) == 0 % if movement is 0
            trelchgtendency(i) = "neutral";
        elseif segmentstotal.tvalue(i) < segmentstotal.cvalue(i) % if therapist is below client
            if segmentstotal.tdirection(i) == 1 % and increasing
                trelchgtendency(i)="affirmative";
            elseif segmentstotal.tdirection(i) == -1 % and decreasing
                trelchgtendency(i) = "contradictive";
            end
        elseif segmentstotal.tvalue(i) > segmentstotal.cvalue(i) % if therapist is above client
            if segmentstotal.tdirection(i) == 1 % and increasing
                trelchgtendency(i)="contradictive";
            elseif segmentstotal.tdirection(i) == -1 % and decreasing
                trelchgtendency(i) = "affirmative";
            end
        end
    end
    
    segmentstotal.trelchgtendency=trelchgtendency'; % assign vector to table
    segmentstotal.trelchgtendency(segmentstotal.trelchgtendency=="")=missing; % insert missing values

% Change crossing string values
    
    % loop for changing of crossings strings
    for f=29:30
        for i=2:height(segmentstotal) % start from 2 for backwards comparison
            if segmentstotal.type(i)=="crossing" % if current entry is crossing, change the last entries relchgtendencies for current
                if segmentstotal.(f)(i-1)=="affirmative"
                   segmentstotal.(f)(i)="contradictive";
                elseif segmentstotal.(f)(i-1)=="contradictive"
                   segmentstotal.(f)(i)="affirmative";
               elseif segmentstotal.(f)(i-1)=="neutral"
                    segmentstotal.(f)(i)="neutral";
                end
            end
        end
    end

% Relchgvalues

    % preallocate
    crelchgvalue=NaN(height(segmentstotal), 1);
    for i=1:height(segmentstotal)
        if segmentstotal.crelchgtendency(i) == "affirmative"
           crelchgvalue(i) = abs(segmentstotal.cabschgvalue(i));
        elseif segmentstotal.crelchgtendency(i) == "contradictive"
           crelchgvalue(i) = -abs(segmentstotal.cabschgvalue(i)); 
        elseif segmentstotal.crelchgtendency(i) == "neutral"
           crelchgvalue(i) = 0;
        elseif segmentstotal.crelchgtendency(i) == "solo"
           crelchgvalue(i) = 0;
        end
    end
    segmentstotal.crelchgvalue=crelchgvalue;
    
    % preallocate
    trelchgvalue=NaN(height(segmentstotal), 1);
    for i=1:height(segmentstotal)
        if segmentstotal.trelchgtendency(i) == "affirmative"
           trelchgvalue(i) = abs(segmentstotal.tabschgvalue(i));
        elseif segmentstotal.trelchgtendency(i) == "contradictive"
           trelchgvalue(i) = -abs(segmentstotal.tabschgvalue(i));
        elseif segmentstotal.trelchgtendency(i) == "neutral"
           trelchgvalue(i) = 0;
        elseif segmentstotal.trelchgtendency(i) == "solo"
           trelchgvalue(i) = 0;
        end
    end
    segmentstotal.trelchgvalue=trelchgvalue;

% relational intensity

    % preallocation
    crelintensity=NaN(height(segmentstotal), 1);
    for i=1:height(segmentstotal)
        if segmentstotal.crelchgtendency(i) == "affirmative"
           crelintensity(i) = abs(segmentstotal.ctotalintensity(i));
        elseif segmentstotal.crelchgtendency(i) == "contradictive"
           crelintensity(i) = -abs(segmentstotal.ctotalintensity(i)); 
        elseif segmentstotal.crelchgtendency(i) == "neutral"
           crelintensity(i) = 0;
        elseif segmentstotal.crelchgtendency(i) == "solo"
           crelintensity(i) = 0;
        end
    end
    
    segmentstotal.crelintensity=crelintensity;
    
    trelintensity=NaN(height(segmentstotal), 1);
    for i=1:height(segmentstotal)
        if segmentstotal.trelchgtendency(i) == "affirmative"
           trelintensity(i) = abs(segmentstotal.ttotalintensity(i));
        elseif segmentstotal.trelchgtendency(i) == "contradictive"
           trelintensity(i) = -abs(segmentstotal.ttotalintensity(i)); 
        elseif segmentstotal.trelchgtendency(i) == "neutral"
           trelintensity(i) = 0;
        elseif segmentstotal.trelchgtendency(i) == "solo"
           trelintensity(i) = 0;
        end
    end
    
    segmentstotal.trelintensity=trelintensity;

% relational absolute intensity - absolute intensity sign changed to relation
    
    cabsrelintensity=NaN(height(segmentstotal), 1);
    for i=1:height(segmentstotal)
        if segmentstotal.crelchgtendency(i) == "affirmative"
           cabsrelintensity(i) = abs(segmentstotal.cabsintensity(i));
        elseif segmentstotal.crelchgtendency(i) == "contradictive"
           cabsrelintensity(i) = -abs(segmentstotal.cabsintensity(i)); 
        elseif segmentstotal.crelchgtendency(i) == "neutral"
           cabsrelintensity(i) = 0;
        elseif segmentstotal.crelchgtendency(i) == "solo"
           cabsrelintensity(i) = 0;
        end
    end
    segmentstotal.cabsrelintensity=cabsrelintensity;
    
    tabsrelintensity=NaN(height(segmentstotal), 1);
    for i=1:height(segmentstotal)
        if segmentstotal.trelchgtendency(i) == "affirmative"
           tabsrelintensity(i) = abs(segmentstotal.tabsintensity(i));
        elseif segmentstotal.trelchgtendency(i) == "contradictive"
           tabsrelintensity(i) = -abs(segmentstotal.tabsintensity(i)); 
       elseif segmentstotal.trelchgtendency(i) == "neutral"
           tabsrelintensity(i) = 0;
        elseif segmentstotal.trelchgtendency(i) == "solo"
           tabsrelintensity(i) = 0;
        end
    end
    segmentstotal.tabsrelintensity=tabsrelintensity;

% Add Time to next action (tonext)

    % calculate time to next action
    timediff=diff(segmentstotal.time);
    % time of last action
    lasttime=improdata.Time(data.endtotal)-segmentstotal.time(end);
    % add timeuntilnext to table
    segmentstotal.tonext=[timediff; lasttime];
    % add Time from last Action (fromlast)
    firsttime=segmentstotal.time(1)-improdata.Time(data.begintotal);
    segmentstotal.fromlast=[firsttime; timediff];

% featdelta, featdeltadifferences and percentages plus meandelta
% Differences (Delta) of Feature between players at indexes
    
    % calculation of featdelta as current difference between client and therapist value
    % extract values of client and therapist
    segmentstotal.featdelta = segmentstotal.cvalue-segmentstotal.tvalue;
    
    % calculate percentage of delta in relation to common total range of feature
    segmentstotal.featdeltapercent=segmentstotal.featdelta/rangetotal.(feat);
    
% Delta Tendencies between each index (absolute)
    % last inter(action) isn't followed by another action - therefore no
    % difference to the next
    for i=1:height(segmentstotal)-1
        segmentstotal.featdeltadifference(i)=segmentstotal.featdelta(i+1)-segmentstotal.featdelta(i);
    end

    % Delta Tendencies Percentage 
    
    % calculate percentage of delta tendencies in relation to common total range of feature
    segmentstotal.featdeltapercentdiff=segmentstotal.featdeltadifference/rangetotal.(feat);
    
% calculate mean delta value for current segment
    
    for h=1:(height(segmentstotal)-1) % loop from beginning until last segment
    
        begintime=segmentstotal.time(h);
        endtime=segmentstotal.time(h+1);
        between=(begintime < data.smoothed.Time) & (data.smoothed.Time < endtime); % extract time idxs between current and next interaction
        betweendata=diffdata.(strcat(feat, "Diff"))(between); % extract data between actions
        deltadata=[segmentstotal.featdelta(h); betweendata; segmentstotal.featdelta(h+1)]; % concatenate and calculate mean of data in between plus the single entries - slightly unprecise measure for crossings as they are calculated as if .1s duration
        featdeltamean(h)=mean(deltadata);
    
    end
    
    featdeltamean=featdeltamean';
    
    % add last value
    
        begintime=segmentstotal.time(end); % last time value is beginning
        endtime=data.smoothed.Time(find(~isnan(data.smoothed.Time), 1, "last")); % end is the end of the impro data (last non NaN entry)
        between=(begintime < data.smoothed.Time) & (data.smoothed.Time <= endtime); % extract time idxs util end
        betweendata=diffdata.(strcat(feat, "Diff"))(between); % extract data until end
        deltadata=[segmentstotal.featdelta(end); betweendata]; % concatenate beginning and remaining data
        featdeltamean(end+1)=mean(deltadata); % calculate mean of concatenated data
    
    segmentstotal.featdeltamean=featdeltamean;


% featdeltameanpercent
    segmentstotal.featdeltameanpercent=segmentstotal.featdeltamean/data.rangetotal.(feat);

%% show resulting table, sort and assign to new struct for features

feats.(feat)=segmentstotal(:, ["idx", "time", "segtype", "type", "actor", "fromother", "tonext", "cvalue", "cdirection", "cabsintensity", "ctotalintensity", "crelintensity", "crelchgtendency", "tvalue", "tdirection", "tabsintensity", "ttotalintensity", "trelintensity", "trelchgtendency","featdeltapercent", "featdeltapercentdiff", "featdeltameanpercent"]);

% clear variables for next loop
clearvars -except feature_names actor_names feats feat data segments mttbdata zerothresh segmentstotal improdata diffdata rangetotal ranges zerodetection

end

end