function [obsc, obst] = feat2obs (feats)
% rearrange table created in features to single observations

feature_names=["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];
obsnames=["value", "direction", "absintensity", "totalintensity", "relintensity", "relchgtendency", "othervalue", "otherdirection", "otherabsintensity", "othertotalintensity", "otherrelintensity", "otherrelchgtendency"];

% column reorderings into feats.(feat) (22 columns: 1:7 shared, 8:13 client's own, 14:19 therapist's own, 20:22 shared)
cvaridx=1:22; % client table: keep column order as-is (client's own data already sits in 8:13, therapist's in 14:19)
tvaridx=[1:7,14:19,8:13,20:22]; % therapist table: swap 8:13 and 14:19 so the therapist's own data lands in 8:13 ("own") and the client's in 14:19 ("other"); shared columns 1:7/20:22 stay put

for i=1:numel(feature_names)
    feat = feature_names(i);
% rearrange table
% (vectorised: table column selection/reordering already applies to all
% rows at once -- feats.(feat)(:, idx) is exactly equivalent to the
% previous per-row loop that copied row i, columns idx, for every row,
% just without the per-row table-assignment overhead)
    obsc.(feat) = feats.(feat)(:, cvaridx);
    obst.(feat) = feats.(feat)(:, tvaridx);
% rename variables
    obsc.(feat) = renamevars(obsc.(feat), 8:19, obsnames);
    obst.(feat) = renamevars(obst.(feat), 8:19, obsnames);
% add "feature" column
    obsc.(feat).feature(:)=feat;
    obst.(feat).feature(:)=feat;
% add empty "interactiontype" column
    obsc.(feat).interactiontype(:)=categorical(NaN);
    obst.(feat).interactiontype(:)=categorical(NaN);
end
end