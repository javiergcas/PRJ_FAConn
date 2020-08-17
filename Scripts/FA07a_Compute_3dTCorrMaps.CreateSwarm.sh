set -e

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn2/'

echo "#swarm -f ./FA07a_Compute_3dTCorrMaps.SWARM.sh -g 32 -t 32 --partition quick" > ./FA07a_Compute_3dTCorrMaps.SWARM.sh

for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  for FA in 015 050 077 090
  do
    WORK_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/`
    INPUT_PATH=`echo ${WORK_DIR}/errts.${SBJ}.tproject.nii.gz`
    if [ -f ${INPUT_PATH} ]; then
       echo "${INPUT_PATH} is available"	
       echo "export SBJ=${SBJ} FA=${FA}; sh ./FA07a_Compute_3dTCorrMaps.sh" >> ./FA07a_Compute_3dTCorrMaps.SWARM.sh
    else
       echo "WARNING: ${INPUT_PATH} not available"
    fi
  done
done
