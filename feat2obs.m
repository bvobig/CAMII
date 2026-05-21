function [obsc, obst] = feat2obs (feats)

% rearrange table created in features to single observations 
varnames=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
obsnames=["value", "direction", "absintensity", "totalintensity", "relintensity", "relchgtendency", "othervalue", "otherdirection", "otherabsintensity", "othertotalintensity", "otherrelintensity", "otherrelchgtendency"];
cvaridx=1:22;
tvaridx=[1:7,14:19,8:13,20:22];

% feat indicator
for y=1:2:23 

% var indicator
z=(y+1)/2; 
var=varnames{z};

% rearrange table
for i=1:height(feats.(var))
    obsc.(var)(i, 1:22)=feats.(var)(i, cvaridx);
    obst.(var)(i, 1:22)=feats.(var)(i, tvaridx);
end

% rename variables
obsc.(var)=renamevars(obsc.(var), 8:19, obsnames);
obst.(var)=renamevars(obst.(var), 8:19, obsnames);

% add "feature" column
obsc.(var).feature(:)=varnames(z);
obst.(var).feature(:)=varnames(z);

% add empty "interactiontype" column
obsc.(var).interactiontype(:)=categorical(NaN);
obst.(var).interactiontype(:)=categorical(NaN);

end