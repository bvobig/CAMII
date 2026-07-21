function extrema_table = get_extrema(data)
%retrieves extrema (FlatSelection first and last) and beginning/end
%segments based on smoothed data

    maxIndices_first = find(islocalmax(data,"FlatSelection","first"));
    maxIndices_last = find(islocalmax(data,"FlatSelection","last"));
    maxIndices = sort(unique([maxIndices_first; maxIndices_last]));
    minIndices_first = find(islocalmin(data,"FlatSelection","first"));
    minIndices_last = find(islocalmin(data,"FlatSelection","last"));
    minIndices = sort(unique([minIndices_first; minIndices_last]));

% indices for beginnings/ends of each player/feature
    isnanData = isnan(data);
if all(isnanData)
    warning('camii:get_extrema:SoloImprovisation', ...
        'Feature is entirely NaN (actor never plays it) -- begin/end will default to the full series bounds.')
end
    beginidx = (find(isnanData(1:end-1) & ~isnanData(2:end)) + 1)'; % identify beginnings
if isempty(beginidx)
            beginidx=1;
end
    endidx = (find(~isnanData(1:end-1) & isnanData(2:end)))'; % identify ends
if isempty(endidx)
            endidx=height(data);
end

% create string arrays
    minstr(1:height(minIndices))="min";
    maxstr(1:height(maxIndices))="max";
    beginstr(1:length(beginidx))="begin";
    endstr(1:length(endidx))="end";

% create tables
    tblvarnames=["idx" "type"];
        mintbl=table(minIndices, minstr', VariableNames=tblvarnames);
        maxtbl=table(maxIndices, maxstr', VariableNames=tblvarnames);
        begintbl=table(beginidx', beginstr', VariableNames=tblvarnames);
        endtbl=table(endidx', endstr', VariableNames=tblvarnames);

% check for doubles of beginnings and ends to max/mins
% concatenate maxima and minima
    maxmins=[maxtbl; mintbl];

% erase endidx from maxmins
    maxminend=intersect(maxmins.idx, endidx);
if ~isempty(maxminend)
        maxmins=maxmins(~ismember(maxmins.idx, maxminend), :);
end

% erase beginindx from maxmins
    maxminbegin=intersect(maxmins.idx, beginidx);
if ~isempty(maxminbegin)
        maxmins=maxmins(~ismember(maxmins.idx, maxminbegin), :);
end
% assign NaN value to ends as there is no further movement

% direction
    endtbl.direction(:)=NaN;
    segments=sortrows([maxmins; begintbl], 1, "ascend"); % concatenate and sort segments with direction needed
    segments.direction(:)=0; % add column of zeros to begins for concatenation
    extrema_table=sortrows([segments; endtbl], 1, "ascend"); % concatenate begins and ends for direction calculation

% directions of maxima/minima and begins
    notEndMask = ~isnan(extrema_table.direction(1:end-1));
    stepDirection = sign(data(extrema_table.idx(2:end)) - data(extrema_table.idx(1:end-1)));
    extrema_table.direction(notEndMask) = stepDirection(notEndMask);

% analyse slope of last segment
    last =  find(~isnan(data), 1, "last" ); % find last non NaN Entry
if ~isempty(last) % guard against the all-NaN case: "last" empty means no slope to analyse, leave direction(end) as-is (NaN, from endtbl)
        slope = data(last) - data(extrema_table.idx(end));
        extrema_table.direction(end) = sign(slope); % sign(x): 1 if x>0, -1 if x<0, 0 if x==0, NaN if x is NaN
end
end