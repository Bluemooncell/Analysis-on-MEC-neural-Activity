# README: Analysis Scripts for MEC Neuronal Activity 
This repository contains the analysis scripts and methodological documentation for the manuscript.
Most of the data preprocessing, cell selection, and statistical analyses were performed using MATLAB. A subset of dimensionality reduction analysis using Linear Discriminant Analysis (LDA) was conducted in Python.
Due to the file size limitation, the sample data available for the operation of the following script is placed at https://zenodo.org/records/15656068
---

## 1. System Requirements

- **MATLAB**: R2021a or newer  
  Required Toolboxes:
  - Signal Processing Toolbox
  - Statistics and Machine Learning Toolbox

- **Python**: Version ≥ 3.9 (only required for LDA projection)
  Recommended packages: `numpy`, `pandas`, `scikit-learn`, `matplotlib`, `h5py`, `seaborn`

- **Operating System**: Windows 10 / macOS / Ubuntu

- **Third-party tools used**:
  - [Suite2P](https://github.com/MouseLand/suite2p): For calcium imaging motion correction and ROI extraction  
  - [DeepLabCut (DLC)](https://github.com/DeepLabCut/DeepLabCut): For behavioral tracking  
  - [CellReg](https://github.com/zivlab/CellReg): For cross-day cell registration  

---

## 2. Description of Data and Script Structure

### 2.1 Data Overview

Our raw dataset includes two types of recordings:
- **CellVideo**: two-photon calcium imaging videos
- **MiceVideo**: behavioral videos from overhead cameras

Due to the large size of the original video data and sample scale, we provide a demo dataset from one mouse (**#321**, Exp.2) as a representative example. The example files are stored in the `Example_Data` directory.

- `321-20250311-2` corresponds to the baseline light session (L2)
- `321-20250311-3` corresponds to the light session after whisker trimming (LW2)

These folders each include the following:
- `Fall.mat`: output file from Suite2P containing ROI and raw fluorescence traces
- `behav.mat`: file containing behavioral variables processed from DLC tracking

---

### 2.2 Calcium Imaging and Behavioral Processing

The calcium preprocessing and cell segmentation scripts are adapted from and based on the following studies:

- Zong et al., *Cell*, 2022  
- Friedrich & Paninski, *Adv Neur In*, 2016  
- Pnevmatikakis et al., *Neuron*, 2016

Scripts are located in:

- `Tools/` and `MINI2P_toolbox/`: helper functions for field detection, MVL (mean vector length), and grid score calculations...
- `STEP1_DLC_suite2p/`:
  - `suite2p_dFF_deconvolution.m`: Converts `Fall.mat` to deconvolved neural activity (`NeuronActivity.mat`)
  - `TrackingAnalysis.m`: Converts DLC `.csv` outputs into `behav.mat` files

---

### 2.3 Shuffle and Cell-Type Identification

Once you obtain both `NeuronActivity.mat` and `behav.mat` for each session, the next steps are:

- Run `shuffle_onesession_ratemap.m` in the `STEP2_Shuffle/` directory to calculate spatial tuning maps and generate shuffled datasets (`shuffle_ratemap_new2.mat` for each session)
  
- Then use the scripts in `STEP3_CellDetect/` to:
  - Identify grid cells, head direction (HD) cells, and other spatially modulated cells
  - Find rate maps, tuning curves, grid scores, MVLs, and spatial information for each cell

---

### 2.4 Further Analysis and Dimensionality Reduction

Additional analyses and visualizations are available in `STEP4_FurtherAnalysis/`, including:

- GMM clustering (using MATLAB’s `fitgmdist` function)
  - Example: clustering HD cells using extracted feature matrix `X`, stored in the same folder

- LDA-based projection and cross-session decoding:
  - Implemented in Python (`run_all_traj_crosssession.py`)
  - Sample input data provided for **Mouse #49 (Exp.1)** under `Example_Data/`
---

## 3. Getting Started

### Step-by-step:

1. Install MATLAB (with required toolboxes) and Python ≥ 3.9 (with required packages)
2. Find the sample data (`Fall.mat`, `behav.mat`) under the corresponding mouse/session folder (Example:'321-20250311-2')
3. Follow the folder structure and script order to identify spatally modulated cells and thier tuning properties:
   - STEP1 → STEP2 → STEP3
4. For Python-based LDA projection, run 'run_all_traj_crosssession.py' based on the provided data (Example:'49-20230127')

# Whisker-Related Analysis

Analyses related to whisker-related experiments are stored separately in the "Example_Data" and "whisker" directories. The example data includes two datasets:

322-20250324: raw data from the texture discrimination task, used in Figure S18
322-20250327: data collected from high-speed top-down whisker tracking, used to extract whisker-responsive neurons based on calcium activity, as shown in Figure S17

Scripts for whisker-based analysis include:
texture_svm_alltime.m: performs SVM decoding for texture classification
Shuffle_singlespike_prepostEvent.m: conducts a shuffle-based analysis to identify neurons with selective responses during texture presentations
calculate_whisker_movement.m: identifiy whisker-responsive cells based on the correlation between whisker movement and  calcium signals (Figure S17)

* All the individual script can be run to completion within a few hours.
