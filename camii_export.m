function camii_export(result_struct, clno, options)
%%
    arguments
        result_struct (1,:) struct
        clno (1,:) string = string(datetime("now", Format = 'yyyyMMdd_HHmmss'));

        options.export_graphs (1,1) logical = false
        options.export_segments (1,1) logical = false
        options.export_stats (1,1) logical = false
        options.export_types (1,1) logical = false
        options.export_results (1,1) logical = false

        options.ExportFormat string{mustBeMember(options.ExportFormat, ["png", "jpg", "eps", "svg"])} = "png"

        options.GraphFeatures string{mustBeMember(options.GraphFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.SegFeatures string {mustBeMember(options.SegFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"   
        options.StatFeatures string {mustBeMember(options.StatFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.TypeFeatures string {mustBeMember(options.TypeFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.TableFormat string {mustBeMember(options.TableFormat, ["xlsx", "csv"])} = "xlsx"

        options.OutputFolder string = ""

    end

%%

outdir = options.OutputFolder;

    if strlength(outdir) == 0
        outdir=pwd;
    end
    
    if ~exist(outdir, 'dir')
        mkdir(outdir)
    end

featureNames = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

graphIDs = mapFeatures(options.GraphFeatures, [1 3 5 7 9 11 13 15 17 19 21 23], featureNames);
segIDs = mapFeatures(options.SegFeatures, [1 3 5 7 9 11 13 15 17 19 21 23], featureNames);
statIDs = mapFeatures(options.StatFeatures, 1:12, featureNames);
typeIDs = mapFeatures(options.TypeFeatures, 1:12, featureNames);

%%

exportResults(clno, graphIDs, segIDs, statIDs, typeIDs, result_struct, outdir, options) %Export Data

% Export

function exportResults(clno, graphIDs, segIDs, statIDs, typeIDs, result_struct, outdir, options)

    if options.export_graphs
        exportGraphsFn(result_struct.data, result_struct.segmentsbv, graphIDs, clno, options.ExportFormat, outdir);
        disp("Graph Export finished")
    end

    if options.export_segments
        exportSegsFn(result_struct.data, result_struct.segmentsbv, result_struct.feats, segIDs, clno, options.ExportFormat, outdir);
        disp("Segments Export finished")
    end

    if options.export_stats
        exportStatsFn(result_struct.data, result_struct.stats, statIDs, clno, options.ExportFormat, outdir);
        disp("Stat Export finished")
    end

    if options.export_types
        exportTypesFn(result_struct.data, result_struct.types, result_struct.typestotal, typeIDs, clno, options.ExportFormat, outdir);
        disp("Interaction Type Export finished")
    end

    if options.export_results
        exportResultsFn(result_struct, clno, options.TableFormat, outdir);
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

end