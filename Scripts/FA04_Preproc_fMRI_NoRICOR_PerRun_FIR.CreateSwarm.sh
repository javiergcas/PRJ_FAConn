set -e
module load afni

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn/'

echo "#swarm -f ./FA04_Preproc_fMRI_NoRICOR_PerRun_FIR.SWARM.sh -g 32 -t 32 --partition quick" > ./FA04_Preproc_fMRI_NoRICOR_PerRun_FIR.SWARM.sh

if [ ! -d FA04_Preproc_fMRI_NoRICOR_PerRun_FIR ]; then 
   mkdir FA04_Preproc_fMRI_NoRICOR_PerRun_FIR
fi

YEO07_PATH=`echo /data/SFIM_FlipAngle/PRJ_FAConn/Resources/Atlases/Yeo_JNeurophysiol11_MNI152/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz`
YEO17_PATH=`echo /data/SFIM_FlipAngle/PRJ_FAConn/Resources/Atlases/Yeo_JNeurophysiol11_MNI152/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz`
for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  ANAT_PROC_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical`
  ORIG_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData`
  RESOURCES_DIR=`echo ${PRJDIR}/Resources`   
  for FA in 015 050 077 090
  do
    INPUT_PATH=`echo ${ORIG_DIR}/${SBJ}_fMRI_${FA}+orig.HEAD`
    REFVOL_PATH=`echo ${ORIG_DIR}/${SBJ}_fMRI_${FA}.RefVol.bc+orig`
    if [ -e ${INPUT_PATH} ]; then
      OUT_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}`
      afni_proc.py                                                                  \
                 -subj_id ${SBJ}                                                    \
                 -copy_anat ${ANAT_PROC_DIR}/anatSS.${SBJ}.nii                      \
                 -anat_has_skull no                                                 \
                 -anat_follower anat_w_skull anat ${ORIG_DIR}/${SBJ}_Anat+orig      \
                 -dsets ${INPUT_PATH}                                               \
                 -blocks tshift align tlrc volreg blur mask regress                 \
                 -radial_correlate_blocks tcat volreg                               \
                 -tcat_remove_first_trs 0                                           \
                 -align_opts_aea -AddEdge -cost lpc+ZZ -giant_move -check_flip      \
                 -align_epi_strip_method 3dSkullStrip                               \
                 -tlrc_base MNI152_2009_template_SSW.nii.gz                         \
                 -tlrc_NL_warp                                                      \
                 -tlrc_NL_warped_dsets ${ANAT_PROC_DIR}/anatQQ.${SBJ}.nii           \
                     ${ANAT_PROC_DIR}/anatQQ.${SBJ}.aff12.1D                        \
                     ${ANAT_PROC_DIR}/anatQQ.${SBJ}_WARP.nii                        \
                 -align_epi_ext_dset ${REFVOL_PATH}[0]                              \
		 -tshift_opts_ts -tpattern alt+z2                                   \
                 -volreg_align_to first                                             \
                 -mask_epi_anat yes                                                 \
                 -blur_size 4.0                                                     \
                 -regress_opts_3dD -jobs 32                                         \
                 -regress_motion_per_run                                            \
                 -regress_censor_motion 0.1                                         \
                 -regress_censor_outliers 0.05                                      \
                 -regress_apply_mot_types demean deriv                              \
                 -regress_make_ideal_sum sum_ideal.1D                               \
                 -regress_est_blur_epits                                            \
                 -regress_est_blur_errts                                            \
                 -regress_run_clustsim no                                           \
                 -html_review_style pythonic                                        \
                 -out_dir ${OUT_DIR}                                                \
                 -script  FA04_Preproc_fMRI_NoRICOR_FIR.${SBJ}.${FA}.sh             \
		 -volreg_compute_tsnr yes \
                 -regress_compute_tsnr yes \
                 -mask_segment_anat yes \
                 -mask_segment_erode yes \
                 -regress_make_cbucket yes \
                 -mask_intersect WM_inFB brain WM \
                 -mask_intersect GM_inFB brain GM \
                 -mask_intersect CSF_inFB brain CSF \
                 -mask_intersect WMe_inFB brain WMe \
                 -mask_intersect GMe_inFB brain GMe \
                 -mask_intersect CSFe_inFB brain CSFe \
                 -scr_overwrite                                         
      sed -i 's/-cenmode ZERO/-cenmode NTRP/g' FA04_Preproc_fMRI_NoRICOR_FIR.${SBJ}.${FA}.sh
      mv FA04_Preproc_fMRI_NoRICOR_FIR.${SBJ}.${FA}.sh FA04_Preproc_fMRI_NoRICOR_PerRun_FIR/
      echo "module load afni; tcsh -xef ./FA04_Preproc_fMRI_NoRICOR_PerRun_FIR/FA04_Preproc_fMRI_NoRICOR_FIR.${SBJ}.${FA}.sh 2>&1 | tee ./FA04_Preproc_fMRI_NoRICOR_PerRun_FIR/output.FA04_Preproc_fMRI_NoRICOR_FIR.${SBJ}.${FA}.txt" >> ./FA04_Preproc_fMRI_NoRICOR_PerRun_FIR.SWARM.sh
    fi
  done
done
