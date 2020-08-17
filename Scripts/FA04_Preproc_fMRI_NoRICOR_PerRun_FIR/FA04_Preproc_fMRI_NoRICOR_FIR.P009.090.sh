#!/bin/tcsh -xef

echo "auto-generated by afni_proc.py, Sun Aug 16 20:28:18 2020"
echo "(version 7.12, April 14, 2020)"
echo "execution started: `date`"

# to execute via tcsh: 
#   tcsh -xef FA04_Preproc_fMRI_NoRICOR_FIR.P009.090.sh |& tee output.FA04_Preproc_fMRI_NoRICOR_FIR.P009.090.sh
# to execute via bash: 
#   tcsh -xef FA04_Preproc_fMRI_NoRICOR_FIR.P009.090.sh 2>&1 | tee output.FA04_Preproc_fMRI_NoRICOR_FIR.P009.090.sh

# =========================== auto block: setup ============================
# script setup

# take note of the AFNI version
afni -ver

# check that the current AFNI version is recent enough
afni_history -check_date 27 Jun 2019
if ( $status ) then
    echo "** this script requires newer AFNI binaries (than 27 Jun 2019)"
    echo "   (consider: @update.afni.binaries -defaults)"
    exit
endif

# the user may specify a single subject to run with
if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = P009
endif

# assign output directory name
set output_dir = /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D03_Preproc_NoRICOR_FIR_090

# verify that the results directory does not yet exist
if ( -d $output_dir ) then
    echo output dir "$subj.results" already exists
    exit
endif

# set list of runs
set runs = (`count -digits 2 1 1`)

# create results and stimuli directories
mkdir $output_dir
mkdir $output_dir/stimuli

# copy anatomy to results dir
3dcopy                                                                           \
    /data/SFIM_FlipAngle/PRJ_FAConn/PrcsData/P009/D01_Anatomical/anatSS.P009.nii \
    $output_dir/anatSS.P009

# copy over the external align_epi_anat.py EPI volume
3dbucket -prefix $output_dir/ext_align_epi \
    '/data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D00_OriginalData/P009_fMRI_090.RefVol.bc+orig[0]'

# copy anatomical follower datasets into the results dir
3dcopy                                                                            \
    /data/SFIM_FlipAngle/PRJ_FAConn/PrcsData/P009/D00_OriginalData/P009_Anat+orig \
    $output_dir/copy_af_anat_w_skull

# copy external -tlrc_NL_warped_dsets datasets
3dcopy                                                                                \
    /data/SFIM_FlipAngle/PRJ_FAConn/PrcsData/P009/D01_Anatomical/anatQQ.P009.nii      \
    $output_dir/anatQQ.P009
3dcopy                                                                                \
    /data/SFIM_FlipAngle/PRJ_FAConn/PrcsData/P009/D01_Anatomical/anatQQ.P009.aff12.1D \
    $output_dir/anatQQ.P009.aff12.1D
3dcopy                                                                                \
    /data/SFIM_FlipAngle/PRJ_FAConn/PrcsData/P009/D01_Anatomical/anatQQ.P009_WARP.nii \
    $output_dir/anatQQ.P009_WARP.nii

# ============================ auto block: tcat ============================
# apply 3dTcat to copy input dsets to results dir,
# while removing the first 0 TRs
3dTcat -prefix $output_dir/pb00.$subj.r01.tcat                   \
    /data/SFIM_FlipAngle/PRJ_FAConn/PrcsData/P009/D00_OriginalData/P009_fMRI_090+orig'[0..$]'

# and make note of repetitions (TRs) per run
set tr_counts = ( 90 )

# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir


# ---------------------------------------------------------
# data check: compute correlations with spherical ~averages
@radial_correlate -nfirst 0 -do_clean yes -rdir radcor.pb00.tcat \
                  pb00.$subj.r*.tcat+orig.HEAD

# ========================== auto block: outcount ==========================
# data check: compute outlier fraction for each volume
touch out.pre_ss_warn.txt
foreach run ( $runs )
    3dToutcount -automask -fraction -polort 2 -legendre                     \
                pb00.$subj.r$run.tcat+orig > outcount.r$run.1D

    # censor outlier TRs per run, ignoring the first 0 TRs
    # - censor when more than 0.05 of automask voxels are outliers
    # - step() defines which TRs to remove via censoring
    1deval -a outcount.r$run.1D -expr "1-step(a-0.05)" > rm.out.cen.r$run.1D

    # outliers at TR 0 might suggest pre-steady state TRs
    if ( `1deval -a outcount.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
        echo "** TR #0 outliers: possible pre-steady state TRs in run $run" \
            >> out.pre_ss_warn.txt
    endif
end

# catenate outlier counts into a single time series
cat outcount.r*.1D > outcount_rall.1D

# catenate outlier censor files into a single time series
cat rm.out.cen.r*.1D > outcount_${subj}_censor.1D

# ================================= tshift =================================
# time shift data so all slice timing is the same 
foreach run ( $runs )
    3dTshift -tzero 0 -quintic -prefix pb01.$subj.r$run.tshift \
             -tpattern alt+z2                                  \
             pb00.$subj.r$run.tcat+orig
end

# --------------------------------
# extract volreg registration base
3dbucket -prefix vr_base pb01.$subj.r01.tshift+orig"[0]"

# ================================= align ==================================
# a2e: align anatomy to EPI registration base
# (new anat will be aligned and stripped, anatSS.P009_al_keep+orig)
align_epi_anat.py -anat2epi -anat anatSS.P009+orig   \
       -suffix _al_keep                              \
       -epi ext_align_epi+orig -epi_base 0           \
       -epi_strip 3dSkullStrip                       \
       -anat_has_skull no                            \
       -AddEdge -cost lpc+ZZ -giant_move -check_flip \
       -volreg off -tshift off

# ================================== tlrc ==================================

# nothing to do: have external -tlrc_NL_warped_dsets

# warped anat     : anatQQ.P009+tlrc
# affine xform    : anatQQ.P009.aff12.1D
# non-linear warp : anatQQ.P009_WARP.nii

# ================================= volreg =================================
# align each dset to base volume
foreach run ( $runs )
    # register each volume to the base image
    3dvolreg -verbose -zpad 1 -base vr_base+orig                              \
             -1Dfile dfile.r$run.1D -prefix pb02.$subj.r$run.volreg           \
             -cubic                                                           \
             pb01.$subj.r$run.tshift+orig
end

# make a single file of registration params
cat dfile.r*.1D > dfile_rall.1D

# create an anat_final dataset, aligned with stats
3dcopy anatSS.P009_al_keep+orig anat_final.$subj

# --------------------------------------
# create a TSNR dataset, just from run 1
3dTstat -mean -prefix rm.signal.vreg.r01 pb02.$subj.r01.volreg+orig
3dDetrend -polort 2 -prefix rm.noise.det -overwrite pb02.$subj.r01.volreg+orig
3dTstat -stdev -prefix rm.noise.vreg.r01 rm.noise.det+orig
3dcalc -a rm.signal.vreg.r01+orig                                             \
       -b rm.noise.vreg.r01+orig                                              \
       -expr 'a/b' -prefix TSNR.vreg.r01.$subj 

# -----------------------------------------
# warp anat follower datasets (non-linear)
3dNwarpApply -source copy_af_anat_w_skull+orig                                \
             -master anat_final.$subj+orig                                    \
             -ainterp wsinc5 -nwarp anatQQ.P009_WARP.nii anatQQ.P009.aff12.1D \
             anatSS.P009_al_keep_mat.aff12.1D                                 \
             -prefix follow_anat_anat_w_skull

# ---------------------------------------------------------
# data check: compute correlations with spherical ~averages
@radial_correlate -nfirst 0 -do_clean yes -rdir radcor.pb02.volreg            \
                  pb02.$subj.r*.volreg+orig.HEAD

# ================================== blur ==================================
# blur each volume of each run
foreach run ( $runs )
    3dmerge -1blur_fwhm 4.0 -doall -prefix pb03.$subj.r$run.blur \
            pb02.$subj.r$run.volreg+orig
end

# ================================== mask ==================================
# create 'full_mask' dataset (union mask)
foreach run ( $runs )
    3dAutomask -prefix rm.mask_r$run pb03.$subj.r$run.blur+orig
end

# create union of inputs, output type is byte
3dmask_tool -inputs rm.mask_r*+orig.HEAD -union -prefix full_mask.$subj

# ---- create subject anatomy mask, mask_anat.$subj+orig ----
#      (resampled from aligned anat)
3dresample -master full_mask.$subj+orig -input anatSS.P009_al_keep+orig \
           -prefix rm.resam.anat

# convert to binary anat mask; fill gaps and holes
3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+orig    \
            -prefix mask_anat.$subj

# compute tighter EPI mask by intersecting with anat mask
3dmask_tool -input full_mask.$subj+orig mask_anat.$subj+orig            \
            -inter -prefix mask_epi_anat.$subj

# compute overlaps between anat and EPI masks
3dABoverlap -no_automask full_mask.$subj+orig mask_anat.$subj+orig      \
            |& tee out.mask_ae_overlap.txt

# note Dice coefficient of masks, as well
3ddot -dodice full_mask.$subj+orig mask_anat.$subj+orig                 \
      |& tee out.mask_ae_dice.txt

# ---- segment anatomy into classes CSF/GM/WM ----
3dSeg -anat anat_final.$subj+orig -mask AUTO -classes 'CSF ; GM ; WM'

# copy resulting Classes dataset to current directory
3dcopy Segsy/Classes+orig .

# make individual ROI masks for regression (CSF GM WM and CSFe GMe WMe)
foreach class ( CSF GM WM )
   # unitize and resample individual class mask from composite
   3dmask_tool -input Segsy/Classes+orig"<$class>"                      \
               -prefix rm.mask_${class}
   3dresample -master pb03.$subj.r01.blur+orig -rmode NN                \
              -input rm.mask_${class}+orig -prefix mask_${class}_resam
   # also, generate eroded masks
   3dmask_tool -input Segsy/Classes+orig"<$class>" -dilate_input -1     \
               -prefix rm.mask_${class}e
   3dresample -master pb03.$subj.r01.blur+orig -rmode NN                \
              -input rm.mask_${class}e+orig -prefix mask_${class}e_resam
end

# create intersect mask WM_inFB from masks brain and WM
3dmask_tool -input full_mask.$subj+orig mask_WM_resam+orig              \
       -inter -prefix mask_inter_WM_inFB

# create intersect mask GM_inFB from masks brain and GM
3dmask_tool -input full_mask.$subj+orig mask_GM_resam+orig              \
       -inter -prefix mask_inter_GM_inFB

# create intersect mask CSF_inFB from masks brain and CSF
3dmask_tool -input full_mask.$subj+orig mask_CSF_resam+orig             \
       -inter -prefix mask_inter_CSF_inFB

# create intersect mask WMe_inFB from masks brain and WMe
3dmask_tool -input full_mask.$subj+orig mask_WMe_resam+orig             \
       -inter -prefix mask_inter_WMe_inFB

# create intersect mask GMe_inFB from masks brain and GMe
3dmask_tool -input full_mask.$subj+orig mask_GMe_resam+orig             \
       -inter -prefix mask_inter_GMe_inFB

# create intersect mask CSFe_inFB from masks brain and CSFe
3dmask_tool -input full_mask.$subj+orig mask_CSFe_resam+orig            \
       -inter -prefix mask_inter_CSFe_inFB

# ================================ regress =================================

# compute de-meaned motion parameters (for use in regression)
1d_tool.py -infile dfile_rall.1D -set_nruns 1                            \
           -demean -write motion_demean.1D

# compute motion parameter derivatives (for use in regression)
1d_tool.py -infile dfile_rall.1D -set_nruns 1                            \
           -derivative -demean -write motion_deriv.1D

# convert motion parameters for per-run regression
1d_tool.py -infile motion_demean.1D -set_nruns 1                         \
           -split_into_pad_runs mot_demean

1d_tool.py -infile motion_deriv.1D -set_nruns 1                          \
           -split_into_pad_runs mot_deriv

# create censor file motion_${subj}_censor.1D, for censoring motion 
1d_tool.py -infile dfile_rall.1D -set_nruns 1                            \
    -show_censor_count -censor_prev_TR                                   \
    -censor_motion 0.1 motion_${subj}

# combine multiple censor files
1deval -a motion_${subj}_censor.1D -b outcount_${subj}_censor.1D         \
       -expr "a*b" > censor_${subj}_combined_2.1D

# note TRs that were not censored
set ktrs = `1d_tool.py -infile censor_${subj}_combined_2.1D              \
                       -show_trs_uncensored encoded`

# ------------------------------
# run the regression analysis
3dDeconvolve -input pb03.$subj.r*.blur+orig.HEAD                         \
    -censor censor_${subj}_combined_2.1D                                 \
    -ortvec mot_demean.r01.1D mot_demean_r01                             \
    -ortvec mot_deriv.r01.1D mot_deriv_r01                               \
    -polort 2 -float                                                     \
    -num_stimts 0                                                        \
    -jobs 32                                                             \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                              \
    -x1D_uncensored X.nocensor.xmat.1D                                   \
    -fitts fitts.$subj                                                   \
    -errts errts.${subj}                                                 \
    -x1D_stop                                                            \
    -cbucket all_betas.$subj                                             \
    -bucket stats.$subj

# -- use 3dTproject to project out regression matrix --
#    (make errts like 3dDeconvolve, but more quickly)
3dTproject -polort 0 -input pb03.$subj.r*.blur+orig.HEAD                 \
           -censor censor_${subj}_combined_2.1D -cenmode NTRP            \
           -ort X.nocensor.xmat.1D -prefix errts.${subj}.tproject



# if 3dDeconvolve fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
endif


# display any large pairwise correlations from the X-matrix
1d_tool.py -show_cormat_warnings -infile X.xmat.1D |& tee out.cormat_warn.txt

# display degrees of freedom info from X-matrix
1d_tool.py -show_df_info -infile X.xmat.1D |& tee out.df_info.txt

# create an all_runs dataset to match the fitts, errts, etc.
3dTcat -prefix all_runs.$subj pb03.$subj.r*.blur+orig.HEAD

# --------------------------------------------------
# create a temporal signal to noise ratio dataset 
#    signal: if 'scale' block, mean should be 100
#    noise : compute standard deviation of errts
3dTstat -mean -prefix rm.signal.all all_runs.$subj+orig"[$ktrs]"
3dTstat -stdev -prefix rm.noise.all errts.${subj}.tproject+orig"[$ktrs]"
3dcalc -a rm.signal.all+orig                                             \
       -b rm.noise.all+orig                                              \
       -c mask_epi_anat.$subj+orig                                       \
       -expr 'c*a/b' -prefix TSNR.$subj 

# ---------------------------------------------------
# compute and store GCOR (global correlation average)
# (sum of squares of global mean of unit errts)
3dTnorm -norm2 -prefix rm.errts.unit errts.${subj}.tproject+orig
3dmaskave -quiet -mask full_mask.$subj+orig rm.errts.unit+orig           \
          > mean.errts.unit.1D
3dTstat -sos -prefix - mean.errts.unit.1D\' > out.gcor.1D
echo "-- GCOR = `cat out.gcor.1D`"

# ---------------------------------------------------
# compute correlation volume
# (per voxel: correlation with masked brain average)
3dmaskave -quiet -mask full_mask.$subj+orig errts.${subj}.tproject+orig  \
          > mean.errts.1D
3dTcorr1D -prefix corr_brain errts.${subj}.tproject+orig mean.errts.1D

# --------------------------------------------------
# compute sum of baseline (all) regressors
3dTstat -sum -prefix sum_baseline.1D X.nocensor.xmat.1D

# ============================ blur estimation =============================
# compute blur estimates
touch blur_est.$subj.1D   # start with empty file

# create directory for ACF curve files
mkdir files_ACF

# -- estimate blur for each run in epits --
touch blur.epits.1D

# restrict to uncensored TRs, per run
foreach run ( $runs )
    set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded \
                          -show_trs_run $run`
    if ( $trs == "" ) continue
    3dFWHMx -detrend -mask mask_epi_anat.$subj+orig                      \
            -ACF files_ACF/out.3dFWHMx.ACF.epits.r$run.1D                \
            all_runs.$subj+orig"[$trs]" >> blur.epits.1D
end

# compute average FWHM blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.epits.1D'{0..$(2)}'\'` )
echo average epits FWHM blurs: $blurs
echo "$blurs   # epits FWHM blur estimates" >> blur_est.$subj.1D

# compute average ACF blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.epits.1D'{1..$(2)}'\'` )
echo average epits ACF blurs: $blurs
echo "$blurs   # epits ACF blur estimates" >> blur_est.$subj.1D

# -- estimate blur for each run in errts --
touch blur.errts.1D

# restrict to uncensored TRs, per run
foreach run ( $runs )
    set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded \
                          -show_trs_run $run`
    if ( $trs == "" ) continue
    3dFWHMx -detrend -mask mask_epi_anat.$subj+orig                      \
            -ACF files_ACF/out.3dFWHMx.ACF.errts.r$run.1D                \
            errts.${subj}.tproject+orig"[$trs]" >> blur.errts.1D
end

# compute average FWHM blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.errts.1D'{0..$(2)}'\'` )
echo average errts FWHM blurs: $blurs
echo "$blurs   # errts FWHM blur estimates" >> blur_est.$subj.1D

# compute average ACF blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.errts.1D'{1..$(2)}'\'` )
echo average errts ACF blurs: $blurs
echo "$blurs   # errts ACF blur estimates" >> blur_est.$subj.1D


# ================== auto block: generate review scripts ===================

# generate a review script for the unprocessed EPI data
gen_epi_review.py -script @epi_review.$subj             \
    -dsets pb00.$subj.r*.tcat+orig.HEAD

# generate scripts to review single subject results
# (try with defaults, but do not allow bad exit status)
gen_ss_review_scripts.py -mot_limit 0.1 -out_limit 0.05 \
    -errts_dset errts.${subj}.tproject+orig.HEAD -exit0 \
    -ss_review_dset out.ss_review.$subj.txt             \
    -write_uvars_json out.ss_review_uvars.json

# ========================== auto block: finalize ==========================

# remove temporary files
\rm -fr rm.* Segsy

# if the basic subject review script is here, run it
# (want this to be the last text output)
if ( -e @ss_review_basic ) then
    ./@ss_review_basic |& tee out.ss_review.$subj.txt

    # generate html ss review pages
    # (akin to static images from running @ss_review_driver)
    apqc_make_tcsh.py -review_style pythonic -subj_dir . \
        -uvar_json out.ss_review_uvars.json
    tcsh @ss_review_html |& tee out.review_html
    apqc_make_html.py -qc_dir QC_$subj

    echo "\nconsider running: \n\n    afni_open -b /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D03_Preproc_NoRICOR_FIR_090/QC_$subj/index.html\n"
endif

# return to parent directory (just in case...)
cd ..

echo "execution finished: `date`"




# ==========================================================================
# script generated by the command:
#
# afni_proc.py -subj_id P009 -copy_anat                                                                 \
#     /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D01_Anatomical/anatSS.P009.nii                     \
#     -anat_has_skull no -anat_follower anat_w_skull anat                                               \
#     /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D00_OriginalData/P009_Anat+orig                    \
#     -dsets                                                                                            \
#     /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D00_OriginalData/P009_fMRI_090+orig.HEAD           \
#     -blocks tshift align tlrc volreg blur mask regress                                                \
#     -radial_correlate_blocks tcat volreg -tcat_remove_first_trs 0                                     \
#     -align_opts_aea -AddEdge -cost lpc+ZZ -giant_move -check_flip                                     \
#     -align_epi_strip_method 3dSkullStrip -tlrc_base                                                   \
#     MNI152_2009_template_SSW.nii.gz -tlrc_NL_warp -tlrc_NL_warped_dsets                               \
#     /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D01_Anatomical/anatQQ.P009.nii                     \
#     /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D01_Anatomical/anatQQ.P009.aff12.1D                \
#     /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D01_Anatomical/anatQQ.P009_WARP.nii                \
#     -align_epi_ext_dset                                                                               \
#     '/data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D00_OriginalData/P009_fMRI_090.RefVol.bc+orig[0]' \
#     -tshift_opts_ts -tpattern alt+z2 -volreg_align_to first -mask_epi_anat                            \
#     yes -blur_size 4.0 -regress_opts_3dD -jobs 32 -regress_motion_per_run                             \
#     -regress_censor_motion 0.1 -regress_censor_outliers 0.05                                          \
#     -regress_apply_mot_types demean deriv -regress_make_ideal_sum                                     \
#     sum_ideal.1D -regress_est_blur_epits -regress_est_blur_errts                                      \
#     -regress_run_clustsim no -html_review_style pythonic -out_dir                                     \
#     /data/SFIM_FlipAngle/PRJ_FAConn//PrcsData/P009/D03_Preproc_NoRICOR_FIR_090                        \
#     -script FA04_Preproc_fMRI_NoRICOR_FIR.P009.090.sh -volreg_compute_tsnr                            \
#     yes -regress_compute_tsnr yes -mask_segment_anat yes                                              \
#     -mask_segment_erode yes -regress_make_cbucket yes -mask_intersect                                 \
#     WM_inFB brain WM -mask_intersect GM_inFB brain GM -mask_intersect                                 \
#     CSF_inFB brain CSF -mask_intersect WMe_inFB brain WMe -mask_intersect                             \
#     GMe_inFB brain GMe -mask_intersect CSFe_inFB brain CSFe -scr_overwrite
