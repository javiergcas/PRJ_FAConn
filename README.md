
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

# Instructions for bash scripts

Bash scripts were created to conduct analyses in the biowulf cluster. For that reason, for every step you can find three different scripts:

1) SCRIPT_NAME.sh: This is the main script that perform whatever actions are needed for a given dataset (e.g., a given T1 or EPI scan)

2) SCRIPT_NAME.CreateSwarm.sh: This script will create a swarm file with all the different calls to SCRIPT_NAME.sh so that all datasets are analyzed

3) SCRIPT_NAME.SWARM.sh: This file contains one call to SCRIPT_NAME.sh per dataset. This file is automatically created by SCRIPT_NAME.CreateSwarm.sh

If working on a high computing cluster with swarm, these scripts should work right away. If working on a single computer, you can run SCRIPT_NAME.SWARM.sh, which should analyze each dataset sequentially. (this may take a lot of time).

Many scripts contain a variable PRJDIR that tells the scripts what is the project directory. Make sure to change this variable to the value on your system before running the scripts.
 
# Instructions for Jupyter Notebooks


