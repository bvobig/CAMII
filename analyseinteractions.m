function [types, typestotal] = analyseinteractions (stats, data, partnerthresh)

%assigns interaction type distribution to role gradients

%% Define Starting and Looping Indicators

varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
ct=["c","t"];

% variable indicator
for t=1:12
    var=varnames(t);
 
% player indicator
for p = 1:2
    player=ct(p);
 

%% Start Assignment Loop

for y=1:height(stats.(player).(var).timestable)
if ~isnan(stats.(player).(var).percenttable3{y, 1})
[~, promidx]=max(stats.(player).(var).percenttable3(y, :), [], 2);
 
if promidx{:, :} == 1 % Affirmative
  
    [deltaval, deltaidx] = max(stats.(player).(var).percenttable2{y, 1:2}, [], 2);
   
    if deltaidx==2 % if not in proximity
        interactiontype(y)=categorical("Approach"); % (Approaching Follower), can be changed again afterwards
   
    else % if in proximity
        proxdiff=abs(deltaval-(stats.(player).(var).percenttable2{y, 5})); % calculate difference between ai and ci
        if proxdiff <= partnerthresh % if difference of ci and ai is below partnerthresh, partnerthresh = percentual difference between a.i and c.i to detect Partner gradient
            interactiontype(y)=categorical("Partner"); % (Subordinate)
       
        else % if difference between ci and ai is above partnerthresh
            dom=stats.(player).(var).percenttable2{y,1}>=0.95; % calculate if ai is used more than 95% 
            if dom==1 % if ai is dominant
                interactiontype(y)=categorical("Dependent");
           
            else % if ai is not dominant
                interactiontype(y)=categorical("Follower"); % (Close)
            end
        end
    end

elseif promidx{:, :} == 2 % Neutral

    [deltaval, deltaidx] = max(stats.(player).(var).percenttable2{y, 3:4}, [], 2);
  
    if deltaidx == 1 % if there is proximity
       
        [otherval, otheridx] = max(stats.(player).(var).percenttable1{y, 7:9}, [], 2);
       
        if otheridx==1 % if other is a
            interactiontype(y)=categorical("Partner"); % (Welcoming) % LNdW Partner / Original: Neutral
        elseif otheridx==2 % if other is n
            interactiontype(y)=categorical("Partner"); % (Connected)
        elseif otheridx==3 % if other is c
            interactiontype(y)=categorical("Partner"); % (Withstand) % LNdW Partner / Original: Neutral
        end
    
    else % if no proximity
      
        [otherval, otheridx] = max(stats.(player).(var).percenttable1{y, 10:12}, [], 2);

        if otheridx==1 % if other is a
            interactiontype(y)=categorical("Resister"); % (Welcoming)
        elseif otheridx==2 % if other is n
            interactiontype(y)=categorical("Resister"); % (Neutral)
        elseif otheridx==3 % if other is c
            interactiontype(y)=categorical("Resister"); % (Withstand)
        end
    end
%% 
elseif promidx{:, :} == 3 % Contradictive

    [deltaval, deltaidx] = max(stats.(player).(var).percenttable2{y, 5:6}, [], 2);

    if deltaidx==2 % if not in proximity
        interactiontype(y)=categorical("Resister"); % (active)
   
    else % if in proximity
        proxdiff=abs(deltaval-(stats.(player).(var).percenttable2{y, 1})); % calculate difference between ai and ci
        if proxdiff <= partnerthresh % if difference of ci and ai is below partnerthresh
            interactiontype(y)=categorical("Partner"); % (Superior)
       
        else % if difference between ci and ai is above partnerthresh
            interactiontype(y)=categorical("Leader");
        end
    end
end
%% 
else 
    interactiontype(y)=categorical("none");
end
    types.(player).(var)=interactiontype';
end
end

%% Solo Passage Detection

noneidxc=isnan(data.smoothed.(var + "C")); % identify none passages
noneidxt=isnan(data.smoothed.(var + "T")); % identify none passages

% apply noneidx to assign "none", therefore omit too early and too late
% assignments due to analysis window

types.c.(var)(noneidxc)=categorical ("none");
types.t.(var)(noneidxt)=categorical ("none");

soloidxc=~noneidxc+noneidxt==2;
soloidxt=~noneidxt+noneidxc==2;

types.c.(var)(soloidxc)=categorical("Solo"); % reassign "Solo" cat for solo passages for each player within feature cycle
types.t.(var)(soloidxt)=categorical("Solo");

clear noneidxc noneidxt soloidxt soloidxc

%% Calculate total Percentages of Interaction Types for each Player

csolo= nnz(types.c.(var) == "Solo"); % Solo
cnone= nnz(types.c.(var) == "none"); % none

totaltypeamountc= height(types.c.(var)) - csolo - cnone; % total c positions that are not none or Solo, inter-actions
cneutral= nnz(types.c.(var) == "Neutral") / totaltypeamountc; % Neutral
cdependent= nnz(types.c.(var) == "Dependent") / totaltypeamountc; % Dependent
cfollower= nnz(types.c.(var) == "Follower") / totaltypeamountc; % Follower
cpartner= nnz(types.c.(var) == "Partner") / totaltypeamountc; % Partner
cleader= nnz(types.c.(var) == "Leader") / totaltypeamountc; % Leader
cresister= nnz(types.c.(var) == "Resister") / totaltypeamountc; % Resister
capproach= nnz(types.c.(var) == "Approach") / totaltypeamountc; % Approach

ctypestotal = array2table([cdependent, capproach, cfollower, cpartner, cleader, cresister, cneutral], "VariableNames", ["Dependent", "Approach", "Follower", "Partner", "Leader", "Resister", "Neutral"]);

tsolo= nnz(types.t.(var) == "Solo"); % Solo
tnone= nnz(types.t.(var) == "none"); % none

totaltypeamountt= height(types.t.(var)) - tsolo - tnone; % total c positions that are not none or Solo, inter-actions
tneutral= nnz(types.t.(var) == "Neutral") / totaltypeamountt; % Neutral
tdependent= nnz(types.t.(var) == "Dependent") / totaltypeamountt; % Dependent
tfollower= nnz(types.t.(var) == "Follower") / totaltypeamountt; % Follower
tpartner= nnz(types.t.(var) == "Partner") / totaltypeamountt; % Partner
tleader= nnz(types.t.(var) == "Leader") / totaltypeamountt; % Leader
tresister= nnz(types.t.(var) == "Resister") / totaltypeamountt; % Resister
tapproach= nnz(types.t.(var) == "Approach") / totaltypeamountt; % Approach

ttypestotal = array2table([tdependent, tapproach, tfollower, tpartner, tleader, tresister, tneutral], "VariableNames", ["Dependent", "Approach", "Follower", "Partner", "Leader", "Resister", "Neutral"]);

typestotal.c.(var)=ctypestotal;
typestotal.t.(var)=ttypestotal;
%% 
end
end
%% 
% 