set -e

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn2/'

echo "#swarm -f ./FA07e_CorrMaps_PerNetwork.SWARM.sh -g 32 -t 32 --partition quick" > ./FA07e_CorrMaps_PerNetwork.SWARM.sh

for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  ORIG_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData`
  for FA in 015 050 077 090
  do
    INPUT_PATH=`echo ${PRJDIR}/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}/errts.${SBJ}.tproject.CorrMap.GM.nii.gz`
    if [ -e ${INPUT_PATH} ]; then
       echo "export SBJ=${SBJ} FA=${FA} NROI=100; sh ./FA07e_CorrMaps_PerNetwork.sh" >> ./FA07e_CorrMaps_PerNetwork.SWARM.sh
    fi
  done
done
