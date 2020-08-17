set -e
PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn/'
WORKDIR=`echo ${PRJDIR}/PrcsData/ALL_CorrMaps`

if [ ! -d ${WORKDIR} ]; then
   mkdir ${WORKDIR}
fi

for FA in 015 050 077 090
do
    3dMean -overwrite -prefix ${WORKDIR}/ALL_fMRI_${FA}.errts.tproject.CorrMap.GM.MNI.nii.gz ${PRJDIR}/PrcsData/P???/D03_Preproc_NoRICOR_FIR_${FA}/errts.P???.tproject.CorrMap.GM.MNI.nii.gz
done
