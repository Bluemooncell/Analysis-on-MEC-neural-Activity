# README: Analysis Scripts for MEC Neuronal Activity 
This repository contains the analysis scripts and methodological documentation for the manuscript.
Most of the data preprocessing, cell selection, and statistical analyses were performed using MATLAB. A subset of dimensionality reduction analysis using Linear Discriminant Analysis (LDA) was conducted in Python.

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

Due to the large size of the original video data and sample scale, we provide a demo dataset from one mouse (**#349**, E2M07) as a representative example. The example files are stored in the `Example_Data` directory.

- `349-20251224-2` corresponds to the baseline dark session in E2
- `349-20251224-3` corresponds to the dark after whisker trimming (DW) in E2
- `349-20251224-4` corresponds to the wall removal session after whisker trimming (DWR') in E2

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

- LDA-based projection and cross-session decoding:
  - Implemented in Python (`run_all_traj_crosssession.py`)
  - Sample input data provided for **Mouse #49 (E1M03)** under `Example_Data/`
---

## 3. Getting Started

### Step-by-step:

1. Install MATLAB (with required toolboxes) and Python ≥ 3.9 (with required packages)
2. Find the sample data (`Fall.mat`, `behav.mat`) under the corresponding mouse/session folder (Example:'321-20250311-2')
3. Follow the folder structure and script order to identify spatally modulated cells and thier tuning properties:
   - STEP1 → STEP2 → STEP3
4. For Python-based LDA projection, run 'run_all_traj_crosssession.py' based on the provided data (Example:'49-20230127')
