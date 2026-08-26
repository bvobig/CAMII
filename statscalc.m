function stats = statscalc (obsc, obst, predsc, predst, data, steps, buffer)
%calculates distribution of interaction types along slider

%% Define Starting Variables and Actor idx
varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

% combine observations and new predictions
for f=1:numel(varnames)
    obsc.(varnames(f)).interactiontype=predsc.(varnames(f));
    obst.(varnames(f)).interactiontype=predst.(varnames(f));
end

ct=["c", "t"];

interactiontypenames=["aia", "ain", "aic", "aiia", "aiin", "aiic", "nia", "nin", "nic", "niia", "niin", "niic","cia", "cin", "cic", "ciia", "ciin", "ciic", "solo"];
rawtypenames=["A.I.A","A.I.N","A.I.C","A.II.A","A.II.N","A.II.C","N.I.A","N.I.N","N.I.C","N.II.A","N.II.N","N.II.C","C.I.A","C.I.N","C.I.C","C.II.A","C.II.N","C.II.C","solo"];
nsteps = numel(1:steps:height(data.impro)); % also constant across all iterations below

%% analyse percentage of interaction types through time

for z=1:2
    if z==1
        obs=obsc;
    elseif z==2
        obs=obst;
    end

    for t=1:numel(varnames)
        % create table for statistics assignment
        emptytable=zeros(nsteps, 19);
        interactiontable=array2table(emptytable, 'VariableNames',interactiontypenames);
        %% Feature-Loop for Percent Calculation

        obsFeat = obs.(varnames(t));
        obsTime = obsFeat.time;
        obsType = string(obsFeat.interactiontype); % interactiontype is categorical (see applymodel.m); switch/case tolerated that implicitly, but == and ismember against a string array below need it converted once here
        obsToNext = obsFeat.tonext;

        % two forward-only pointers into obsTime rescanning the whole column every iteration. Reset here for every (actor, feature) pair, since obsTime is a different column each time.
        nobs = numel(obsTime);
        startptr = 1;
        endptr = 0;
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
            while startptr<=nobs && obsTime(startptr)<areabegin
                startptr=startptr+1;
            end

            if startptr>nobs
                startdata=[]; % matches find(...) returning empty when nothing qualifies
            else
                startdata=startptr;
            end

            while endptr<nobs && obsTime(endptr+1)<=areaend
                endptr=endptr+1;
            end

            if endptr==0
                enddata=[]; % matches find(...) returning empty when nothing qualifies
            else
                enddata=endptr;
            end

            starttime=obsTime(startdata);
            endtime=obsTime(enddata);
            startdiff=starttime-areabegin;
            enddiff=areaend-endtime;

            % add in between values to interaction types
            segrange = startdata:enddata-1; % colon always produces a row, even when empty
            [inrange_tf, inrange_grp] = ismember(obsType(segrange), rawtypenames);
            segtonext = obsToNext(segrange);
            subs = inrange_grp(inrange_tf);
            vals = segtonext(inrange_tf);
            inrange_sums = accumarray(subs(:), vals(:), [19, 1]);
            interactiontable{i, :} = interactiontable{i, :} + inrange_sums';

            % partially add first value
            if obsTime(startdata)>areabegin & startdata>1
                colidx = find(rawtypenames == obsType(startdata-1), 1);
                if ~isempty(colidx)
                    interactiontable{i, colidx} = interactiontable{i, colidx} + startdiff;
                end
            end
            
            % partially add last value
            if obsTime(enddata)<areaend & enddata<height(obsFeat)
                colidx = find(rawtypenames == obsType(enddata), 1);
                if ~isempty(colidx)
                    interactiontable{i, colidx} = interactiontable{i, colidx} + enddiff;
                end
            end
        end

        %% Convert Time spent in Distribution Percentage
        % calculation of percentages of interaction in interaction table
        rowtotals = sum(interactiontable{:, :}, 2); % detect total time in segment (normally areasize as .1s), per row
        interactiontablepercent = array2table(interactiontable{:, :} ./ rowtotals, 'VariableNames', interactiontable.Properties.VariableNames);
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
        timetotal=sum(obsToNext);
        interactiontimetotal=sum(obsToNext(obsType~="solo" & obsType~="none"));
        [cat_tf, cat_grp] = ismember(obsType, rawtypenames);
        cat_subs = cat_grp(cat_tf);
        cat_vals = obsToNext(cat_tf);
        catsums = accumarray(cat_subs(:), cat_vals(:), [19, 1]) / interactiontimetotal;

        % catsums is in rawtypenames order: A.I.A, A.I.N, A.I.C, A.II.A, A.II.N, A.II.C, N.I.A, N.I.N, N.I.C, N.II.A, N.II.N, N.II.C, C.I.A, C.I.N, C.I.C, C.II.A, C.II.N, C.II.C, solo
        aiatotal=catsums(1); aintotal=catsums(2); aictotal=catsums(3);
        aiiatotal=catsums(4); aiintotal=catsums(5); aiictotal=catsums(6);
        aitotal= sum([aiatotal aintotal aictotal]);
        aiitotal= sum([aiiatotal aiintotal aiictotal]);
        atotal= sum([aitotal aiitotal]);
        niatotal=catsums(7); nintotal=catsums(8); nictotal=catsums(9);
        niiatotal=catsums(10); niintotal=catsums(11); niictotal=catsums(12);
        nitotal= sum([niatotal nintotal nictotal]);
        niitotal= sum([niiatotal niintotal niictotal]);
        ntotal= sum([nitotal niitotal]);
        ciatotal=catsums(13); cintotal=catsums(14); cictotal=catsums(15);
        ciiatotal=catsums(16); ciintotal=catsums(17); ciictotal=catsums(18);
        citotal= sum([ciatotal cintotal cictotal]);
        ciitotal= sum([ciiatotal ciintotal ciictotal]);
        ctotal= sum([citotal ciitotal]);

        % solototal= catsums(19); % (left unused)
        % nonetotal=sum(obsToNext(obsType=="none"));

        improstats.(varnames(t)).totalstats1=table(aiatotal, aintotal, aictotal, aiiatotal, aiintotal, aiictotal, ...
            niatotal, nintotal, nictotal, niiatotal, niintotal, niictotal, ciatotal, cintotal, ...
            cictotal, ciiatotal, ciintotal, ciictotal);
        improstats.(varnames(t)).totalstats2=table(aitotal, aiitotal, nitotal, niitotal, citotal, ciitotal);
        improstats.(varnames(t)).totalstats3=table(atotal, ntotal, ctotal);

    end

    stats.(ct(z))=improstats;
    
end
end