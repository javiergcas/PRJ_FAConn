set -e
module load afni
PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn/'

INPUT_PATH=`echo   ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.nii.gz`
OUTPUT_PATH=`echo  ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}_${FA}.tproject.MNI.nii.gz`

MASTER=`echo ${PRJDIR}/PrcsData/ALL_CorrMaps/anatQQ.ALL.nii`
WARP=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/anatQQ.${SBJ}_WARP.nii`
MATRIX=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/anatQQ.${SBJ}.aff12.1D`
A2E_MATRIX=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/anatSS.${SBJ}_al_keep_mat.aff12.1D`
FB_MASK=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/full_mask.${SBJ}+orig`

3dNwarpApply -overwrite                  \
             -dxyz 2                     \
             -master ${MASTER}           \
             -source ${INPUT_PATH}       \
             -nwarp "${WARP} ${MATRIX} inv(${A2E_MATRIX})" \
             -prefix ${OUTPUT_PATH}
