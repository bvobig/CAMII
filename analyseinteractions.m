function [types, typestotal] = analyseinteractions (stats, data, partnerthresh)
%assigns interaction type distribution to role gradients

%% Define Starting and Looping Indicators
varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
ct=["c","t"];
% category names used both for the per-row classification below and for
% the total-percentage counting further down
catnames = ["Dependent","Approach","Follower","Partner","Leader","Resister","Neutral"];

%% Initiate Loops

% variable indicator
for t=1:12
    var=varnames(t);

    % player indicator
    for p = 1:2
        player=ct(p);
        %% Start Assignment Loop
        n = height(stats.(player).(var).timestable);

        pt2 = stats.(player).(var).percenttable2{:, :}; % columns: ai, aii, ni, nii, ci, cii
        pt3 = stats.(player).(var).percenttable3{:, :}; % columns: a, n, c

        validmask = ~isnan(pt3(:, 1));
        [~, promidx] = max(pt3, [], 2); % 1=Affirmative, 2=Neutral, 3=Contradictive, matching a/n/c column order
        isA = validmask & promidx==1;
        isN = validmask & promidx==2;
        isCon = validmask & promidx==3;
        interactiontype = repmat(categorical("none"), n, 1); % default for rows that fail validmask

        % Affirmative
        [deltaval_a, deltaidx_a] = max(pt2(:, 1:2), [], 2); % ai vs aii
        notproximity_a = deltaidx_a==2;
        proxdiff_a = abs(deltaval_a - pt2(:, 5)); % vs ci
        inthresh_a = proxdiff_a <= partnerthresh;
        dom_a = pt2(:, 1) >= 0.95; % ai used more than 95%

        interactiontype(isA & notproximity_a) = categorical("Approach"); % (Approaching Follower), can be changed again afterwards
        interactiontype(isA & ~notproximity_a & inthresh_a) = categorical("Partner"); % (Subordinate)
        interactiontype(isA & ~notproximity_a & ~inthresh_a & dom_a) = categorical("Dependent");
        interactiontype(isA & ~notproximity_a & ~inthresh_a & ~dom_a) = categorical("Follower"); % (Close)

        % Neutral
        [~, deltaidx_n] = max(pt2(:, 3:4), [], 2); % ni vs nii
        proximity_n = deltaidx_n==1;

        interactiontype(isN & proximity_n) = categorical("Partner"); % (Welcoming/Connected/Withstand)
        interactiontype(isN & ~proximity_n) = categorical("Resister"); % (Welcoming/Neutral/Withstand)

        % Contradictive
        [deltaval_c, deltaidx_c] = max(pt2(:, 5:6), [], 2); % ci vs cii
        notproximity_c = deltaidx_c==2;
        proxdiff_c = abs(deltaval_c - pt2(:, 1)); % vs ai
        inthresh_c = proxdiff_c <= partnerthresh;

        interactiontype(isCon & notproximity_c) = categorical("Resister"); % (active)
        interactiontype(isCon & ~notproximity_c & inthresh_c) = categorical("Partner"); % (Superior)
        interactiontype(isCon & ~notproximity_c & ~inthresh_c) = categorical("Leader");

        types.(player).(var)=interactiontype;

    end

    %% Solo Passage Detection
    noneidxc=isnan(data.smoothed.(var + "C")); % identify none passages
    noneidxt=isnan(data.smoothed.(var + "T")); % identify none passages

    % apply noneidx to assign "none", therefore omit too early and too late assignments due to analysis window
    types.c.(var)(noneidxc)=categorical ("none");
    types.t.(var)(noneidxt)=categorical ("none");

    soloidxc = ~noneidxc & noneidxt; % client plays, therapist doesn't
    soloidxt = ~noneidxt & noneidxc; % therapist plays, client doesn't

    types.c.(var)(soloidxc)=categorical("Solo"); % reassign "Solo" cat for solo passages for each player within feature cycle
    types.t.(var)(soloidxt)=categorical("Solo");

    %% Calculate total Percentages of Interaction Types for each Player
    allcatnames = ["Solo","none",catnames];

    [tf_c, grp_c] = ismember(string(types.c.(var)), allcatnames);
    subs_c = grp_c(tf_c);
    counts_c = accumarray(subs_c(:), 1, [numel(allcatnames), 1]); 

    csolo=counts_c(1); 
    cnone=counts_c(2);

    totaltypeamountc= height(types.c.(var)) - csolo - cnone; % total c positions that are not none or Solo, interactions

    cdependent=counts_c(3)/totaltypeamountc; 
    capproach=counts_c(4)/totaltypeamountc; 
    cfollower=counts_c(5)/totaltypeamountc;
    cpartner=counts_c(6)/totaltypeamountc; 
    cleader=counts_c(7)/totaltypeamountc; 
    cresister=counts_c(8)/totaltypeamountc; 
    cneutral=counts_c(9)/totaltypeamountc;

    ctypestotal = array2table([cdependent, capproach, cfollower, cpartner, cleader, cresister, cneutral], "VariableNames", catnames);

    [tf_t, grp_t] = ismember(string(types.t.(var)), allcatnames);
    subs_t = grp_t(tf_t);
    counts_t = accumarray(subs_t(:), 1, [numel(allcatnames), 1]); 

    tsolo=counts_t(1); 
    tnone=counts_t(2);

    totaltypeamountt= height(types.t.(var)) - tsolo - tnone; % total t positions that are not none or Solo, interactions

    tdependent=counts_t(3)/totaltypeamountt; 
    tapproach=counts_t(4)/totaltypeamountt; 
    tfollower=counts_t(5)/totaltypeamountt;
    tpartner=counts_t(6)/totaltypeamountt; 
    tleader=counts_t(7)/totaltypeamountt; 
    tresister=counts_t(8)/totaltypeamountt; 
    tneutral=counts_t(9)/totaltypeamountt;
    
    ttypestotal = array2table([tdependent, tapproach, tfollower, tpartner, tleader, tresister, tneutral], "VariableNames", catnames);

    typestotal.c.(var)=ctypestotal;
    typestotal.t.(var)=ttypestotal;
end
end