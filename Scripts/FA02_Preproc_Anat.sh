set -e
module load afni
PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn2'
ORIG_DATA_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData`
ANAT_DATA_DIR=`echo ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical`

echo "++ STEP 1: Preprocessing of Anatomical Data for Subject ${SBJ}"
echo "++ ==========================================================="
echo "++ Original   Data Dir: ${ORIG_DATA_DIR}"
echo "++ Anatomical Data Dir: ${ANAT_DATA_DIR}"

# Create D01_Anatomical Directory if necessary
if [ ! -d ${ANAT_DATA_DIR} ]; then
   mkdir ${ANAT_DATA_DIR}
fi

# Convert nii to afni if necessary
cd ${ORIG_DATA_DIR}
if [ -e ${ORIG_DATA_DIR}/${SBJ}_Anat.nii ]; then
   3dcopy -overwrite ${SBJ}_Anat.nii ${SBJ}_Anat+orig
   rm ${SBJ}_Anat.nii
fi

# Create Link to original anatomical dataset in directory where we 
# pre-process anatomical datasets
if [ ! -e ${ANAT_DATA_DIR}/${SBJ}_Anat+orig.HEAD ]; then
  echo "++ Making a link to original Anat dataset in pre-processing dir for anatomical data..."
  ln -s ${ORIG_DATA_DIR}/${SBJ}_Anat+orig.HEAD    ${ANAT_DATA_DIR}/${SBJ}_Anat+orig.HEAD
  ln -s ${ORIG_DATA_DIR}/${SBJ}_Anat+orig.BRIK.gz ${ANAT_DATA_DIR}/${SBJ}_Anat+orig.BRIK.gz
fi

@SSwarper                                    \
   -input  ${ORIG_DATA_DIR}/${SBJ}_Anat+orig \
   -base   MNI152_2009_template_SSW.nii.gz   \
   -subid  ${SBJ}                            \
   -odir   ${ANAT_DATA_DIR}                  \
   -warpscale 0.5                            \
   -verb
