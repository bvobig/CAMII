# camii

[![DOI](https://zenodo.org/badge/1245913746.svg)](https://doi.org/10.5281/zenodo.20338644)

camii is a MATLAB function developed based on the theoretical framework presented in Vobig (2025).
The function analyzes dyadic piano improvisations provided as MIDI files containing two channels. It preprocesses the data using a modified version of the Music Therapy Toolbox (MTTB) and applies a supervised machine learning classifier together with a manually defined decision tree to segment and identify interaction types throughout the improvisation.
The interaction analysis is based on the concepts of Relational Direction and Relational Proximity.

Optional input arguments allow exporting different graphical and statistical representations in various formats.

## Requirements

The following software and toolboxes are required:
MATLAB (developed and tested with MATLAB R2024b)
Statistics and Machine Learning Toolbox
Signal Processing Toolbox
External Dependencies

## External Repositories and Functions needed:

mttblight2: modified version of the Music Therapy Toolbox (MTTB) provided by Olivier Lartillot (is contained in repository)
miditoolbox: MIDI analysis toolbox by Tuomas Eerola and Petri Toiviainen (https://github.com/miditoolbox/1.1)
InterX: MATLAB function for curve intersection detection (https://de.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections)
export_fig: MATLAB figure export utility by Yair Altman (https://github.com/altmany/export_fig/tree/master)

## Installation

CAMII can be used either through the provided MATLAB Project or by manually configuring the MATLAB path.

### Recommended: MATLAB Project

Open the provided MATLAB Project (`camii.prj`).
The project automatically configures all required paths and dependencies, if available.

### Manual Setup

If you do not use the MATLAB Project, add the required dependencies with all subfolders within the camii folder to the MATLAB path manually:

camii/mttblight
camii/external/miditoolbox
camii/external/export_figure
camii/external/InterX

## Input Requirements
MIDI file (.mid)
Exactly two MIDI channels representing the two performers

## Example Usage
results = camii("example.mid","ExampleSession");

### Example with optional exports:
results = camii("example.mid", "ExampleSession", GraphExport=true, ExportFormat="png");

## References

Erkkilä, J., Lartillot, O., Luck, G., Riikkilä, K., & Toiviainen, P. (2004). Intelligent Music Systems in Music Therapy. Music Therapy Today, 5(5).

Vobig, B. (2025). A Computational Approach to Interaction Type Analysis of Music Therapy Improvisations. Music & Science, 8. https://doi.org/10.1177/20592043251329233
