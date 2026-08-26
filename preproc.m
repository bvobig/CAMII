function preprocdata = preproc (mttbdata, smoothmethod)
% preproc creates 4 datasets for original, smoothed and shortened alternatives. Further gives out statistical values for each feature and beginning/ends of play

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
% calculate new "Time" indicator as mean between Frame Begin and Frame End
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
% calculate minimum of ending indexes for total end
endclient=find(beginning(:, 1), 1, "last");
endtherapist=find(beginning(:, 2), 1, "last");
if isempty(beginclient) || isempty(begintherapist)
    warning('camii:preproc:SoloImprovisation', ...
        'Client or Therapist never plays in this improvisation -- treating it as a solo improvisation for begin/end-of-play detection.')
end
% concatenating (rather than min/max on two separate arguments) ensures
% begin/endidx still resolve correctly when one actor never plays, i.e.
% one of the four find() results above is empty
beginidx=min([beginclient, begintherapist]);
endidx=max([endclient, endtherapist]);
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
    otherwise
        error('camii:preproc:InvalidSmoothMethod', ...
            'Invalid smoothmethod (%s). Valid options are 1 (fixed 20-frame movmean) or 2 (movmean with SmoothingFactor=0.1).', mat2str(smoothmethod))
end

%% NaN Correction
% Insert original impro NaN Values in smoothimpro and smoothimproshort
% Convert Variable names for input to array2table
varnameschar=convertStringsToChars(varnames);
% for normal impro: reinsert NaN gaps that smoothdata interpolated across
smoothimpro=restoreNaNs(impro, smoothimpro, varnameschar);
% for short impro: same correction
smoothimproshort=restoreNaNs(improshort, smoothimproshort, varnameschar);

%% Individual Statistics
% Calculate Individual Statistical Data for each Feature
% Range
% calculate and rename range
improranges=range(impro(:, 3:end));
improranges=renamevars(improranges, 1:width(improranges), (varnames(3:end)));
% smoothed
improrangessmooth=range(smoothimpro(:, 3:end));
improrangessmooth=renamevars(improrangessmooth, 1:width(improrangessmooth), (varnames(3:end)));
% Mean
% calculate and rename mean
impromeans=mean(impro(:, 3:end), "omitmissing");
impromeans=renamevars(impromeans, 1:width(impromeans), (varnames(3:end)));
% smoothed
impromeanssmoothed=mean(smoothimpro(:, 3:end), "omitmissing");
impromeanssmoothed=renamevars(impromeanssmoothed, 1:width(impromeanssmoothed), (varnames(3:end)));
% Median
% calculate and rename median
impromedian=median(impro(:, 3:end), "omitmissing");
impromedian=renamevars(impromedian, 1:width(impromedian), (varnames(3:end)));
% smoothed
impromediansmoothed=median(smoothimpro(:, 3:end), "omitmissing");
impromediansmoothed=renamevars(impromediansmoothed, 1:width(impromediansmoothed), (varnames(3:end)));
% Standard Deviation
% calculate and rename std, w in this case is 1 because all values are
% present, set to 0 for estimation of mean by n-1 to compensate for using
% estimated values as in a sample set
improstd=std(impro(:, 3:end), 1, "omitmissing");
improstd=renamevars(improstd, 1:width(improstd), (varnames(3:end)));
% smoothed
improstdsmoothed=std(smoothimpro(:, 3:end), 1, "omitmissing");
improstdsmoothed=renamevars(improstdsmoothed, 1:width(improstdsmoothed), (varnames(3:end)));

%% Difference Calculation
% Calculate FeatDelta between Players (forward)
% calculate difference between the two players for original data
% client minus therapist (positive values mean client is above therapist, negative values mean client is below therapist)
% create vector for FeatDelta Names
diffvars=["ACDiff", "ArticulationDiff", "DensityDiff", "DissonanceDiff", "DurationDiff", "MajornessDiff", "MeanPitchDiff", "MeanVelocityDiff", "MinornessDiff", "StandardPitchDeviationDiff", "TempoDiff", "TonalityDiff"];
% Raw Impro Data
difftable=table;
count=1;
for i=3:2:width(impro)
    difftable.(diffvars(count))=impro.(i)-impro.(i+1); % vectorised column subtraction (was a per-row loop)
    count=count+1;
end
% Smoothed Data
difftablesmooth=table;
count=1;
for i=3:2:width(smoothimpro)
    difftablesmooth.(diffvars(count))=smoothimpro.(i)-smoothimpro.(i+1); % vectorised column subtraction (was a per-row loop)
    count=count+1;
end

%% Common Statistics
% Calculate Common Feature Statistics (Client+Therapist combined per feature)
rangetotal          = combinedStat(impro, featnames, @range);
rangetotalsmoothed  = combinedStat(smoothimpro, featnames, @range);
meantotal           = combinedStat(impro, featnames, @(x) mean(x, "omitmissing"));
meantotalsmoothed   = combinedStat(smoothimpro, featnames, @(x) mean(x, "omitmissing"));
mediantotal         = combinedStat(impro, featnames, @(x) median(x, "omitmissing"));
mediantotalsmoothed = combinedStat(smoothimpro, featnames, @(x) median(x, "omitmissing"));
stdtotal            = combinedStat(impro, featnames, @(x) std(x, 1, "omitmissing"));
stdtotalsmoothed    = combinedStat(smoothimpro, featnames, @(x) std(x, 1, "omitmissing"));

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
end

function T = restoreNaNs(origT, smoothT, varnameschar)
% Reinsert the NaN gaps present in origT (which smoothdata interpolates
% across) back into smoothT, then reattach the Time/Time_Start columns
% from origT and rename to match. origT has [Time, Time_Start, features...],
% smoothT has only [features...] (as produced by smoothdata on origT(:,3:end)).
origArray = table2array(origT);
smoothArray = table2array(smoothT);
nanIdx = isnan(origArray(:, 3:end));
smoothArray(nanIdx) = NaN;
smoothArray = [origT.Time, origT.Time_Start, smoothArray];
T = array2table(smoothArray, VariableNames=varnameschar);
end

function statTable = combinedStat(T, featnames, statFcn)
% Apply statFcn to each feature's combined Client+Therapist column pair
% (e.g. columns 3&4, 5&6, ... of T) and return a 1-row table with one
% column per feature, named after featnames.
nFeat = numel(featnames);
vals = zeros(1, nFeat);
for k = 1:nFeat
    y = 2*k + 1; % first feature column is column 3
    vals(k) = statFcn([T.(y); T.(y+1)]);
end
statTable = array2table(vals, VariableNames=featnames);
end