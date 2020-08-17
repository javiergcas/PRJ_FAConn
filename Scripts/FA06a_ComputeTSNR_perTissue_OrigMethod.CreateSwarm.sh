set -e
module load afni

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn/'

echo "#swarm -f ./FA06a_ComputeTSNR_perTissue_OrigMethod.SWARM.sh -g 32 -t 32 --partition quick" > ./FA06a_ComputeTSNR_perTissue_OrigMethod.SWARM.sh

for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  ORIG_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData`
  for FA in 015 050 077 090
  do
    INPUT_PATH=`echo ${ORIG_DIR}/${SBJ}_fMRI_${FA}+orig.HEAD`
    if [ -e ${INPUT_PATH} ]; then
       echo "export SBJ=${SBJ} FA=${FA}; sh ./FA06a_ComputeTSNR_perTissue_OrigMethod.sh" >> ./FA06a_ComputeTSNR_perTissue_OrigMethod.SWARM.sh
    fi
  done
done
