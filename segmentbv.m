function segmentsbv = segmentbv (data, smoothed, prominenceactivation, prominencevalue)

% segmentation with n=1 smoothed data, and n=0 raw data;
% 
% if m=0, sens(prominence) is 0 and if m=1 sens is std Inititiate Data
% Analysis, if m = 2, manual sens is applied
% via MTTB, mttb_light("filename", step, window)

%% Switch Case for Prominence Activation

switch prominenceactivation % define switch case if prominence(sensitivity) values should be linked to .1 of std

    case 0
        sens(1:26)=0;

    case 1 % prominence values are manually set

        ac=prominencevalue;
        art=prominencevalue;
        dens=prominencevalue;
        diss=prominencevalue;
        dur=prominencevalue;
        major=prominencevalue;
        meanp=prominencevalue;
        meanv=prominencevalue;
        minor=prominencevalue;
        stdpitch=prominencevalue;
        tempo=prominencevalue;
        tonality=prominencevalue;

        sens = [0, 0, ac, ac, art, art, dens, dens, diss, diss, dur, dur, major, major, meanp, meanp, meanv, meanv, minor, minor, stdpitch, stdpitch, tempo, tempo, tonality, tonality];

    case 2 % prominence values are connected to value of standard deviation multiplied with a weighting (at this moment 1, so direct std)
        stdsens=[0, 0, table2array(data.std)];
        % individual Feature Weights connceted to std
        ac=1;
        art=1;
        dens=1;
        diss=1;
        dur=1;
        major=1;
        meanp=1;
        meanv=1;
        minor=1;
        stdpitch=1;
        tempo=1;
        tonality=1;
        
        weights=[0, 0, ac, ac, art, art, dens, dens, diss, diss, dur, dur, major, major, meanp, meanp, meanv, meanv, minor, minor, stdpitch, stdpitch, tempo, tempo, tonality, tonality];
        sens=stdsens.*weights;

end

%% Switch Case for Segmentation along Raw or Smoothed Data

switch smoothed

% Segmentation along last local Maxima and Minima with flexible Prominence Values along Raw Data

    case 1 
        % initiate for loop (3 as first musical feature until end)
        for i=3:26 % MeanVelocityC
                % Find local maxima and minima of feature i, Prominence adjustable, center selection, mapped onto Time coordinates
            maxIndices = find(islocalmax(data.impro.(i),"MinProminence",sens(i),"FlatSelection","last", ...
                "SamplePoints",data.impro.Time));
            minIndices = find(islocalmin(data.impro.(i),"MinProminence",sens(i),"FlatSelection","last", ...
                "SamplePoints",data.impro.Time));
                
            %% indices for beginnings/ends of each player/feature

            beginidx=[];

            counter=1; % identify beginnings
            for n=1:(height(data.impro.(i)))-1
                if isnan(data.impro.(i)(n)) & ~isnan(data.impro.(i)(n+1))
                beginidx(counter)=n+1;
                counter=counter+1;
                end
            end

            if isempty(beginidx)
                beginidx=1;
            end
            
            %% Identify Ends
            endidx=[];

            counter=1; % identify ends
            for n=2:(height(data.impro.(i)))
                if isnan(data.impro.(i)(n)) & ~isnan(data.impro.(i)(n-1))
                endidx(counter)=n-1;
                counter=counter+1;
                end
            end

            if isempty(endidx)
                endidx=height(data.impro.(i));
            end
            
            %% 
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

            %% check for doubles of beginnings and ends to max/mins

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

            %% Direction
            % assign NaN value to ends as there is no further movement
            % direction
            endtbl.direction(:)=NaN;
            segments=sortrows([maxmins; begintbl], 1, "ascend"); % concatenate and sort segments with direction needed         
            segments.direction(:)=0; % add column of zeros to begins for concatenation
            total=sortrows([segments; endtbl], 1, "ascend"); % concatenate begins and ends for direction calculation
 
            %% directions of maxima/minima and begins 
            counter=1;
            for v=1:(height(total))-1
                if ~isnan(total.direction(v))
                    if data.smoothed.(i)(total.idx(v+1)) - data.smoothed.(i)(total.idx(v)) > 0
                        total.direction(v)=1;
                        counter=counter+1;
                    elseif data.smoothed.(i)(total.idx(v+1)) - data.smoothed.(i)(total.idx(v)) < 0
                        total.direction(v)=-1;
                        counter=counter+1;
                    elseif data.smoothed.(i)(total.idx(v+1)) - data.smoothed.(i)(total.idx(v)) == 0
                        total.direction(v)=0;
                        counter=counter+1;
                    end
                end
            end
            
            %% analyse slope of last segment
            last =  find(~isnan(data.smoothed.(i)), 1, "last" ); % find last non NaN Entry
            slope = data.smoothed.(i)(last) - data.smoothed.(i)(total.idx(end));
            if slope < 0
                total.direction(end) = -1;
            elseif slope > 0
                total.direction(end) = 1;
            elseif slope == 0 
                total.direction(end) = 0;
            end
           
            %% assign results to struct
            segmentsbv.total.(data.smoothed.Properties.VariableNames{i})=total.idx;
            segmentsbv.direction.(data.smoothed.Properties.VariableNames{i})=total.direction;
            segmentsbv.type.(data.smoothed.Properties.VariableNames{i})=total.type;
            
            clearvars -except data n m segmentsbv sens

        end


% Segmentation along centered local Maxima and Minima with flexible Prominence Values along Smoothed Data


    case 2 
        % initiate for loop (3 as first musical feature until end)
        for i=3:26 % MeanVelocityC
                % Find local maxima and minima of feature i, Prominence adjustable, center selection, mapped onto Time coordinates
            maxIndices_first = find(islocalmax(data.smoothed.(i),"MinProminence",sens(i),"FlatSelection","first", ...
                "SamplePoints",data.impro.Time));
            maxIndices_last = find(islocalmax(data.smoothed.(i),"MinProminence",sens(i),"FlatSelection","last", ...
                "SamplePoints",data.impro.Time));

            maxIndices = sort(unique([maxIndices_first; maxIndices_last]));

            minIndices_first = find(islocalmin(data.smoothed.(i),"MinProminence",sens(i),"FlatSelection","first", ...
                "SamplePoints",data.impro.Time));
            minIndices_last = find(islocalmin(data.smoothed.(i),"MinProminence",sens(i),"FlatSelection","last", ...
                "SamplePoints",data.impro.Time));

            minIndices = sort(unique([minIndices_first; minIndices_last]));
                
            % indices for beginnings/ends of each player/feature

            beginidx=[];

            counter=1; % identify beginnings
            for n=1:(height(data.impro.(i)))-1
                if isnan(data.impro.(i)(n)) & ~isnan(data.impro.(i)(n+1))
                beginidx(counter)=n+1;
                counter=counter+1;
                end
            end

            if isempty(beginidx)
                beginidx=1;
            end

            endidx=[];

            counter=1; % identify ends
            for n=2:(height(data.impro.(i)))
                if isnan(data.impro.(i)(n)) & ~isnan(data.impro.(i)(n-1))
                endidx(counter)=n-1;
                counter=counter+1;
                end
            end

            if isempty(endidx)
                endidx=height(data.impro.(i));
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
            total=sortrows([segments; endtbl], 1, "ascend"); % concatenate begins and ends for direction calculation
 
            % directions of maxima/minima and begins 
            counter=1;
            for v=1:(height(total))-1
                if ~isnan(total.direction(v))
                    if data.smoothed.(i)(total.idx(v+1)) - data.smoothed.(i)(total.idx(v)) > 0
                        total.direction(v)=1;
                        counter=counter+1;
                    elseif data.smoothed.(i)(total.idx(v+1)) - data.smoothed.(i)(total.idx(v)) < 0
                        total.direction(v)=-1;
                        counter=counter+1;
                    elseif data.smoothed.(i)(total.idx(v+1)) - data.smoothed.(i)(total.idx(v)) == 0
                        total.direction(v)=0;
                        counter=counter+1;
                    end
                end
            end
            
            % analyse slope of last segment
            last =  find(~isnan(data.smoothed.(i)), 1, "last" ); % find last non NaN Entry
            slope = data.smoothed.(i)(last) - data.smoothed.(i)(total.idx(end));
            if slope < 0
                total.direction(end) = -1;
            elseif slope > 0
                total.direction(end) = 1;
            elseif slope == 0 
                total.direction(end) = 0;
            end
           
            % assign results to struct
            segmentsbv.total.(data.smoothed.Properties.VariableNames{i})=total.idx;
            segmentsbv.direction.(data.smoothed.Properties.VariableNames{i})=total.direction;
            segmentsbv.type.(data.smoothed.Properties.VariableNames{i})=total.type;
            
            clearvars -except data n m segmentsbv sens

        end

end
end