
# Introduction

These scripts were used to do some preliminary analyses in the multi flip angle data shared by University of Alahabad.

The scripts are created with the following in mind:

1) PRJDIR contains the project directory

2) Within the project directory data is expected to reside in folder PrcsData

3) Inside PrcsData there is one directory per subject

4) Original EPI and T1 Data are expected to be in D00_OriginalData

5) Preprocessing of T1 datasets will occur in D01_Anatomical

6) Preprocessing of EPI data will occur in a different directory per flip angle : D03_Preproc_NoRICOR_FIR_${FA}

7) There are two type of scripts: bash scripts and jupyter notebooks

# How to run the scripts

Scripts are expected to be run in order, e.g., FA02_XXX, FA03_XX, etc.

Here is a basic description of each script set.

1) **FA02_Preproc_Anat**: This script set will pre-process the anatomical scans. This includes skull striping, bias correction, non-linear transformation to MNI space and tissue segmentation.

2) **FA03_PrepareRefVols4Alignment**: This script set will generate an epi reference volume per EPI run. This refernece volume will be a bias corrected version of the first volume of each run.

3) **FA04_Preproc_fMRI_NoRICOR_PerRun_FIR**: This script calls afni_proc to generate pre-processing scripts for each run separately. We will do analyses in original EPI space to minimize partial voluming. This script will do (among other things), the following: time shift correction, motion correction, compute registration to T1, spatial smoothing, create of masks for different tissues, and nuisance regression.

4) **FA05_CreateNiis_and_Masks**: This script set does a few extra operations following afni_proc. Those include: transformation of some HEAD/BRIK files into nifti (so that the can be loaded in Python later), aligment of 100 and 200 ROI Shaefer atlas to each fully pre-processed EPI dataset, alignment of 7 and 17 network yeo atlas to each fully pre-processed EPI dataset.

5) **FA06a_ComputeTSNR_perTissue_OrigMethod**: This script set computes TSNR in GM, WM, CSF (and eroded versions of these masks). It computes the TSNR after motion correction, spatial smoothing and nuisance regression.
  
6) **FA07a_Compute_3dTCorrMaps**: This script set computes maps of voxel-wise connectivity using AFNI program 3dTcorrmap.

7) **FA07b_Compute_3dTCorrMaps_ShowResults_AvgMaps**: This script set will bring the maps obtained in 6) to MNI space, so that we can generate an average connectivity map across all subjects in 8).

8) **FA07c_Compute_3dTCorrMaps_AvgAcrossSubject.sh**: This script averages all the subject individual voxel-wise connectivity maps

9) **FA07d_Voxelwise_Connectivity_Results_GM**: This notebook shows summary figures with changes in voxel-wise connectivity across the whole GM ribbon. It also include some basic preliminary statistical analyses.

# Instructions for bash scripts

Bash scripts were created to conduct analyses in the biowulf cluster. For that reason, for every step you can find three different scripts:

1) SCRIPT_NAME.sh: This is the main script that perform whatever actions are needed for a given dataset (e.g., a given T1 or EPI scan)

2) SCRIPT_NAME.CreateSwarm.sh: This script will create a swarm file with all the different calls to SCRIPT_NAME.sh so that all datasets are analyzed

3) SCRIPT_NAME.SWARM.sh: This file contains one call to SCRIPT_NAME.sh per dataset. This file is automatically created by SCRIPT_NAME.CreateSwarm.sh

If working on a high computing cluster with swarm, these scripts should work right away. If working on a single computer, you can run SCRIPT_NAME.SWARM.sh, which should analyze each dataset sequentially. (this may take a lot of time).

Many scripts contain a variable PRJDIR that tells the scripts what is the project directory. Make sure to change this variable to the value on your system before running the scripts.
 
# Instructions for Jupyter Notebooks

# Additional Files

This repository contains atlas files for the Schaefer Atlas and the Yeo Atlas. Those files were copied from the following publicly available repository (https://github.com/ThomasYeoLab/CBIG)
