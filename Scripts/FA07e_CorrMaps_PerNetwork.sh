set -e

module load afni

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn/'
MASK_PATH=`echo  ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/${SBJ}_fMRI_${FA}.Schaefer2018_${NROI}Par_7Nw.nii.gz`
INPUT_PATH=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.GM.nii.gz`
OUT_TXT=`echo    ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.GM.Schaefer_${NROI}Par_7Nw.means.txt`
OUT_CSV=`echo    ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.GM.Schaefer_${NROI}Par_7Nw.means.csv`

3dROIstats -nzmean \
           -nomeanout \
           -nobriklab \
           -mask ${MASK_PATH} \
                 ${INPUT_PATH} > ${OUT_TXT}

cat ${OUT_TXT} | tr -s '\t' ',' >  ${OUT_CSV}
rm ${OUT_TXT}
