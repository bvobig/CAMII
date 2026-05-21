function [predsc, predst] = applymodel (model, obsc, obst)

% apply camii model on observations to predict interaction types
varnames=fieldnames(obsc);

for i=1:height(varnames)
    [interactiontypesc, ~] = model.predictFcn(obsc.(varnames{i}));
    [interactiontypest, ~] = model.predictFcn(obst.(varnames{i}));
    predsc.(varnames{i})=categorical(interactiontypesc);
    predst.(varnames{i})=categorical(interactiontypest);
end