set -e
echo "#swarm -f ./FA07b_Compute_3dTCorrMaps_ShowResults_AvgMaps.SWARM.sh -g 32 -t 32 --partition quick,norm" > ./FA07b_Compute_3dTCorrMaps_ShowResults_AvgMaps.SWARM.sh
PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn'
for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  for FA in 015 050 077 090
  do
      CMAP_IN=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.GM.nii.gz`
      CMAP_OUT=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.GM.MNI.nii.gz`
      YEO17=`echo /data/SFIM_FlipAngle/PRJ_FAConn/Resources/Atlases/Yeo_JNeurophysiol11_MNI152/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz`
      MASTER=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/anatQQ.${SBJ}.nii`
      WARP=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/anatQQ.${SBJ}_WARP.nii`
      MATRIX=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/anatQQ.${SBJ}.aff12.1D`
      A2E_MATRIX=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/anatSS.${SBJ}_al_keep_mat.aff12.1D`
      echo "module load afni; 3dNwarpApply -overwrite -master ${MASTER} -dxyz 2 -source ${CMAP_IN} -nwarp '${WARP} ${MATRIX} inv(${A2E_MATRIX})' -prefix ${CMAP_OUT}" >> ./FA07b_Compute_3dTCorrMaps_ShowResults_AvgMaps.SWARM.sh
  done
done
