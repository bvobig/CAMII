function [results] = camii_analysis(midi_file, options)
%%
    arguments
        midi_file (1,:) string
        options.buffer_size (1,1) double = 25
        options.zero_threshold (1,1) double = 0.01
        options.partner_threshold (1,1) double = 0.2
    end

%%

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

load ("camii_model.mat", "camii_model") % load ML model

%%
improdata = mttb_light2(midi_file, 0.1, 6);
[data, segments, feats, stats, types, typestotal] = analysis (improdata, camii_model, options); %Analyse Data

% Gather Results

results.data=data; 
results.segments=segments;
results.feats=feats;
results.stats=stats;
results.types=types;
results.typestotal=typestotal;

% Calculation

function [data, segments, feats, stats, types, typestotal] = analysis (mttbdata, model, options) %typestruct

    data = preproc(mttbdata, 1); disp("1/7 Preprocessing finished")% preprocess mttb data
    segments = segment_data(data, 1); disp("2/7 segmentation finished") % segment data (data, bend_threshold)
    feats = featcalc(data, segments, options.zero_threshold); disp("3/7 Feature Calculation finished") % calculate features (data, segments, zerothresh)
    [obsc, obst] = feat2obs (feats); disp("4/7 Observation Transformation finished") % convert features into observations
    [predsc, predst] = applymodel (model, obsc, obst); disp("5/7 Interaction Type Prediction finished") % apply model
    stats = statscalc (obsc, obst, predsc, predst, data, 1, options.buffer_size); disp("6/7 Stat Calculation finished") % calculate stats %buffer*2 is frame in .1s (default = 25)
    [types, typestotal] = analyseinteractions(stats, data, options.partner_threshold);disp("7/7 Interaction Analysis finished") % partnerthresh (default = 0.2) = percentual difference between a.i and c.i to detect Partner gradient

    beep on; beep; disp ("Calculation Task finished");
    
    end
end