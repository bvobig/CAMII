function crossings = crossingcalc (data)

varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

%set counter
x=1;

for t=3:2:25 %initiate loop for crossing calculation of all features
    %crossing calculation with InterX
    crossing=InterX([data.smoothed.Time';data.smoothed.(t)'], [data.smoothed.Time';data.smoothed.(t+1)']);
    %use counter for struct allocation 
    crossings.(varnames(x))=crossing;
    %increase counter
    x=x+1;
end

end