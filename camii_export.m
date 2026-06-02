function camii_export(result_struct, clno, options)
%%
    arguments
        result_struct (1,:) struct
        clno (1,:) string

        options.export_graphs (1,1) logical = false
        options.export_segments (1,1) logical = false
        options.export_stats (1,1) logical = false
        options.export_types (1,1) logical = false
        options.export_results (1,1) logical = false

        options.BufferSize (1,1) double = 25
        options.ExportFormat string{mustBeMember(options.ExportFormat, ["png", "jpg", "eps", "svg"])} = "jpg"

        options.GraphFeatures string{mustBeMember(options.GraphFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.SegFeatures string {mustBeMember(options.SegFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"   
        options.StatFeatures string {mustBeMember(options.StatFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.TypeFeatures string {mustBeMember(options.TypeFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.TableFormat string {mustBeMember(options.TableFormat, ["xlsx", "csv"])} = "xlsx"

    end

%%

featureNames = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

graphIDs = mapFeatures(options.GraphFeatures, [1 3 5 7 9 11 13 15 17 19 21 23], featureNames);
segIDs = mapFeatures(options.SegFeatures, [1 3 5 7 9 11 13 15 17 19 21 23], featureNames);
statIDs = mapFeatures(options.StatFeatures, 1:12, featureNames);
typeIDs = mapFeatures(options.TypeFeatures, 1:12, featureNames);

formatNames = ["png", "jpg", "eps", "svg"];

exportFigFormat = mapFormat(options.ExportFormat, ["-png", "-jpg", "-eps", "-svg"], formatNames);
printFormat = mapFormat(options.ExportFormat, ["-dpng", "-djpeg", "-depsc", "-dsvg"], formatNames);

%%

exportResults(clno, graphIDs, segIDs, statIDs, typeIDs, exportFigFormat, printFormat, result_struct, options) %Export Data

% Export

function exportResults(clno, graphIDs, segIDs, statIDs, typeIDs, exportFigFormat, printFormat, result_struct, options)

    if options.export_graphs
        exportGraphsFn(result_struct.data, result_struct.segmentsbv, graphIDs, clno, exportFigFormat, printFormat);
        disp("Graph Export finished")
    end

    if options.export_segments
        exportSegsFn(result_struct.data, result_struct.segmentsbv, result_struct.feats, segIDs, clno, exportFigFormat);
        disp("Segments Export finished")
    end

    if options.export_stats
        exportStatsFn(result_struct.data, result_struct.stats, statIDs, clno, exportFigFormat);
        disp("Stat Export finished")
    end

    if options.export_types
        exportTypesFn(result_struct.data, result_struct.types, result_struct.typestotal, typeIDs, clno, printFormat);
        disp("Interaction Type Export finished")
    end

    if options.export_results
        exportResultsFn(result_struct, clno, options.TableFormat);
    end

    beep on; beep; 
    disp("Export of Data finished")
end

%%

function ids = mapFeatures(features, values, names)

    if any(features == "All")
        ids = values;
        return
    end

    ids = zeros(1,numel(features));

    for k = 1:numel(features)
        idx = strcmpi(features(k), names);
        if ~any(idx)
            error("Unknown feature: %s", features(k))
        end
        ids(k) = values(idx);    
    end
end

function format = mapFormat(formatInput, values, names)
    idx = strcmpi(formatInput, names);
        if ~any(idx)
            error("Unknown Export Format: %s", formatInput)
        end
    format = values(idx);
    
end

end