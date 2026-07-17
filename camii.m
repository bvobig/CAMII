function [results] = camii(midi_file, options)
%%
    arguments
        midi_file (1,:) string
        
        options.clno (1,:) string = string(datetime("now", "Format", 'yyyyMMdd_HHmmss'));

        options.export_graphs (1,1) logical = false
        options.export_segments (1,1) logical = false
        options.export_stats (1,1) logical = false
        options.export_types (1,1) logical = false
        options.export_results (1,1) logical = false

        options.BufferSize (1,1) double = 25
        options.ExportFormat string{mustBeMember(options.ExportFormat, ["png", "jpg", "eps", "svg"])} = "png"

        options.GraphFeatures string{mustBeMember(options.GraphFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.SegFeatures string {mustBeMember(options.SegFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"   
        options.StatFeatures string {mustBeMember(options.StatFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.TypeFeatures string {mustBeMember(options.TypeFeatures, ["All","AC","Articulation","Density", "Dissonance","Duration","Majorness", "MeanPitch","MeanVelocity","Minorness", "StandardPitchDeviation","Tempo","Tonality"])} = "All"
        options.TableFormat string {mustBeMember(options.TableFormat, ["xlsx", "csv"])} = "xlsx"

        options.OutputFolder string = ""

    end

%%

if strlength(options.clno) == 0
    options.clno = string(datetime("now","Format","yyyyMMdd_HHmmss"));
end

outdir = options.OutputFolder;

    if strlength(outdir) == 0
        outdir=pwd;
    end
    
    if ~exist(outdir, 'dir')
        mkdir(outdir)
    end

% Check Dependencies

     if isempty(which('mttb_light2'))
        error('camii:MissingDependency', ...
            'Required function mttb_light2.m could not be found on the MATLAB path.')
    end
    
    if isempty(which('InterX'))
        error('camii:MissingDependency', ...
            'Required function InterX.m could not be found on the MATLAB path.')
    end
    
    projectRoot = fileparts(mfilename('fullpath'));
    
    miditoolboxDir = fullfile(projectRoot,'external','miditoolbox');
    exportFigDir   = fullfile(projectRoot,'external','export_figure');
    mttbLightDir   = fullfile(projectRoot,'mttblight');
    
    if ~isfolder(miditoolboxDir)
        error('camii:MissingDependency', ...
            'Folder external/miditoolbox is missing.')
    end
    
    if ~isfolder(exportFigDir)
        error('camii:MissingDependency', ...
            'Folder external/export_figure is missing.')
    end
    
    if ~isfolder(mttbLightDir)
        error('camii:MissingDependency', ...
            'Folder mttblight is missing.')
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

%%
load ("camii_model.mat", "camii_model") % load ML model
%%
improdata = mttb_light2(midi_file, 0.1, 6);
[data, segments, feats, stats, types, typestotal] = analysis (improdata, camii_model, options); %Analyse Data

results.typestotal=typestotal; % Gather Results
results.types=types;

exportResults(data, segments, feats, stats, types, typestotal, graphIDs, segIDs, statIDs, typeIDs, results, outdir, options) %Export Data

% Calculation

function [data, segments, feats, stats, types, typestotal] = analysis (mttbdata, model, options) %typestruct

    data = preproc(mttbdata, 1); disp("1/7 Preprocessing finished")% preprocess mttb data
    segments = segment_data(data, 3); disp("2/7 segmentation finished") % segment data (data, bend_threshold)
    feats = featcalc(data, segments, 0.01); disp("3/7 Feature Calculation finished") % calculate features (data, segments, zerothresh)
    [obsc, obst] = feat2obs (feats); disp("4/7 Observation Transformation finished") % convert features into observations
    [predsc, predst] = applymodel (model, obsc, obst); disp("5/7 Interaction Type Prediction finished") % apply model
    stats = statscalc (obsc, obst, predsc, predst, data, 1, options.BufferSize); disp("6/7 Stat Calculation finished") % calculate stats %buffer*2 is frame in .1s (default = 25)
    [types, typestotal] = analyseinteractions(stats, data, 0.2);disp("7/7 Interaction Analysis finished") % partnerthresh (default = 0.2) = percentual difference between a.i and c.i to detect Partner gradient

beep on; beep; disp ("Calculation Task finished");

end
% Export

function exportResults(data, segments, feats, stats, types, typestotal, graphIDs, segIDs, statIDs, typeIDs, results, outdir, options)

    if options.export_graphs
        exportGraphsFn(data, segments, graphIDs, options.clno, options.ExportFormat, outdir);
        disp("Graph Export finished")
    end

    if options.export_segments
        exportSegsFn(data, segments, feats, segIDs, options.clno, options.ExportFormat, outdir);
        disp("Segments Export finished")
    end

    if options.export_stats
        exportStatsFn(data, stats, statIDs, options.clno, options.ExportFormat, outdir);
        disp("Stat Export finished")
    end

    if options.export_types
        exportTypesFn(data, types, typestotal, typeIDs, options.clno, options.ExportFormat, outdir);
        disp("Interaction Type Export finished")
    end

    if options.export_results
        exportResultsFn(results, options.clno, options.TableFormat, outdir);
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