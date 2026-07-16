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

    beginidx=[];

    counter=1; % identify beginnings
        for n=1:(height(data))-1
            if isnan(data(n)) & ~isnan(data(n+1))
            beginidx(counter)=n+1;
            counter=counter+1;
            end
        end
    
        if isempty(beginidx)
            beginidx=1;
        end

    endidx=[];

    counter=1; % identify ends
        for n=2:(height(data))
            if isnan(data(n)) & ~isnan(data(n-1))
            endidx(counter)=n-1;
            counter=counter+1;
            end
        end

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
    
    counter=1;
    for v=1:(height(extrema_table))-1
        if ~isnan(extrema_table.direction(v))
            if data(extrema_table.idx(v+1)) - data(extrema_table.idx(v)) > 0
                extrema_table.direction(v)=1;
                counter=counter+1;
            elseif data(extrema_table.idx(v+1)) - data(extrema_table.idx(v)) < 0
                extrema_table.direction(v)=-1;
                counter=counter+1;
            elseif data(extrema_table.idx(v+1)) - data(extrema_table.idx(v)) == 0
                extrema_table.direction(v)=0;
                counter=counter+1;
            end
        end
    end
    
% analyse slope of last segment

    last =  find(~isnan(data), 1, "last" ); % find last non NaN Entry
    slope = data(last) - data(extrema_table.idx(end));
    if slope < 0
        extrema_table.direction(end) = -1;
    elseif slope > 0
        extrema_table.direction(end) = 1;
    elseif slope == 0 
        extrema_table.direction(end) = 0;
    end
end