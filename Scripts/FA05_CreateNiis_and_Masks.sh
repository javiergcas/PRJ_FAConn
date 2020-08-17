set -e
module load afni

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn/'

## #Create Signal Volume for TSNR computations
## #==========================================
## MEAN_INPUT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/pb02.${SBJ}.r01.volreg+orig`
## MEAN_OUTPT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/pb02.${SBJ}.r01.MEAN.nii`
## 3dTstat -overwrite -mean -prefix ${MEAN_OUTPT} ${MEAN_INPUT}

# Convert some outputs from afni_proc into .nii files (this is necessary for later analyses in Python)
# ====================================================================================================
FBmask_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/full_mask.${SBJ}`
GMmask_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_GM_inFB`
WMmask_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_WM_inFB`
CSFmask_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_CSF_inFB`
GMemask_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_GMe_inFB`
WMemask_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_WMe_inFB`
CSFemask_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_CSFe_inFB`
Clean_Prefix=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject` 
for prefix in ${FBmask_Prefix} ${GMmask_Prefix} ${WMmask_Prefix} ${CSFmask_Prefix} ${GMemask_Prefix} ${WMemask_Prefix} ${CSFemask_Prefix} ${Clean_Prefix}
do
   3dcopy -overwrite ${prefix}+orig ${prefix}.nii.gz
done

# Bring Schaefer Atlas to each Run EPI space
# ==========================================
ATLAS100_IN=`echo "${PRJDIR}/Resources/Atlases/Schaefer2018/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.nii.gz"`
ATLAS100_OUT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/${SBJ}_fMRI_${FA}.Schaefer2018_100Par_7Nw.nii.gz`
INFO100_PATH=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/${SBJ}_fMRI_${FA}.Schaefer2018_100Par_7Nw.info.txt`

ATLAS200_IN=`echo "${PRJDIR}/Resources/Atlases/Schaefer2018/Schaefer2018_200Parcels_7Networks_order_FSLMNI152_2mm.nii.gz"`
ATLAS200_OUT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/${SBJ}_fMRI_${FA}.Schaefer2018_200Par_7Nw.nii.gz`
INFO200_PATH=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/${SBJ}_fMRI_${FA}.Schaefer2018_200Par_7Nw.info.txt`

MASTER=`echo ${Clean_Prefix}.nii.gz`
WARP=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/anatQQ.${SBJ}_WARP.nii`
MATRIX=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/anatQQ.${SBJ}.aff12.1D`
A2E_MATRIX=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/anatSS.${SBJ}_al_keep_mat.aff12.1D`
FB_MASK=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/full_mask.${SBJ}+orig`

3dNwarpApply -overwrite \
             -iwarp \
             -interp NN \
             -master ${MASTER}            \
             -source ${ATLAS100_IN}       \
             -nwarp "${WARP} ${MATRIX} inv(${A2E_MATRIX})" \
             -prefix ${ATLAS100_OUT}

3dcalc -overwrite -a ${ATLAS100_OUT} -m ${FB_MASK} -expr 'a*m' -prefix ${ATLAS100_OUT}
3dROIstats -quiet -nzvoxels -mask ${ATLAS100_OUT} ${ATLAS100_OUT} > ${INFO100_PATH}

3dNwarpApply -overwrite \
             -iwarp \
             -interp NN \
             -master ${MASTER} \
             -source ${ATLAS200_IN} \
             -nwarp "${WARP} ${MATRIX} inv(${A2E_MATRIX})" \
             -prefix ${ATLAS200_OUT}
3dcalc -overwrite -a ${ATLAS200_OUT} -m ${FB_MASK} -expr 'a*m' -prefix ${ATLAS200_OUT}
3dROIstats -quiet -nzvoxels -mask ${ATLAS200_OUT} ${ATLAS200_OUT} > ${INFO200_PATH}

# Bring the Yeo Networks in Alignment with each run
# =================================================
YEO07_IN=`echo ${PRJDIR}/Resources/Atlases/Yeo_JNeurophysiol11_MNI152/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz`
YEO17_IN=`echo ${PRJDIR}/Resources/Atlases/Yeo_JNeurophysiol11_MNI152/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz`
YEO07_OUT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/${SBJ}_fMRI_${FA}.Yeo07.nii.gz`
YEO17_OUT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/${SBJ}_fMRI_${FA}.Yeo17.nii.gz`
3dNwarpApply -overwrite -iwarp -interp NN -master ${MASTER} -source ${YEO07_IN} -nwarp "${WARP} ${MATRIX} inv(${A2E_MATRIX})" -prefix ${YEO07_OUT}
3dcalc -overwrite -a ${YEO07_OUT} -m ${FB_MASK} -expr 'a*m' -prefix ${YEO07_OUT}

3dNwarpApply -overwrite -iwarp -interp NN -master ${MASTER} -source ${YEO17_IN} -nwarp "${WARP} ${MATRIX} inv(${A2E_MATRIX})" -prefix ${YEO17_OUT}; 
3dcalc -overwrite -a ${YEO17_OUT} -m ${FB_MASK} -expr 'a*m' -prefix ${YEO17_OUT}

