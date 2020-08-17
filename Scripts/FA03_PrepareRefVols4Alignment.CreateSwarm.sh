set -e

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn2/'

echo "#swarm -f ./FA03_PrepareRefVols4Alignment.SWARM.sh -g 32 -t 32 --partition quick,norm" > ./FA03_PrepareRefVols4Alignment.SWARM.sh

for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  ORIG_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData`
  for FA in 015 050 077 090
  do
    INPUT_NII_PATH=`echo ${ORIG_DIR}/${SBJ}_fMRI_${FA}.nii.gz`
    INPUT_BRIK_PATH=`echo ${ORIG_DIR}/${SBJ}_fMRI_${FA}+orig.HEAD`
    if [ -e ${INPUT_NII_PATH} ] || [ -e ${INPUT_BRIK_PATH} ]; then
       echo "export SBJ=${SBJ} FA=${FA}; sh ./FA03_PrepareRefVols4Alignment.sh" >> ./FA03_PrepareRefVols4Alignment.SWARM.sh
    fi
  done
done
