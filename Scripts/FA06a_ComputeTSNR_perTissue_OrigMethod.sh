set -e

module load afni

cd /data/SFIM_FlipAngle/PRJ_FAConn2/PrcsData/${SBJ}/D03_Preproc_NoRICOR_FIR_${FA}

# Compute Mean Signal, Standard Deviation and TSNR at three different moments             
# ===========================================================================
3dTstat -mean -sigma -tsnr -mask full_mask.${SBJ}+orig. -overwrite -prefix pb02.${SBJ}_fMRI_${FA}.r01.volreg.STATS pb02.${SBJ}.r01.volreg+orig
3dTstat -mean -sigma -tsnr -mask full_mask.${SBJ}+orig. -overwrite -prefix pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS   pb03.${SBJ}.r01.blur+orig
3dTstat -mean -sigma -mask full_mask.${SBJ}+orig. -overwrite -prefix errts.${SBJ}.tproject.STATS             errts.${SBJ}.tproject+orig

# Rename sub-bricks to avoid the default names given by 3dTstat that contain spaces
# =================================================================================
3drefit -relabel_all_str 'Mean Sigma TSNR' pb02.${SBJ}_fMRI_${FA}.r01.volreg.STATS+orig
3drefit -relabel_all_str 'Mean Sigma TSNR' pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS+orig
3drefit -relabel_all_str 'Mean Sigma'      errts.${SBJ}.tproject.STATS+orig

# Compute TSNR Map after nuisance regression (this is computed a bit differently becuase the regression step removes the mean)
# ============================================================================================================================
3dcalc -m pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS+orig[Mean] -s errts.${SBJ}.tproject.STATS+orig[Sigma] -c full_mask.${SBJ}+orig. -expr 'c*m/s' -overwrite -prefix errts.${SBJ}.tproject.TSNR
3dbucket -overwrite -prefix errts.${SBJ}.tproject.STATS+orig errts.${SBJ}.tproject.STATS+orig errts.${SBJ}.tproject.TSNR+orig
3drefit -relabel_all_str 'Mean Sigma TSNR' errts.${SBJ}.tproject.STATS+orig
rm errts.${SBJ}.tproject.TSNR+orig.*

# Extract Smean, Sigma and TSNR for the different tissue compartments
# ===================================================================
for step in VOLREG BLUR PROJECT
do
    if [ ${step} == "VOLREG" ]; then
       mean_vol=`echo pb02.${SBJ}_fMRI_${FA}.r01.volreg.STATS+orig['Mean']`
       stdv_vol=`echo pb02.${SBJ}_fMRI_${FA}.r01.volreg.STATS+orig['Sigma']`
       tsnr_vol=`echo pb02.${SBJ}_fMRI_${FA}.r01.volreg.STATS+orig['TSNR']`
       out_path=`echo pb02.${SBJ}_fMRI_${FA}.r01.volreg.STATS.1D`
       snr_vol=`echo  pb02.${SBJ}_fMRI_${FA}.r01.volreg.SNR`
    fi
    if [ ${step} == "BLUR" ]; then
       mean_vol=`echo pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS+orig['Mean']`
       stdv_vol=`echo pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS+orig['Sigma']`
       tsnr_vol=`echo pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS+orig['TSNR']`
       out_path=`echo pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS.1D`
       snr_vol=`echo  pb03.${SBJ}_fMRI_${FA}.r01.blur.SNR`
    fi
    if [ ${step} == "PROJECT" ]; then
       mean_vol=`echo pb03.${SBJ}_fMRI_${FA}.r01.blur.STATS+orig['Mean']`
       stdv_vol=`echo errts.${SBJ}.tproject.STATS+orig['Sigma']`
       tsnr_vol=`echo errts.${SBJ}.tproject.STATS+orig['TSNR']`
       out_path=`echo errts.${SBJ}.tproject.STATS.1D`
       snr_vol=`echo  errts.${SBJ}.tproject.SNR`
    fi

    TSNR_WM=`3dROIstats   -quiet -mask mask_inter_WM_inFB+orig.   ${tsnr_vol} | awk '{print $1}'`
    TSNR_GM=`3dROIstats   -quiet -mask mask_inter_GM_inFB+orig.   ${tsnr_vol} | awk '{print $1}'`
    TSNR_CSF=`3dROIstats  -quiet -mask mask_inter_CSF_inFB+orig.  ${tsnr_vol} | awk '{print $1}'`
    TSNR_WMe=`3dROIstats  -quiet -mask mask_inter_WMe_inFB+orig.  ${tsnr_vol} | awk '{print $1}'`
    TSNR_GMe=`3dROIstats  -quiet -mask mask_inter_GMe_inFB+orig.  ${tsnr_vol} | awk '{print $1}'`
    TSNR_CSFe=`3dROIstats -quiet -mask mask_inter_CSFe_inFB+orig. ${tsnr_vol} | awk '{print $1}'`
    
    Smean_WM=`3dROIstats   -quiet -mask mask_inter_WM_inFB+orig.   ${mean_vol} | awk '{print $1}'`
    Smean_GM=`3dROIstats   -quiet -mask mask_inter_GM_inFB+orig.   ${mean_vol} | awk '{print $1}'`
    Smean_CSF=`3dROIstats  -quiet -mask mask_inter_CSF_inFB+orig.  ${mean_vol} | awk '{print $1}'`
    Smean_WMe=`3dROIstats  -quiet -mask mask_inter_WMe_inFB+orig.  ${mean_vol} | awk '{print $1}'`
    Smean_GMe=`3dROIstats  -quiet -mask mask_inter_GMe_inFB+orig.  ${mean_vol} | awk '{print $1}'`
    Smean_CSFe=`3dROIstats -quiet -mask mask_inter_CSFe_inFB+orig. ${mean_vol} | awk '{print $1}'`
    
    Sigma_WM=`3dROIstats   -quiet -mask mask_inter_WM_inFB+orig.   ${stdv_vol} | awk '{print $1}'`
    Sigma_GM=`3dROIstats   -quiet -mask mask_inter_GM_inFB+orig.   ${stdv_vol} | awk '{print $1}'`
    Sigma_CSF=`3dROIstats  -quiet -mask mask_inter_CSF_inFB+orig.  ${stdv_vol} | awk '{print $1}'`
    Sigma_WMe=`3dROIstats  -quiet -mask mask_inter_WMe_inFB+orig.  ${stdv_vol} | awk '{print $1}'`
    Sigma_GMe=`3dROIstats  -quiet -mask mask_inter_GMe_inFB+orig.  ${stdv_vol} | awk '{print $1}'`
    Sigma_CSFe=`3dROIstats -quiet -mask mask_inter_CSFe_inFB+orig. ${stdv_vol} | awk '{print $1}'`
    
    # Compute SNR Map (This was an to compute SNR using a predefined value of sigma_zero. This is not accurate, please do not use these values)
    # =========================================================================================================================================
    SigmaZero=3.5
    3dcalc  -overwrite -datum float -a ${mean_vol} -b full_mask.${SBJ}+orig -expr "b*(a/${SigmaZero})" -prefix ${snr_vol}
    SNR_WM=`3dROIstats   -quiet -mask mask_inter_WM_inFB+orig.   ${snr_vol}+orig. | awk '{print $1}'`
    SNR_GM=`3dROIstats   -quiet -mask mask_inter_GM_inFB+orig.   ${snr_vol}+orig. | awk '{print $1}'`
    SNR_CSF=`3dROIstats  -quiet -mask mask_inter_CSF_inFB+orig.  ${snr_vol}+orig. | awk '{print $1}'`
    SNR_WMe=`3dROIstats  -quiet -mask mask_inter_WMe_inFB+orig.  ${snr_vol}+orig. | awk '{print $1}'`
    SNR_GMe=`3dROIstats  -quiet -mask mask_inter_GMe_inFB+orig.  ${snr_vol}+orig. | awk '{print $1}'`
    SNR_CSFe=`3dROIstats -quiet -mask mask_inter_CSFe_inFB+orig. ${snr_vol}+orig. | awk '{print $1}'`

   echo "TSNR_WM TSNR_GM TSNR_CSF TSNR_WMe TSNR_GMe TSNR_CSFe SNR_WM SNR_GM SNR_CSF SNR_WMe SNR_GMe SNR_CSFe Smean_WM Smean_GM Smean_CSF Smean_WMe Smean_GMe Smean_CSFe Sigma_WM Sigma_GM Sigma_CSF Sigma_WMe Sigma_GMe Sigma_CSFe" > ${out_path}
   echo "${TSNR_WM} ${TSNR_GM} ${TSNR_CSF} ${TSNR_WMe} ${TSNR_GMe} ${TSNR_CSFe} ${SNR_WM} ${SNR_GM} ${SNR_CSF} ${SNR_WMe} ${SNR_GMe} ${SNR_CSFe} ${Smean_WM} ${Smean_GM} ${Smean_CSF} ${Smean_WMe} ${Smean_GMe} ${Smean_CSFe} ${Sigma_WM} ${Sigma_GM} ${Sigma_CSF} ${Sigma_WMe} ${Sigma_GMe} ${Sigma_CSFe}" >> ${out_path}
   cat ${out_path}
done
