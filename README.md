# CAMII

**Computational Assessment of Musical Interaction in Clinical Improvisation**

[![DOI](https://zenodo.org/badge/1245913746.svg)](https://doi.org/10.5281/zenodo.20338644)

CAMII is a MATLAB-based analysis framework developed from the theoretical model presented in Vobig (2025).

The software analyzes dyadic piano improvisations provided as MIDI files containing two performer channels. The data are preprocessed using a modified version of the Music Therapy Toolbox (MTTB), after which a supervised machine learning classifier and a manually defined decision tree are applied to identify and classify interaction patterns throughout the improvisation.

The interaction analysis is based on the concepts of **Relational Direction** and **Relational Proximity**.

Optional export settings allow the generation of graphical and statistical representations in various formats.

---

# Requirements

The following software and toolboxes are required:

* MATLAB (developed and tested with MATLAB R2024a)
* Statistics and Machine Learning Toolbox
* Signal Processing Toolbox

External dependencies:

* mttblight2
* MIDI Toolbox
* InterX
* export_fig

---

# Compatibility

CAMII has been developed and tested with:

* MATLAB R2024a
* Windows 11

The standalone application is currently available for Windows systems only.

---

# Input Requirements

CAMII requires:

* MIDI file (`.mid`)
* Exactly two MIDI channels representing the two performers
* Channel 1: Client
* Channel 2: Therapist

---

# Installation

CAMII can be used either through the standalone application or directly within MATLAB.

## Recommended: Standalone Application

Execute the installer (`camiiInstaller.exe`).

The installer will first install the required MATLAB Runtime and subsequently install the CAMII application.

The application provides functionality for:

* importing MIDI files
* analysing improvisation data
* interactively exploring results
* exporting visualisations and statistical summaries

These functions are organised into separate tabs within the application interface.

---

## Manual Setup in MATLAB

If you prefer to use CAMII directly within MATLAB, add the CAMII folder and all required dependency folders (including subfolders) to the MATLAB search path.

The repository already contains a modified version of the Music Therapy Toolbox (`mttblight2`), provided and licensed for use by Olivier Lartillot.

The remaining dependencies must be downloaded separately from MATLAB File Exchange or GitHub.

The following folder structure is recommended:

```text
camii/
├── mttblight2/
├── external/
│   ├── miditoolbox/
│   ├── export_fig/
│   └── InterX/
```

---

# External Dependencies

## mttblight2

Modified version of the Music Therapy Toolbox (MTTB), provided by Olivier Lartillot.

Included in this repository.

---

## MIDI Toolbox

MIDI analysis toolbox developed by Tuomas Eerola and Petri Toiviainen.

Repository:

https://github.com/miditoolbox/1.1

Reference:

Toiviainen, P., & Eerola, T. (2016). *MIDI Toolbox (Version 1.1) [MATLAB]*.
https://github.com/miditoolbox/1.1

---

## InterX

MATLAB function for curve intersection detection.

Repository:

https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections

Reference:

NS. (2025). *Curve Intersections [MATLAB]*.
https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections

---

## export_fig

MATLAB figure export utility developed by Yair Altman and Oliver Woodford.

Repository:

https://github.com/altmany/export_fig

Reference:

Altman, Y., & Woodford, O. J. (2014). *export_fig [MATLAB]*.
https://github.com/altmany/export_fig/releases/tag/v3.48

---

# Usage

CAMII can either be used through the standalone application or directly within MATLAB.

For MATLAB usage, CAMII is available as:

* a comprehensive single-function workflow (`camii.m`)
* separate analysis and export functions (`camii_analysis.m` and `camii_export.m`)

---

# Comprehensive Function Workflow

The comprehensive `camii` function performs both analysis and export operations.

Basic syntax:

```matlab
results = camii(midi_file, clno)
```

Example:

```matlab
results = camii( ...
    "example.mid", ...
    "ExampleSession", ...
    export_graphs=true, ...
    GraphFeatures=["MeanVelocity","Density"], ...
    ExportFormat="png", ...
    BufferSize=25);
```

## Inputs

### midi_file

Path or filename of the MIDI file to be analysed.

### clno

Identifier used for naming exported files.

### Optional Export Parameters

Export options can be activated individually:

```matlab
export_graphs=true
export_segments=true
export_stats=true
export_types=true
export_results=true
```

Additional options allow selection of:

* exported features
* image formats
* table formats

---

## BufferSize

The `BufferSize` parameter controls the slider length used for profile assignment.

The value is specified in units of 0.1 seconds.

The default value is:

```matlab
BufferSize = 25
```

which corresponds to an effective analysis window of 5 seconds.

Smaller values increase temporal sensitivity, while larger values produce more stable and global interaction profiles.

---

## Output

The function returns a structured results object containing:

* processed feature data
* segment information
* statistical summaries
* interaction type evolution
* interaction type distributions

Most importantly:

```matlab
results.types
```

contains the interaction type assigned at each time point, while

```matlab
results.typestotal
```

contains the overall distribution of interaction types across the improvisation.

> **Warning**
>
> Segment export may require considerable processing time because all identified segments are exported individually.

> **Warning**
>
> By default, export functions operate on all available features. This may generate a large number of figures. Specifying only the required features is recommended.

---

# Split Function Workflow

Instead of using the comprehensive workflow, CAMII can be applied using separate analysis and export functions.

This approach allows repeated visualisation and export of results without recalculating the improvisation.

---

## Analysis

```matlab
results = camii_analysis(midi_file)
```

Example:

```matlab
results = camii_analysis( ...
    "example.mid", ...
    BufferSize=25);
```

The output contains all intermediate and final analysis results required for subsequent export operations.

---

## Export

```matlab
camii_export(results, clno)
```

Example:

```matlab
camii_export( ...
    results, ...
    "ExampleSession", ...
    export_types=true, ...
    TypeFeatures=["Dissonance","MeanPitch"], ...
    export_results=true, ...
    TableFormat="csv");
```

The export function requires:

* a results structure produced by `camii_analysis`
* an identifier (`clno`) used for naming exported files

Optional arguments determine:

* which result types are exported
* which musical features are included
* graphical output format
* table output format

> **Warning**
>
> Segment export may require considerable processing time because all identified segments are exported individually.

> **Warning**
>
> By default, export functions operate on all available features. This may generate a large number of figures. Specifying only the required features is recommended.

---

# Known Limitations

* Only MIDI files containing exactly two channels are supported.
* Channel assignment is fixed:

  * Channel 1 = Client
  * Channel 2 = Therapist
* The method was developed and validated using piano improvisation recordings.
* The standalone application is currently available for Windows systems only.

---

# Citation

If you use CAMII in research, please cite:

> Vobig, B. (2026). *CAMII: Computational Assessment of Musical Interaction in Clinical Improvisation* (Version v0.1.1). Zenodo. https://doi.org/10.5281/zenodo.20338644

---

# License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).

See the LICENSE file for details.

The repository also contains third-party components distributed under their respective compatible licenses.
