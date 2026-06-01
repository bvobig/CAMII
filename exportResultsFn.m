function exportResultsFn (results, clno, TableFormat)
%%
actorNames = ["c", "t"];
%%
%extract typestotal as table

typestotalTable = table();

for actoridx = 1:2
    actor=actorNames(actoridx);
    featName=fieldnames(results.typestotal.(actor));
    for featidx = 1: numel(featName)
        feat=string(featName{featidx});
        featentry = [table(actor, VariableNames="Actor"), table(feat, VariableNames="Feat"), results.typestotal.(actor).(feat)];
        typestotalTable(end+1, :) = featentry;
    end
end
%%
%rearrange table
    typestotalTable.Actor = categorical(typestotalTable.Actor);
    typestotalTable.Feat= categorical(typestotalTable.Feat);
    writetable(typestotalTable, (clno + "_typesTotal." + TableFormat))
%%
%extract types evolution as table

typesEvolution = table();

for actoridx = 1:2
    actor=actorNames(actoridx);
    for featidx = 1: height(fieldnames(results.types.(actor)))
        featName=fieldnames(results.types.(actor));
        feat=string(featName{featidx});
        columnName = feat + "_" + actor;
        typesEvolution.(columnName) = results.types.(actor).(feat);
    end
end
%%
    writetable(typesEvolution, (clno + "_typesEvolution." + TableFormat))
%%
end