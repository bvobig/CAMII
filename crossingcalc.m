function crossings = crossingcalc (data, n)

varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

%set counter
x=1;

%case for raw or smoothed data
switch n

    case 1 %smoothed data

%initiate loop for crossing calculation of all features
for t=3:2:25
%crossing calculation with InterX
crossing=InterX([data.smoothed.Time';data.smoothed.(t)'], [data.smoothed.Time';data.smoothed.(t+1)']);
%use counter for struct allocation 
crossings.(varnames(x))=crossing;
%increase counter
x=x+1;
end

    case 0 %raw data

%initiate loop for crossing calculation of all features
for t=3:2:25
%crossing calculation with InterX
crossing=InterX([data.impro.Time';data.impro.(t)'], [data.impro.Time';data.impro.(t+1)']);
%use counter for struct allocation 
crossings.(varnames(x))=crossing;
%increase counter
x=x+1;
end

end