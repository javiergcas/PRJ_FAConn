set -e
module load afni
PRJDIR=/data/SFIM_FlipAngle/PRJ_FAConn

INPUT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject+orig`

MASK_FB=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/full_mask.${SBJ}+orig`
MASK_GM=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_GM_inFB+orig`
MASK_WM=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_WM_inFB+orig`
MASK_CSF=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/mask_inter_CSF_inFB+orig`

OUTPUT_FB=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.FB.nii.gz`
OUTPUT_WM=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.WM.nii.gz`
OUTPUT_GM=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.GM.nii.gz`
OUTPUT_CSF=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.CSF.nii.gz`

# Use only acquisitions that were not censor by AFNI during the pre-processing
# ============================================================================
GOOD_TRS=`1d_tool.py -infile ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/X.xmat.1D -show_trs_uncensored encoded`

3dTcorrMap -overwrite -input ${INPUT}[${GOOD_TRS}] -mask ${MASK_FB} -Mean ${OUTPUT_FB}
3dTcorrMap -overwrite -input ${INPUT}[${GOOD_TRS}] -mask ${MASK_GM} -Mean ${OUTPUT_GM}
3dTcorrMap -overwrite -input ${INPUT}[${GOOD_TRS}] -mask ${MASK_WM} -Mean ${OUTPUT_WM}
3dTcorrMap -overwrite -input ${INPUT}[${GOOD_TRS}] -mask ${MASK_CSF} -Mean ${OUTPUT_CSF}
