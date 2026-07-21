function [predsc, predst] = applymodel (model, obsc, obst)
% apply camii model on observations to predict interaction types

featnames=fieldnames(obsc); % same feature set as obst, by construction of feat2obs

for i=1:numel(featnames)
    [interactiontypesc, ~] = model.predictFcn(obsc.(featnames{i}));
    [interactiontypest, ~] = model.predictFcn(obst.(featnames{i}));
    predsc.(featnames{i})=categorical(interactiontypesc);
    predst.(featnames{i})=categorical(interactiontypest);
end

end