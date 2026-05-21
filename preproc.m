function preprocdata = preproc (mttbdata, smoothmethod)

% PREPROC creates 4 datasets for original, smoothed and shortened alternatives. Further gives out statistical values for each feature and beginning/ends of play

%% Restructuring

% erase non-graph elements and reassign to impro
impro=rmfield(mttbdata, ["sil1", "sil2"]);
% transform struct into table
impro=struct2table(impro);
% rearrange variables so that Client and Therapist are next to each other (also erase sync and synctempo)
impro=impro(:, ["t_end", "t_start", "ac1", "ac2", "art1", "art2", "dens1", "dens2", "dis1", "dis2", "dur1", "dur2", "maj1", "maj2", "meanp1", "meanp2", "meanv1", "meanv2", "min1", "min2", "stdp1", "stdp2", "tempo1", "tempo2", "ton1", "ton2"]);
% feature names for assignment
featnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
% rename variables for clear identification
varnames=["Time", "Time_End", "Time_Start", "ACC", "ACT", "ArticulationC", "ArticulationT", "DensityC", "DensityT", "DissonanceC", "DissonanceT", "DurationC", "DurationT", "MajornessC", "MajornessT", "MeanPitchC", "MeanPitchT", "MeanVelocityC", "MeanVelocityT", "MinornessC", "MinornessT", "StandardPitchDeviationC", "StandardPitchDeviationT", "TempoC", "TempoT", "TonalityC", "TonalityT"];
impro=renamevars(impro, 1:width(impro), varnames(2:end));

%% Time Indexing
% calculate new "Time" indicator as median between Frame Begin and Frame End
impro.Time=(impro.Time_End+impro.Time_Start)/2;
impro=movevars(impro, "Time", "Before", "Time_End");
% Exclude Time_End from Calculation
impro=impro(:, [1, 3:end]);
% shorten impro table to only include impro.Time >= 0, Oliviers t_mean
impro=impro(impro.Time>=0, :);

% update varnames as there is no _Start or _End anymore
varnames=varnames([1, 3:end]);

%% Shortening Alternative
% Isolate Shortened Data (from Begin to End of Play)
% concatenate density variables as indicators for play
beginning=[impro.DensityC, impro.DensityT];
% replace NaN by Zero for find function
idxnan=isnan(beginning);
beginning(idxnan)=0;
% calculate minimum of beginning indexes for total begin
beginclient=find(beginning(:, 1), 1, "first");
begintherapist=find(beginning(:, 2), 1, "first");
beginidx=min(beginclient, begintherapist);
% calculate minimum of ending indexes for total end
endclient=find(beginning(:, 1), 1, "last");
endtherapist=find(beginning(:, 2), 1, "last");
endidx=max(endclient, endtherapist);

% cut improvisation data at begin and end of total play
improshort=impro(beginidx:endidx, :);

%% Data Smoothing
% create new table for smoothed Data with moving mean of 20ms, each for normal and short

switch smoothmethod
    case 1 % uniform smoothing by 20frame movmean
        smoothimpro=smoothdata(impro(:, 3:end),"movmean",20);
        smoothimproshort=smoothdata(improshort(:, 3:end), "movmean",20);
    case 2 % individual smoothing by Smoothingfactor = 0.1
        smoothimpro=smoothdata(impro(:, 3:end),"movmean",SmoothingFactor=0.1);
        smoothimproshort=smoothdata(improshort(:, 3:end), "movmean",SmoothingFactor=0.1);
end

%% NaN Correction
% Insert original impro NaN Values in smoothimpro and smoothimproshort
% Convert Variable names for input to array2table
varnameschar=convertStringsToChars(varnames);

% for normal impro
    % Change data type of impro and smoothimpro table for isnan calculation
    improarray=table2array(impro);
    smoothimproarray=table2array(smoothimpro);
    % identify original NaN values in impro Table, excluding time
    nanidx=isnan(improarray(:, 3:end));
    % Assign original NaN values to relevant spaces in smoothimpro
    smoothimproarray(nanidx)=NaN;
    % concatenate original time values with smoothed and adapted data
    smoothimproarray=[impro.Time, impro.Time_Start, smoothimproarray];
    % Create new table with adjusted data and original variable names
    smoothimpro=array2table(smoothimproarray, VariableNames=varnameschar);

% for short impro
    % Change data type of impro and smoothimpro table for isnan calculation
    improshortarray=table2array(improshort);
    smoothimproshortarray=table2array(smoothimproshort);
    % identify original NaN values in impro Table, excluding time
    nanidxshort=isnan(improshortarray(:, 3:end));
    % Assign original NaN values to relevant spaces in smoothimpro
    smoothimproshortarray(nanidxshort)=NaN;
    % concatenate original time values with smoothed and adapted data
    smoothimproshortarray=[improshort.Time, improshort.Time_Start, smoothimproshortarray];
    % Create new table with adjusted data and original variable names
    smoothimproshort=array2table(smoothimproshortarray, VariableNames=varnameschar);

%% Individual Statistics
% Calculate Individual Statistical Data for each Feature
% Range 
    % calculate and rename range
    improranges=range(impro(:, 3:end));
    improranges=renamevars(improranges, 1:24, (varnames(3:end)));
    % smoothed
    improrangessmooth=range(smoothimpro(:, 3:end));
    improrangessmooth=renamevars(improrangessmooth, 1:24, (varnames(3:end)));

% Mean 
    % calculate and rename mean
    impromeans=mean(impro(:, 3:end), "omitmissing");
    impromeans=renamevars(impromeans, 1:24, (varnames(3:end)));
    % smoothed
    impromeanssmoothed=mean(smoothimpro(:, 3:end), "omitmissing");
    impromeanssmoothed=renamevars(impromeanssmoothed, 1:24, (varnames(3:end)));

% Median
    % calculate and rename median
    impromedian=median(impro(:, 3:end), "omitmissing");
    impromedian=renamevars(impromedian, 1:24, (varnames(3:end)));
    % smoothed
    impromediansmoothed=median(smoothimpro(:, 3:end), "omitmissing");
    impromediansmoothed=renamevars(impromediansmoothed, 1:24, (varnames(3:end)));

% Standard Deviation
    % calculate and rename std, w in this case is 1 because all values are
    % present, set to 0 for estimation of mean by n-1 to compensate for using
    % estimated values as in a sample set
    improstd=std(impro(:, 3:end), 1, "omitmissing");
    improstd=renamevars(improstd, 1:24, (varnames(3:end)));
    % smoothed
    improstdsmoothed=std(smoothimpro(:, 3:end), 1, "omitmissing");
    improstdsmoothed=renamevars(improstdsmoothed, 1:24, (varnames(3:end)));

%% Difference Calculation
% Calculate FeatDelta between Players (forward)
% calculate difference between the two players for original data
% client minus therapist (positive values mean client is above therapist, negative values mean client is below therapist)

% create vector for FeatDelta Names
diffvars=["ACDiff", "ArticulationDiff", "DensityDiff", "DissonanceDiff", "DurationDiff", "MajornessDiff", "MeanPitchDiff", "MeanVelocityDiff", "MinornessDiff", "StandardPitchDeviationDiff", "TempoDiff", "TonalityDiff"];

% Raw Impro Data
% preallocation
difference=zeros(height(impro), 1);
difftable=table;

count=1;

for i=3:2:width(impro)
    for n=1:height(impro)
        difference(n)=impro.(i)(n)-impro.(i+1)(n);
    end
    difftable.(diffvars(count))=difference;
    count=count+1;
end

% Smoothed Data
% preallocation
differencesmooth=zeros(height(impro), 1);
count=1;
difftablesmooth=table;

for i=3:2:width(smoothimpro)
    for n=1:height(smoothimpro)
        differencesmooth(n)=smoothimpro.(i)(n)-smoothimpro.(i+1)(n);
    end
    difftablesmooth.(diffvars(count))=differencesmooth;
    count=count+1;
end

%% Common Statistics
% Calculate Common Feature Statistics
% Range
    % Raw Data
    % preallocate
    rangetotalpre=zeros(1, 12);
    count=1;
    for y=3:2:25
        rangetotalpre(count)=range([impro.(y);impro.(y+1)]);
        count=count+1;
    end
    % tranform data into table
    rangetotal=array2table(rangetotalpre, VariableNames=featnames);

    % Smoothed Data
    rangetotalpresmoothed=zeros(1, 12);
    count=1;
    for y=3:2:25
        rangetotalpresmoothed(count)=range([smoothimpro.(y);smoothimpro.(y+1)]);
        count=count+1;
    end
    % tranform data into table
    rangetotalsmoothed=array2table(rangetotalpresmoothed, VariableNames=featnames);

% Mean
    % Raw Data
    % preallocate
    meantotalpre=zeros(1, 12);
    count=1;
    for y=3:2:25
        meantotalpre(count)=mean([impro.(y);impro.(y+1)], "omitmissing");
        count=count+1;
    end
    % tranform data into table
    meantotal=array2table(meantotalpre, VariableNames=featnames);
    
    % Smoothed Data
    % preallocate
    meantotalpresmoothed=zeros(1, 12);
    count=1;
    for y=3:2:25
        meantotalpresmoothed(count)=mean([smoothimpro.(y);smoothimpro.(y+1)], "omitmissing");
        count=count+1;
    end
    % tranform data into table
    meantotalsmoothed=array2table(meantotalpresmoothed, VariableNames=featnames);

% Median
    % Raw Data
    % preallocate
    mediantotalpre=zeros(1, 12);
    count=1;
    for y=3:2:25
        mediantotalpre(count)=median([impro.(y);impro.(y+1)], "omitmissing");
        count=count+1;
    end
    % tranform data into table
    mediantotal=array2table(mediantotalpre, VariableNames=featnames);
    
    % Smoothed Data
    % preallocate
    mediantotalpresmoothed=zeros(1, 12);
    count=1;
    for y=3:2:25
        mediantotalpresmoothed(count)=median([smoothimpro.(y);smoothimpro.(y+1)], "omitmissing");
        count=count+1;
    end
    % tranform data into table
    mediantotalsmoothed=array2table(mediantotalpresmoothed, VariableNames=featnames);

% Standard Deviation
    % Raw Data
    % preallocate
    stdtotalpre=zeros(1, 12);
    count=1;
    for y=3:2:25
        stdtotalpre(count)=std([impro.(y);impro.(y+1)], 1);
        count=count+1;
    end
    % tranform data into table
    stdtotal=array2table(stdtotalpre, VariableNames=featnames);
    
    % Smoothed Data
    % preallocate
    stdtotalpresmoothed=zeros(1, 12);
    count=1;
    for y=3:2:25
        stdtotalpresmoothed(count)=std([smoothimpro.(y);smoothimpro.(y+1)], 1);
        count=count+1;
    end
    % tranform data into table
    stdtotalsmoothed=array2table(stdtotalpresmoothed, VariableNames=featnames);

%% Struct Gathering
preprocdata.impro=impro;
preprocdata.improdiff=difftable;
preprocdata.smoothed=smoothimpro;
preprocdata.smootheddiff=difftablesmooth;
preprocdata.beginC=beginclient;
preprocdata.beginT=begintherapist;
preprocdata.endC=endclient;
preprocdata.endT=endtherapist;
preprocdata.begintotal=beginidx;
preprocdata.endtotal=endidx;
preprocdata.range=improranges;
preprocdata.rangesmoothed=improrangessmooth;
preprocdata.rangetotal=rangetotal;
preprocdata.rangetotalsmoothed=rangetotalsmoothed;
preprocdata.mean=impromeans;
preprocdata.meansmoothed=impromeanssmoothed;
preprocdata.meantotal=meantotal;
preprocdata.meantotalsmoothed=meantotalsmoothed;
preprocdata.median=impromedian;
preprocdata.mediansmoothed= impromediansmoothed;
preprocdata.mediantotal=mediantotal;
preprocdata.mediantotalsmoothed=mediantotalsmoothed;
preprocdata.std=improstd;
preprocdata.stdsmoothed=improstdsmoothed;
preprocdata.stdtotal=stdtotal;
preprocdata.stdtotalsmoothed=stdtotalsmoothed;
preprocdata.short=improshort;
preprocdata.smoothedshort=smoothimproshort;