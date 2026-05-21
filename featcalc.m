function feats = featcalc(data, smoothed, segments, zerodetection, zerothresh)
 
% calculates several features for each segment, needs preprocessed data and segments, provided by segmentsol or segmentsbv plus crossings as points of recontextualisation
% manual zerodetection entry (1=on, 0=off)

%% Crossing calculation

crossings=crossingcalc(data, smoothed);

%% Switch Case whether to Calculate on Original/Raw or Smoothed Data

switch smoothed
       case 0 % raw data
            improdata=data.impro;
            diffdata=data.improdiff;
            rangetotal=data.rangetotal;
            ranges=data.range;
        case 1 % smoothed data
            improdata=data.smoothed;
            diffdata=data.smootheddiff;
            rangetotal=data.rangetotalsmoothed;
            ranges=data.rangesmoothed;
end

%% Initiate Feature Loop for all Features

fieldname=fieldnames(segments.direction);
fielddiffname=fieldnames(diffdata);
varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

% looping in 1 steps until 12 for fielddiffname and varname, loop is integrated 
% looping in 2 steps until 23 for features (always client and therapist next to each other)
% y added by +1 to change indication from client to therapist

for y=1:2:23 % 15
z=(y+1)/2; % varname indicator

% Create actor vectors and action type vectors

%indexes, assign agent to action, create name variables 
clear client therapist
client(1:height(segments.total.(fieldname{y})), 1)="C";
actionc(1:height(segments.total.(fieldname{y})), 1)="act";
therapist(1:height(segments.total.(fieldname{y+1})), 1)="T";
actiont(1:height(segments.total.(fieldname{y+1})), 1)="act";
cross(1:width(crossings.(varnames(z))), 1)="crossing";

%% Single Actor Calculations

% Client 

%toown  
    % transform action idx, times and actor to table
    timesc=improdata.Time(segments.total.(fieldname{y}));
    segmentsc=table(segments.total.(fieldname{y}), segments.type.(fieldname{y}), timesc , client, actionc, VariableNames=["idx", "segtype", "time", "actor", "type"]);
    % calculate differences between own actions plus time until last action ends
    segmentscdiff=table([diff(improdata.Time(segmentsc.idx)); improdata.Time(data.endC)-improdata.Time(segmentsc.idx(end))]);
    % calculate both into a table
    segmentsc=[segmentsc, segmentscdiff];
    
    % rename Var1 to own time
    segmentsc=renamevars(segmentsc, "Var1", "ctoown");
    
    % add values at segments
    segmentsc.cvalue=improdata.(fieldname{y})(segmentsc.idx);

% fromown
    % preallocation
    fromown=zeros(height(segmentsc), 1);
    fromown(1)=NaN;
    for i=2:height(segmentsc)
        fromown(i)=improdata.Time(segmentsc.idx(i))-improdata.Time(segmentsc.idx(i-1));
    end
    segmentsc.cfromown=fromown;

% Direction
    % calculated directly in segmentation
    segmentsc.cdirection=segments.direction.(fieldname{y});

% abschgvalue (Absolute Change Value)
    % preallocation
    cabschgval=NaN(height(segmentsc)-1,1);
    % differences between next and current entry (difference to next), positive
    % = ascending curve, negative = descending curve
    for i=1:(height(segmentsc)-1)
        if ~isnan(segmentsc.cdirection(i)) % if no ending
        cabschgval(i)=segmentsc.cvalue(i+1)-segmentsc.cvalue(i);
        elseif isnan(segmentsc.cdirection(i))
        cabschgval(i)=NaN;
        end
    end
    cabschgval=[cabschgval; improdata.(fieldname{y})(data.endC)-segmentsc.cvalue(end)];
    % assign abschgvalue to table
    segmentsc.cabschgvalue=cabschgval;

% chngfactor
    % preallocation
    changevaluesc=zeros(height(segmentsc)-1, 1);
    for i=1:(height(segmentsc)-1)
        if ~isnan(segmentsc.cdirection(i)) % if no ending
        changevaluesc(i)=segmentsc.cvalue(i+1)/segmentsc.cvalue(i);
        elseif isnan(segmentsc.cdirection(i))
        changevaluesc(i)=NaN;
        end
    end
    changevaluesc=[changevaluesc; improdata.(fieldname{y})(data.endC)/segmentsc.cvalue(end)];
    % assign changevalues to table
    segmentsc.cchngfactor=changevaluesc;

% rangepercent, totalrangepercent
    % percentage of change compared to total range
    segmentsc.crangepercent=segmentsc.cabschgvalue/ranges.(fieldname{y});
    segmentsc.ctotalrangepercent=segmentsc.cabschgvalue/rangetotal.(z);

% indivintensity, totalintensity, absintensity
    % calculate rangepercent vs. time - intensity value. change in percentage of
    % range per second
    segmentsc.cindivintensity=segmentsc.crangepercent./segmentsc.ctoown;
    segmentsc.ctotalintensity=segmentsc.ctotalrangepercent./segmentsc.ctoown;
    segmentsc.cabsintensity=segmentsc.cabschgvalue./segmentsc.ctoown;
    % zerothresh direction
    
    % zero Direction calculation as in/decrease smaller than 0.01 intensity (1 positive, -1 negative, 0 neutral)
    % segmentsc.direction(segmentsc.intensity > -0.01 & segmentsc.intensity < 0.01) = 0;
    switch zerodetection % only assign zero if the original value is not NaN, so that ends aren't reinterpreted
        case 1
            segmentsc.cdirection(abs(segmentsc.cindivintensity) < zerothresh & ~isnan(segmentsc.cdirection))=0;
    end


% Therapist

% toown
    timest=improdata.Time(segments.total.(fieldname{y+1}));
    segmentst=table(segments.total.(fieldname{y+1}), segments.type.(fieldname{y+1}), timest, therapist, actiont, VariableNames=["idx", "segtype", "time", "actor", "type"]);
    segmentstdiff=table([diff(improdata.Time(segmentst.idx)); improdata.Time(data.endT)-improdata.Time(segmentst.idx(end))]);
    segmentst=[segmentst, segmentstdiff];
    segmentst=renamevars(segmentst, "Var1", "ttoown");
    segmentst.tvalue=improdata.(fieldname{y+1})(segmentst.idx);

% fromown
    fromown=zeros(height(segmentst), 1);
    fromown(1)=NaN;
    for i=2:height(segmentst)
        fromown(i)=improdata.Time(segmentst.idx(i))-improdata.Time(segmentst.idx(i-1));
    end
    segmentst.tfromown=fromown;

% Direction
    % computed in segmentation functions
    segmentst.tdirection=segments.direction.(fieldname{y+1});

% abschgvalue
    % preallocation
    abschgvalt=NaN(height(segmentst)-1,1);
    % differences between next and current entry (difference to next), positive
    % = ascending curve, negative = descending curve
    for i=1:(height(segmentst)-1)
        if ~isnan(segmentst.tdirection(i)) % if no ending
        abschgvalt(i)=segmentst.tvalue(i+1)-segmentst.tvalue(i);
        elseif isnan(segmentst.tdirection(i))
        abschgvalt(i)=NaN;
        end
    end
    abschgvalt=[abschgvalt; improdata.(fieldname{y+1})(data.endT)-segmentst.tvalue(end)];
    % assign abschgvalue to table
    segmentst.tabschgvalue=abschgvalt;

% chngfactor
    changevaluest=zeros(height(segmentst)-1, 1);
    for i=1:(height(segmentst)-1)
        if ~isnan(segmentst.tdirection(i)) % if no ending
        changevaluest(i)=segmentst.tvalue(i+1)/segmentst.tvalue(i);
        elseif isnan(segmentst.tdirection(i))
        changevaluest(i)=NaN;
        end
    end
    changevaluest=[changevaluest; improdata.(fieldname{y+1})(data.endT)/segmentst.tvalue(end)];
    
    segmentst.tchngfactor=changevaluest;

% rangepercent/totalrangepercent
    % percentage of change compared to total range
    segmentst.trangepercent=segmentst.tabschgvalue/ranges.(fieldname{y+1});
    segmentst.ttotalrangepercent=segmentst.tabschgvalue/rangetotal.(z);

% indidintensity, totalintensity, absintensity
    % calculate rangepercent vs. time - intensity value. change in percentage of
    % range per second
    segmentst.tindivintensity=segmentst.trangepercent./segmentst.ttoown;
    segmentst.ttotalintensity=segmentst.ttotalrangepercent./segmentst.ttoown;
    segmentst.tabsintensity=segmentst.tabschgvalue./segmentst.ttoown;

    % zerothresh direction
    % zero Direction calculation as in/decrease smaller than 0.01 intensity (1 positive, -1 negative, 0 neutral)
    % segmentst.direction(segmentst.intensity > -0.01 & segmentst.intensity < 0.01) = 0;
    
    switch zerodetection
        case 1
            segmentst.tdirection(abs(segmentst.tindivintensity) < zerothresh & ~isnan(segmentst.tdirection))=0;
    end

%% Concatenation of Therapist and Client tables

tblwidth=width(segmentsc);

% prepare ctable for concatenation
tblsegmentsc=[segmentsc, array2table(NaN(height(segmentsc), tblwidth-5))];

segmentwidth=width(tblsegmentsc);

tblsegmentsc.Properties.VariableNames(tblwidth+1:segmentwidth)=segmentst.Properties.VariableNames(6:16);

% prepare ttable for concatenation
tblsegmentst=[segmentst, array2table(NaN(height(segmentst), tblwidth-5))];
tblsegmentst.Properties.VariableNames(tblwidth+1:segmentwidth)=segmentsc.Properties.VariableNames(6:16);

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
crossingsarray=crossings.(varnames(z))';
empty=NaN(height(crossingsarray), 1);

crossarray4tbl=[empty, empty, crossingsarray(:, 1), empty, empty, empty, crossingsarray(:, 2), NaN(height(crossingsarray), (segmentwidth-6))];

crosstable=array2table(crossarray4tbl, "VariableNames", segmentsct.Properties.VariableNames);
crosstable.type=cross;

% concatenate and sort both into single table
segmentstotal=sortrows([segmentsct; crosstable], "time", "ascend");
% Relational Change Values for client and therapist(positive for affirmative, negative for contradictive)

%% Combined Actor Calculations

% Fill movement information (doubles)

% fill crossing information for therapist
segmentstotal.tvalue(segmentstotal.type=="crossing")=segmentstotal.cvalue(segmentstotal.type=="crossing");

    % client side
    segmentstotal.cvalue(segmentstotal.actor=="T")=improdata.(fieldname{y})(segmentstotal.idx(segmentstotal.actor=="T"));
    
    for f=9:16 % double values for client movement information
        for i=2:height(segmentstotal)
           if isnan(segmentstotal.(f)(i)) & ~isnan(segmentstotal.cvalue(i)) & ~(segmentstotal.actor(i)=="C" & isnan(segmentstotal.cdirection(i))) % if current entry is empty, but theres a value and current entry is no end of play
               segmentstotal.(f)(i)=segmentstotal.(f)(i-1);
          end
       end
    end
    
    % therapist side
    segmentstotal.tvalue(segmentstotal.actor=="C")=improdata.(fieldname{y+1})(segmentstotal.idx(segmentstotal.actor=="C"));
    
    for f=20:27 % double values for therapist movement information
        for i=2:height(segmentstotal)
           if isnan(segmentstotal.(f)(i)) & ~isnan(segmentstotal.tvalue(i)) & ~(segmentstotal.actor(i)=="T" & isnan(segmentstotal.tdirection(i))) % if current entry is empty, but theres a value and current entry is no end of play
               segmentstotal.(f)(i)=segmentstotal.(f)(i-1);
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
    segmentstotal.featdeltapercent=segmentstotal.featdelta/rangetotal.(z);
    
% Delta Tendencies between each index (absolute)
    % last inter(action) isn't followed by another action - therefore no
    % difference to the next
    for i=1:height(segmentstotal)-1
        segmentstotal.featdeltadifference(i)=segmentstotal.featdelta(i+1)-segmentstotal.featdelta(i);
    end

    % Delta Tendencies Percentage 
    
    % calculate percentage of delta tendencies in relation to common total range of feature
    segmentstotal.featdeltapercentdiff=segmentstotal.featdeltadifference/rangetotal.(z);
    
% calculate mean delta value for current segment
    
    for h=1:(height(segmentstotal)-1) % loop from beginning until last segment
    
        begintime=segmentstotal.time(h);
        endtime=segmentstotal.time(h+1);
        between=(begintime < data.smoothed.Time) & (data.smoothed.Time < endtime); % extract time idxs between current and next interaction
        betweendata=diffdata.(z)(between); % extract data between actions
        deltadata=[segmentstotal.featdelta(h); betweendata; segmentstotal.featdelta(h+1)]; % concatenate and calculate mean of data in between plus the single entries - slightly unprecise measure for crossings as they are calculated as if .1s duration
        featdeltamean(h)=mean(deltadata);
    
    end
    
    featdeltamean=featdeltamean';
    
    % add last value
    
        begintime=segmentstotal.time(end); % last time value is beginning
        endtime=data.smoothed.Time(find(~isnan(data.smoothed.Time), 1, "last")); % end is the end of the impro data (last non NaN entry)
        between=(begintime < data.smoothed.Time) & (data.smoothed.Time <= endtime); % extract time idxs util end
        betweendata=diffdata.(z)(between); % extract data until end
        deltadata=[segmentstotal.featdelta(end); betweendata]; % concatenate beginning and remaining data
        featdeltamean(end+1)=mean(deltadata); % calculate mean of concatenated data
    
    segmentstotal.featdeltamean=featdeltamean;


% featdeltameanpercent
    segmentstotal.featdeltameanpercent=segmentstotal.featdeltamean/data.rangetotal.(z);

%% show resulting table, sort and assign to new struct for features

feats.(varnames(z))=segmentstotal(:, ["idx", "time", "segtype", "type", "actor", "fromother", "tonext", "cvalue", "cdirection", "cabsintensity", "ctotalintensity", "crelintensity", "crelchgtendency", "tvalue", "tdirection", "tabsintensity", "ttotalintensity", "trelintensity", "trelchgtendency","featdeltapercent", "featdeltapercentdiff", "featdeltameanpercent"]);

% increase z-value for next feature loop 
z=z+1;
% clear variables for next loop
clearvars -except z feats counter varnames data fielddiffname fieldname segments mttbdata y crossings zerothresh segmentstotal improdata diffdata rangetotal ranges zerodetection

end
end