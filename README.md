# CAMII

**Computational Assessment of Musical Interaction in Clinical Improvisation**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20338644.svg)](https://doi.org/10.5281/zenodo.20338644)

CAMII is a MATLAB-based analysis framework developed from the theoretical model presented in Vobig (2025).

The software analyses dyadic piano improvisations provided as MIDI files containing two performer channels. The data are preprocessed using a modified version of the Music Therapy Toolbox (MTTB), after which a supervised machine learning classifier and a manually defined decision tree are applied to identify and classify interaction patterns throughout the improvisation.

The interaction analysis is based on the concepts of **Relational Direction** and **Relational Proximity**.

Optional export settings allow the generation of graphical and statistical representations in various formats.

---

# Requirements

The following software and toolboxes are required:

* MATLAB (developed and tested with MATLAB R2026a)
* Statistics and Machine Learning Toolbox
* Signal Processing Toolbox

External dependencies:

* mttblight2
* MIDI Toolbox
* InterX

---

# Compatibility

CAMII has been developed and tested with:

* MATLAB R2026a
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

Execute the installer under the current CAMII release Assets ("Releases"):

CAMII_v.X.X.X_FullInstaller.exe
CAMII_v.X.X.X_WebInstaller.exe

The installer will first install the required MATLAB Runtime and subsequently install the CAMII application. Depending on the choice, the installation file includes a complete local runtime of MATLAB (FullInstaller) or downloads and installs the current runtime version via web (WebInstaller). 

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
│   └── InterX/
```

---

# External Dependencies

## mttblight2

Modified version of the Music Therapy Toolbox (MTTB), provided by Olivier Lartillot and included with permission for use within CAMII.

Included in this repository.

---

## MIDI Toolbox

MIDI analysis toolbox developed by Tuomas Eerola and Petri Toiviainen.

Repository:

https://github.com/miditoolbox/1.1

Reference:

Toiviainen, P., & Eerola, T. (2016). MIDI Toolbox 1.1. URL: https://github.com/miditoolbox/1.1

https://github.com/miditoolbox/1.1

---

## InterX

MATLAB function for curve intersection detection.

Repository:

https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections

Reference:

NS (2026). Curve intersections (https://ch.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections), MATLAB Central File Exchange. Retrieved June 5, 2026.

https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections

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
results = camii(midi_file)
```

Example:

```matlab
results = camii( ...
    midi_file = "example.mid", ...
    clno = "ExampleSession", ...
    export_graphs = true, ...
    GraphFeatures = ["MeanVelocity","Density"], ...
    ExportFormat = "png", ...
    buffer_size = 10);
```

## Inputs

### midi_file

Path or filename of the MIDI file to be analysed.

### clno

Optional Identifier used for naming exported files. If no identifier is defined, files are named using the current time (yyyyMMdd_HHmmss)

```matlab
clno = "ExampleSession"
```

### Optional Export Parameters

Export options can be activated individually:

```matlab
export_graphs = true
export_segments = true
export_stats = true
export_types = true
export_results = true
```

Additional options allow selection of:

* Exported Features (Default = "All"), Samples: 

```matlab
options.GraphFeatures = ["AC","Density"]
options.SegFeatures = "All"
options.StatFeatures = ["Dissonance, MeanVelocity, Tempo"] 
options.TypeFeatures = "MeanPitch"
```

* Image Formats (combined graphics are only exported as .png)

```matlab
options.ExportFormat = "png" (default) or "jpg", "eps", "svg"
```

* Table Formats (Default = "xlsx")

```matlab
options.TableFormat = "xlsx" (or "csv")
```

### Feature Selection

Avaliable features for analysis and export include all twelve features computable by the MTTB: 

* AC
* Articulation
* Density
* Dissonance
* Duration
* Majorness
* MeanPitch
* MeanVelocity
* Minorness
* StandardPitchDeviation
* Tempo
* Tonality 

---

### buffer_size

The `buffer_size` parameter controls the slider length used for profile assignment.

The value is specified in units of 0.1 seconds.

The default value is:

```matlab
buffer_size = 25
```

which corresponds to an effective analysis window of 5 seconds.

Smaller values increase temporal sensitivity, while larger values produce more stable and global interaction profiles.

---

### partner_threshold

The `partner_threshold` defines the maximum difference between Follower and Leader proportions allowed to detect the Partner gradient for the current analysis frame.

The value is specified in decimal percentage, so that 0.2 represents a margin of 20%.

The default value is:

```matlab
partner_threshold = 0.2
```

Smaller values treat the Partner gradient as more exclusive, while larger values allow more margin to detect the Partner gradient.

---

### zero_threshold

The `zero_threshold` parameter defines the maximum individual intensity of movement to be registered still as neutral movement. Individual intensity is calculated as the percentage of the individual players range moved per second.

The value is specified in decimal percentage.

The default value is:

```matlab
zero_threshold = 0.01
```

which represents a maximum intensity of 1% per second allowed to be detected as neutral movement.

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
The additional options are split for each function and can be applied as within the comprehensive function demonstrated above. 

---

## Analysis

```matlab
results = camii_analysis(midi_file, options)
```

Example:

```matlab
results = camii_analysis( ...
    midi_file = "example.mid", ...
    buffer_size = 25, ...
    partner_threshold = 0.2, ...
    zero_threshold = 0.01);
```

The output contains all intermediate and final analysis results required for subsequent export operations.

---

## Export

```matlab
camii_export(results, options)
```

Example:

```matlab
camii_export( ...
    results, ...
    clno = "ExampleSession", ...
    export_types = true, ...
    TypeFeatures = ["Dissonance","MeanPitch"], ...
    export_results = true, ...
    TableFormat = "csv");
```

The export function requires:

* a results structure produced by `camii_analysis`

Optional arguments (as in the comprehenive function) determine:

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

# Citation

If you use CAMII in research, please cite:

> Vobig, B. (2026). *CAMII: Computational Assessment of Musical Interaction in Clinical Improvisation* (Version v0.1.1). Zenodo. https://doi.org/10.5281/zenodo.20338644

---

# License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).

> CAMII: A tool for the Computational Assessment of Musical Interaction in clinical Improvisations
> Copyright (C) <2026>  <Bastian Vobig> 
> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU General Public License as published by
> the Free Software Foundation, either version 3 of the License, or
> (at your option) any later version.
>
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU General Public License for more details.
>
> You should have received a copy of the GNU General Public License
> along with this program.  If not, see <https://www.gnu.org/licenses/>.

See the [LICENSE](LICENSE) file for more details.

The repository also contains third-party components distributed under their respective compatible licenses. Third-party license information is provided in
[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).
