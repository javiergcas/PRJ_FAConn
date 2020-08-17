set -e
module load afni

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn/'

cd ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData

# Convert to AFNI Format (BRIK/HEAD)
# ==================================
if [ -e ${SBJ}_fMRI_${FA}.nii.gz ]; then
   3drefit -space ORIG -view +orig ${SBJ}_fMRI_${FA}.nii.gz
   3dcopy -overwrite ${SBJ}_fMRI_${FA}.nii.gz ${SBJ}_fMRI_${FA}+orig 
   rm ${SBJ}_fMRI_${FA}.nii.gz
fi

# Select First Volume as it has good contrast
# ===========================================
# In the 2011 data becuase we kept the non-steady state datapoints, this was more critical
# as this allowed us to have a good volume with good tissue contrast for alignment towards
# the anatomical independently of flip angle
3dcalc -overwrite -a ${SBJ}_fMRI_${FA}+orig[0] -expr 'a' -prefix ${SBJ}_fMRI_${FA}.RefVol

# Create Full Brain Mask
# ======================
3dSkullStrip -overwrite -input ${SBJ}_fMRI_${FA}.RefVol+orig. -prefix ${SBJ}_fMRI_${FA}.RefVol.Mask -mask_vol
3drefit -atrcopy ${SBJ}_fMRI_${FA}.RefVol+orig IJK_TO_DICOM_REAL ${SBJ}_fMRI_${FA}.RefVol.Mask+orig
3dcalc       -a ${SBJ}_fMRI_${FA}.RefVol.Mask+orig. -expr 'step(a)' -overwrite -prefix ${SBJ}_fMRI_${FA}.RefVol.Mask

# Create Bias Map 
# ===============
3dBlurInMask -mask ${SBJ}_fMRI_${FA}.RefVol.Mask+orig. -overwrite -fwhm 25 -prefix ${SBJ}_fMRI_${FA}.RefVol.BiasMap -input ${SBJ}_fMRI_${FA}.RefVol+orig.

# Bring Bias Map to a meaningful range
# ====================================
DATA_MIN=`3dROIstats -nzminmax -nomeanout -quiet -mask ${SBJ}_fMRI_${FA}.RefVol.Mask+orig ${SBJ}_fMRI_${FA}.RefVol.BiasMap+orig | awk '{print $1}'`
DATA_MAX=`3dROIstats -nzminmax -nomeanout -quiet -mask ${SBJ}_fMRI_${FA}.RefVol.Mask+orig ${SBJ}_fMRI_${FA}.RefVol.BiasMap+orig | awk '{print $2}'` 
3dcalc -overwrite -datum float -a ${SBJ}_fMRI_${FA}.RefVol.BiasMap+orig. -b ${SBJ}_fMRI_${FA}.RefVol.Mask+orig \
       -expr "(b*( ( ((10-1)*(a-${DATA_MIN})) / (${DATA_MAX}-${DATA_MIN}) )+1)) + abs(step(b)-1)" \
       -prefix ${SBJ}_fMRI_${FA}.RefVol.BiasMap 

# Apply Bias Map (Perform Bias correction on the reference volume
# ===============================================================
3dcalc -overwrite -a ${SBJ}_fMRI_${FA}.RefVol+orig. -b ${SBJ}_fMRI_${FA}.RefVol.BiasMap+orig. -expr 'a/b' -prefix ${SBJ}_fMRI_${FA}.RefVol.bc
