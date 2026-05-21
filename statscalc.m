function stats = statscalc (obsc, obst, predsc, predst, data, steps, buffer)

%calculates distribution of interaction types along slider

%% Define Starting Variables and Actor idx

varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
 
% combine observations and new predictions
for f=1:length(varnames)
    obsc.(varnames(f)).interactiontype=predsc.(varnames(f));
    obst.(varnames(f)).interactiontype=predst.(varnames(f));
end
 
% analyse percentage of interaction types through time
% steps=1 (stepsize of .1 second)
% buffer around current position
 
ct=["c", "t"];

for z=1:2
    if z==1
        obs=obsc;
    elseif z==2
        obs=obst;
    end

for t=1:length(varnames)
 
% create assignment table for results
interactiontypenames=["aia", "ain", "aic", "aiia", "aiin", "aiic", "nia", "nin", "nic", "niia", "niin", "niic","cia", "cin", "cic", "ciia", "ciin", "ciic", "solo"];
emptytable=zeros(length(1:steps:height(data.impro)), 19);

% create table for statistics assignment
interactiontable=array2table(emptytable, 'VariableNames',interactiontypenames);

%% Initiate Feature-Loop for Percent Calculation

for i=1:steps:height(data.impro) % steps of .1 second

    if i<buffer+1 % determine area for analysis 
        areabegin=data.impro.Time(1);
        areaend=data.impro.Time(i+buffer);
    elseif (height(data.impro)-i)<buffer+1
        areabegin=data.impro.Time(i-buffer);
        areaend=data.impro.Time(end);
    else 
        areabegin=data.impro.Time(i-buffer);
        areaend=data.impro.Time(i+buffer);
    end
 
    % find beginning and ending segments in observation data
    startdata=find(obs.(varnames(t)).time>=areabegin, 1, "first");
    enddata=find(obs.(varnames(t)).time<=areaend, 1, "last");
    starttime=obs.(varnames(t)).time(startdata);
    endtime=obs.(varnames(t)).time(enddata);
    startdiff=starttime-areabegin;
    enddiff=areaend-endtime;
 

    % add in between values to interaction types
    if startdata<enddata % only if startdata is smaller than enddata, meaning there are values in between
        for f=startdata:enddata-1
            switch obs.(varnames(t)).interactiontype(f)
                case "A.I.A"
                    interactiontable.aia(i)=interactiontable.aia(i)+obs.(varnames(t)).tonext(f);
                case "A.I.N"
                    interactiontable.ain(i)=interactiontable.ain(i)+obs.(varnames(t)).tonext(f);
                case "A.I.C"
                    interactiontable.aic(i)=interactiontable.aic(i)+obs.(varnames(t)).tonext(f);
                case "A.II.A"
                    interactiontable.aiia(i)=interactiontable.aiia(i)+obs.(varnames(t)).tonext(f);
                case "A.II.N"
                    interactiontable.aiin(i)=interactiontable.aiin(i)+obs.(varnames(t)).tonext(f);
                case "A.II.C"
                    interactiontable.aiic(i)=interactiontable.aiic(i)+obs.(varnames(t)).tonext(f);
                case "N.I.A"
                    interactiontable.nia(i)=interactiontable.nia(i)+obs.(varnames(t)).tonext(f);
                case "N.I.N"
                    interactiontable.nin(i)=interactiontable.nin(i)+obs.(varnames(t)).tonext(f);
                case "N.I.C"
                    interactiontable.nic(i)=interactiontable.nic(i)+obs.(varnames(t)).tonext(f);
                case "N.II.A"
                    interactiontable.niia(i)=interactiontable.niia(i)+obs.(varnames(t)).tonext(f);
                case "N.II.N"
                    interactiontable.niin(i)=interactiontable.niin(i)+obs.(varnames(t)).tonext(f);
                case "N.II.C"
                    interactiontable.niic(i)=interactiontable.niic(i)+obs.(varnames(t)).tonext(f);
                case "C.I.A"
                    interactiontable.cia(i)=interactiontable.cia(i)+obs.(varnames(t)).tonext(f);
                case "C.I.N"
                    interactiontable.cin(i)=interactiontable.cin(i)+obs.(varnames(t)).tonext(f);
                case "C.I.C"
                    interactiontable.cic(i)=interactiontable.cic(i)+obs.(varnames(t)).tonext(f);
                case "C.II.A"
                    interactiontable.ciia(i)=interactiontable.ciia(i)+obs.(varnames(t)).tonext(f);
                case "C.II.N"
                    interactiontable.ciin(i)=interactiontable.ciin(i)+obs.(varnames(t)).tonext(f);
                case "C.II.C"
                    interactiontable.ciic(i)=interactiontable.ciic(i)+obs.(varnames(t)).tonext(f);
                case "solo"
                    interactiontable.solo(i)=interactiontable.solo(i)+obs.(varnames(t)).tonext(f);
                    
            end
        end
    end
%% 

    % partially add first value
    if obs.(varnames(t)).time(startdata)>areabegin & startdata>1
            switch obs.(varnames(t)).interactiontype(startdata-1)
                case "A.I.A"
                    interactiontable.aia(i)=interactiontable.aia(i)+(startdiff);
                case "A.I.N"
                    interactiontable.ain(i)=interactiontable.ain(i)+(startdiff);
                case "A.I.C"
                    interactiontable.aic(i)=interactiontable.aic(i)+(startdiff);
                case "A.II.A"
                    interactiontable.aiia(i)=interactiontable.aiia(i)+(startdiff);
                case "A.II.N"
                    interactiontable.aiin(i)=interactiontable.aiin(i)+(startdiff);
                case "A.II.C"
                    interactiontable.aiic(i)=interactiontable.aiic(i)+(startdiff);
                case "N.I.A"
                    interactiontable.nia(i)=interactiontable.nia(i)+(startdiff);
                case "N.I.N"
                    interactiontable.nin(i)=interactiontable.nin(i)+(startdiff);
                case "N.I.C"
                    interactiontable.nic(i)=interactiontable.nic(i)+(startdiff);
                case "N.II.A"
                    interactiontable.niia(i)=interactiontable.niia(i)+(startdiff);
                case "N.II.N"
                    interactiontable.niin(i)=interactiontable.niin(i)+(startdiff);
                case "N.II.C"
                    interactiontable.niic(i)=interactiontable.niic(i)+(startdiff);
                case "C.I.A"
                    interactiontable.cia(i)=interactiontable.cia(i)+(startdiff);
                case "C.I.N"
                    interactiontable.cin(i)=interactiontable.cin(i)+(startdiff);
                case "C.I.C"
                    interactiontable.cic(i)=interactiontable.cic(i)+(startdiff);
                case "C.II.A"
                    interactiontable.ciia(i)=interactiontable.ciia(i)+(startdiff);
                case "C.II.N"
                    interactiontable.ciin(i)=interactiontable.ciin(i)+(startdiff);
                case "C.II.C"
                    interactiontable.ciic(i)=interactiontable.ciic(i)+(startdiff);
                case "solo"
                    interactiontable.solo(i)=interactiontable.solo(i)+(startdiff);
            end
    end
%% 

    % partially add last value
    if obs.(varnames(t)).time(enddata)<areaend & enddata<height(obs.(varnames(t)))
        switch obs.(varnames(t)).interactiontype(enddata)
            case "A.I.A"
                interactiontable.aia(i)=interactiontable.aia(i)+(enddiff);
            case "A.I.N"
                interactiontable.ain(i)=interactiontable.ain(i)+(enddiff);
            case "A.I.C"
                interactiontable.aic(i)=interactiontable.aic(i)+(enddiff);
            case "A.II.A"
                interactiontable.aiia(i)=interactiontable.aiia(i)+(enddiff);
            case "A.II.N"
                interactiontable.aiin(i)=interactiontable.aiin(i)+(enddiff);
            case "A.II.C"
                interactiontable.aiic(i)=interactiontable.aiic(i)+(enddiff);
            case "N.I.A"
                interactiontable.nia(i)=interactiontable.nia(i)+(enddiff);
            case "N.I.N"
                interactiontable.nin(i)=interactiontable.nin(i)+(enddiff);
            case "N.I.C"
                interactiontable.nic(i)=interactiontable.nic(i)+(enddiff);
            case "N.II.A"
                interactiontable.niia(i)=interactiontable.niia(i)+(enddiff);
            case "N.II.N"
                interactiontable.niin(i)=interactiontable.niin(i)+(enddiff);
            case "N.II.C"
                interactiontable.niic(i)=interactiontable.niic(i)+(enddiff);
            case "C.I.A"
                interactiontable.cia(i)=interactiontable.cia(i)+(enddiff);
            case "C.I.N"
                interactiontable.cin(i)=interactiontable.cin(i)+(enddiff);
            case "C.I.C"
                interactiontable.cic(i)=interactiontable.cic(i)+(enddiff);
            case "C.II.A"
                interactiontable.ciia(i)=interactiontable.ciia(i)+(enddiff);
            case "C.II.N"
                interactiontable.ciin(i)=interactiontable.ciin(i)+(enddiff);
            case "C.II.C"
                interactiontable.ciic(i)=interactiontable.ciic(i)+(enddiff);
            case "solo"
                interactiontable.solo(i)=interactiontable.solo(i)+(enddiff);
        end
    end
end

%% Convert Time spent in Distribution Percentage

% calculation of percentages of interaction in interaction table
interactiontablepercent=array2table(zeros(size(interactiontable)));
interactiontablepercent.Properties.VariableNames=interactiontable.Properties.VariableNames;
for i=1:height(interactiontable)
    totaltime=sum(interactiontable{i, :}); % detect total time in segment (normally areasize as .1s)
    interactiontablepercent(i, :)=interactiontable(i, :)./totaltime;  
end
 
improstats.(varnames(t)).timestable=interactiontable;
improstats.(varnames(t)).percenttable1=interactiontablepercent;

%% Calculate higher-level Measurements

% sums of c, a and n for distance and closeness
ai=interactiontablepercent{:, "aia"}+interactiontablepercent{:, "ain"}+interactiontablepercent{:, "aic"};
aii=interactiontablepercent{:, "aiia"}+interactiontablepercent{:, "aiin"}+interactiontablepercent{:, "aiic"};
ni=interactiontablepercent{:, "nia"}+interactiontablepercent{:, "nin"}+interactiontablepercent{:, "nic"};
nii=interactiontablepercent{:, "niia"}+interactiontablepercent{:, "niin"}+interactiontablepercent{:, "niic"};
ci=interactiontablepercent{:, "cia"}+interactiontablepercent{:, "cin"}+interactiontablepercent{:, "cic"};
cii=interactiontablepercent{:, "ciia"}+interactiontablepercent{:, "ciin"}+interactiontablepercent{:, "ciic"};

% total sums of a, c and n
a=ai+aii;
c=ci+cii;
n=ni+nii;

%assign
improstats.(varnames(t)).percenttable2=table(ai, aii, ni, nii, ci, cii);
improstats.(varnames(t)).percenttable3=table(a, n, c);

%% Assign total Percentages for Interaction Types to Final Table

timetotal=sum(obs.(varnames(t)).tonext);
interactiontimetotal=sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype~="solo" & obs.(varnames(t)).interactiontype~="none"));

aiatotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="A.I.A"))/interactiontimetotal;
aiiatotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="A.II.A"))/interactiontimetotal;
aintotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="A.I.N"))/interactiontimetotal;
aiintotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="A.II.N"))/interactiontimetotal;
aictotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="A.I.C"))/interactiontimetotal;
aiictotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="A.II.C"))/interactiontimetotal;
aitotal= sum([aiatotal aintotal aictotal]);
aiitotal= sum([aiiatotal aiintotal aiictotal]);
atotal= sum([aitotal aiitotal]);

niatotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="N.I.A"))/interactiontimetotal;
niiatotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="N.II.A"))/interactiontimetotal;
nintotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="N.I.N"))/interactiontimetotal;
niintotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="N.II.N"))/interactiontimetotal;
nictotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="N.I.C"))/interactiontimetotal;
niictotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="N.II.C"))/interactiontimetotal;
nitotal= sum([niatotal nintotal nictotal]);
niitotal= sum([niiatotal niintotal niictotal]);
ntotal= sum([nitotal niitotal]);


ciatotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="C.I.A"))/interactiontimetotal;
ciiatotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="C.II.A"))/interactiontimetotal;
cintotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="C.I.N"))/interactiontimetotal;
ciintotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="C.II.N"))/interactiontimetotal;
cictotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="C.I.C"))/interactiontimetotal;
ciictotal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="C.II.C"))/interactiontimetotal;
citotal= sum([ciatotal cintotal cictotal]);
ciitotal= sum([ciiatotal ciintotal ciictotal]);
ctotal= sum([citotal ciitotal]);

% solototal= sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="solo"));
% nonetotal=sum(obs.(varnames(t)).tonext(obs.(varnames(t)).interactiontype=="none"));
 
improstats.(varnames(t)).totalstats1=table(aiatotal, aintotal, aictotal, aiiatotal, aiintotal, aiictotal, ...
    niatotal, nintotal, nictotal, niiatotal, niintotal, niictotal, ciatotal, cintotal, ...
    cictotal, ciiatotal, ciintotal, ciictotal);
improstats.(varnames(t)).totalstats2=table(aitotal, aiitotal, nitotal, niitotal, citotal, ciitotal);
improstats.(varnames(t)).totalstats3=table(atotal, ntotal, ctotal);

end
   
    stats.(ct(z))=improstats;
    
end
end