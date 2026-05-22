camii

camii is a MATLAB function developed based on the theoretical framework presented in Vobig (2025).
The function analyzes dyadic piano improvisations provided as MIDI files containing two channels. It preprocesses the data using a modified version of the Music Therapy Toolbox (MTTB) and applies a supervised machine learning classifier together with a manually defined decision tree to segment and identify interaction types throughout the improvisation.
The interaction analysis is based on the concepts of Relational Direction and Relational Proximity.

Optional input arguments allow exporting different graphical and statistical representations in various formats.

Requirements

The following software and toolboxes are required:
MATLAB (developed and tested with MATLAB R2024b)
Statistics and Machine Learning Toolbox
Signal Processing Toolbox
External Dependencies

camii depends on the following external repositories and functions:

mttblight2: modified version of the Music Therapy Toolbox (MTTB) provided by Olivier Lartillot
miditoolbox: MIDI analysis toolbox by Tuomas Eerola and Petri Toiviainen (https://github.com/miditoolbox/1.1)
InterX: MATLAB function for curve intersection detection (https://de.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections)
export_fig: MATLAB figure export utility by Yair Altman (https://github.com/altmany/export_fig/tree/master)

Input Requirements
MIDI file (.mid)
Exactly two MIDI channels representing the two performers

Example Usage
results = camii("example.mid","ExampleSession");

Example with optional exports:
results = camii("example.mid", "ExampleSession", GraphExport=true, ExportFormat="png");

References

Erkkilä, J., Lartillot, O., Luck, G., Riikkilä, K., & Toiviainen, P. (2004). Intelligent Music Systems in Music Therapy. Music Therapy Today, 5(5).

Vobig, B. (2025). A Computational Approach to Interaction Type Analysis of Music Therapy Improvisations. Music & Science, 8. https://doi.org/10.1177/20592043251329233
