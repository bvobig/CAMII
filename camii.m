function [results] = camii(midi_file, clno, options)
%%
    arguments
        midi_file (1,:) string
        clno (1,:) string

        options.GraphExport (1,1) logical = false
        options.SegExport   (1,1) logical = false
        options.StatExport  (1,1) logical = false
        options.TypeExport  (1,1) logical = false

        options.BufferSize (1,1) double = 25
        options.ExportFormat string{mustBeMember(options.ExportFormat, ["png", "jpg", "eps", "svg"])} = "jpg"

    options.GraphFeatures string{mustBeMember(options.GraphFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"

    options.SegFeatures string {mustBeMember(options.SegFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
    
    options.StatFeatures string {mustBeMember(options.StatFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"

    options.TypeFeatures string {mustBeMember(options.TypeFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"

    end
%%
% Validate MIDI file
    if ~isfile(midi_file)
        error("camii:FileNotFound", ...
            "The specified MIDI file does not exist.")
    end

    [~,~,ext] = fileparts(midi_file);
   
    if ~strcmpi(ext,'.mid')
    error("camii:InvalidFileType", ...
        "Input file must be a .mid file.")
   end
%%

featureNames = ["AC", "Articulation", "Density", "Dissonance", "Duration", "Majorness", "MeanPitch", "MeanVelocity", "Minorness", "StandardPitchDeviation", "Tempo", "Tonality"];

graphIDs = mapFeatures(options.GraphFeatures, [1 3 5 7 9 11 13 15 17 19 21 23], featureNames);
segIDs = mapFeatures(options.SegFeatures, [1 3 5 7 9 11 13 15 17 19 21 23], featureNames);
statIDs = mapFeatures(options.StatFeatures, 1:12, featureNames);
typeIDs = mapFeatures(options.TypeFeatures, 1:12, featureNames);

formatNames = ["png", "jpg", "eps", "svg"];

exportFigFormat = mapFormat(options.ExportFormat, ["-png", "-jpg", "-eps", "-svg"], formatNames);
printFormat = mapFormat(options.ExportFormat, ["-dpng", "-djpg", "-depsc", "-dsvg"], formatNames);


%%
load ("camii_model.mat", "camii_model") % load ML model
%%
improdata = mttb_light2(midi_file, 0.1, 6);
[data, segmentsbv, feats, stats, types, typestotal] = analysis (improdata, camii_model, options); %Analyse Data
exportResults(data, clno, segmentsbv, feats, stats, types, typestotal, graphIDs, segIDs, statIDs, typeIDs, exportFigFormat, printFormat, options) %Export Data

results.typestotal=typestotal; % Gather Results
results.types=types;
results.stats=stats;
% Calculation

function [data, segmentsbv, feats, stats, types, typestotal] = analysis (mttbdata, model, options) %typestruct

    data = preproc(mttbdata, 1); disp("Preprocessing finished")% preprocess mttb data
    segmentsbv = segmentbv(data, 2, 0, 1); disp("bvsegmentation finished") % segment data (data, smoothing, prominence values)
    % segmentsol = segmentol(data, 0); disp("olsegmentation finished") % Olivier segmentation method (data, smoothing)
    feats = featcalc(data, 1, segmentsbv, 1, 0.01); disp("Feature Calculation finished") % calculate features (data, smoothed, segmentmethod, zerodetection, zerothresh)
    [obsc, obst] = feat2obs (feats); disp("Observation Transformation finished") % convert features into observations
    [predsc, predst] = applymodel (model, obsc, obst); disp("Interaction Type Prediction finished") % apply model
    stats = statscalc (obsc, obst, predsc, predst, data, 1, options.BufferSize); disp("Stat Calculation finished") % calculate stats %buffer*2 is frame in .1s (default = 25)
    [types, typestotal] = analyseinteractions(stats, data, 0.2);disp("Interaction Analysis finished") % partnerthresh (default = 0.2) = percentual difference between a.i and c.i to detect Partner gradient
    % typestruct = evocalc (data, types, 1, 25);disp("Gradient Evolution Analysis finished")

beep on; beep; disp ("Calculation Task finished");

end
% Export

function exportResults(data, clno, segmentsbv, feats, stats, types, typestotal, graphIDs, segIDs, statIDs, typeIDs, exportFigFormat, printFormat, options)

    if options.GraphExport
        graphexport(data, segmentsbv, graphIDs, clno, exportFigFormat, printFormat);
        disp("Graph Export finished")
    end

    if options.SegExport
        segexport(data, segmentsbv, feats, segIDs, clno, exportFigFormat);
        disp("Segments Export finished")
    end

    if options.StatExport
        statexport(data, stats, statIDs, clno, exportFigFormat);
        disp("Stat Export finished")
    end

    if options.TypeExport
        typeexport(data, types, typestotal, typeIDs, clno, printFormat);
        disp("Interaction Type Export finished")
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