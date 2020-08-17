import os.path as osp
import pandas as pd
import numpy as np
from .variables import PrcsData_Dir

def get_roi_lists(PRJDIR,SBJLIST,FAs,ATLASDIR,AtlasID='Schaefer2018',Nrois=100,Nnw=7,Nvox_thr=15, verbose=True):
  # Load Atlas Information (nothing specific to our subjects)
  roi_info_path        = osp.join(ATLASDIR,'{atlasid}_{nroi}Parcels_{nnw}Networks_order.txt'.format(atlasid=AtlasID,nroi=str(Nrois),nnw=str(Nnw)))
  roi_info             = pd.read_csv(roi_info_path,sep='\t', header=None)
  roi_info.columns     = ['ROI_Num','ROI_Name','R','G','B','Unknown']
  roi_info             = roi_info.drop(['Unknown'],axis=1)
  aux                  = roi_info['ROI_Name'].str.split('_',3,expand=True)
  roi_info['Hemi']     = aux[1]
  roi_info['NW']       = aux[2]
  roi_info['ROI_ID']   = aux[3]
  aux                  = roi_info['ROI_Name'].str.split('_',1,expand=True)
  roi_info['ROI_Name'] = aux[1]
  roi_info.set_index('ROI_Num',drop=True,inplace=True)
  
  # Add information regarding how many voxels each ROI has in each subject FOV
  for sbj in SBJLIST:
    for fa in FAs:
        path = osp.join(PRJDIR,'PrcsData',sbj,'D03_Preproc_NoRICOR_FIR_{fa}'.format(fa=fa),'{sbj}_fMRI_{fa}.Schaefer2018_{nroi}Par_7Nw.info.txt'.format(sbj=sbj,fa=fa,nroi=str(Nrois)))
        if osp.exists(path):
            aux  = np.loadtxt(path, dtype=np.int32)
            aux  = pd.DataFrame(aux.reshape(int(aux.shape[0]/2),2),columns=['ROI_Num',sbj+'_'+fa+'_NVox'], dtype=np.int32)
            aux.set_index('ROI_Num', drop=True,inplace=True)
            roi_info = pd.concat([roi_info,aux],axis=1)
            num_empty_rois = roi_info[sbj+'_'+fa+'_NVox'].isna().sum()
            if (num_empty_rois>0) & verbose: 
                print('++ WARNING: %s has empty %d ROIs' % (sbj+'_'+fa+'_NVox', num_empty_rois))
            roi_info.loc[(roi_info[sbj+'_'+fa+'_NVox'].isna(),sbj+'_'+fa+'_NVox')] = 0
            roi_info[sbj+'_'+fa+'_NVox'] = roi_info[sbj+'_'+fa+'_NVox'].astype(np.int32)
        else:
            if verbose:
              print('++ WARNING: Missing file %s' % path)
  nvox_cols = [c for c in roi_info.columns if 'NVox' in c]
  
  # Select good and bad rois based on minimum number of voxels in FOV
  roi_info['Valid']=(roi_info[nvox_cols]<Nvox_thr).sum(axis=1)==0
  good_rois = roi_info[roi_info['Valid']==True]
  bad_rois  = roi_info[roi_info['Valid']==False]
  
  print('++ INFO: Number of valid rois = %d' % good_rois.shape[0])
  return roi_info, good_rois, bad_rois

def load_qa_metrics(proc_step, data_df):
    """
    This function loads pre-computed values of TSNR, Signal leve, Sigma and SNR (please discard this last one)
    """
    Data_DF = pd.DataFrame(index=data_df.index, 
                       columns=['Sbj','FA',
                                'TSNR_WM','TSNR_GM','TSNR_CSF','TSNR_WMe','TSNR_GMe','TSNR_CSFe',
                                'SNR_WM','SNR_GM','SNR_CSF','SNR_WMe','SNR_GMe','SNR_CSFe',
                                'Smean_WM','Smean_GM','Smean_CSF','Smean_WMe','Smean_GMe','Smean_CSFe',
                                'Sigma_WM','Sigma_GM','Sigma_CSF','Sigma_WMe','Sigma_GMe','Sigma_CSFe'])
    for item in data_df.iterrows():
        idx   = item[0]
        sbj   = item[1]['Sbj']
        fa    = item[1]['FA']
        avail = item[1]['Exists']
        Data_DF.loc[idx,'Sbj'] = sbj
        Data_DF.loc[idx,'FA']  = fa
        if avail:
            if proc_step == 'volreg':
                data_path = osp.join(PrcsData_Dir,sbj,'D03_Preproc_NoRICOR_FIR_{fa}'.format(fa=fa),'pb02.{sbj}_fMRI_{fa}.r01.volreg.STATS.1D'.format(sbj=sbj,fa=fa))
            if proc_step == 'blur':
                data_path = osp.join(PrcsData_Dir,sbj,'D03_Preproc_NoRICOR_FIR_{fa}'.format(fa=fa),'pb03.{sbj}_fMRI_{fa}.r01.blur.STATS.1D'.format(sbj=sbj,fa=fa))
            if proc_step == 'project':
                data_path = osp.join(PrcsData_Dir,sbj,'D03_Preproc_NoRICOR_FIR_{fa}'.format(fa=fa),'errts.{sbj}.tproject.STATS.1D'.format(sbj=sbj,fa=fa))
            if osp.exists(data_path):
                aux_df    = pd.read_csv(data_path,sep=' ')
                for tissue in ['TSNR_WM','TSNR_GM','TSNR_CSF','TSNR_WMe','TSNR_GMe','TSNR_CSFe',
                           'SNR_WM','SNR_GM','SNR_CSF','SNR_WMe','SNR_GMe','SNR_CSFe',
                           'Smean_WM','Smean_GM','Smean_CSF','Smean_WMe','Smean_GMe','Smean_CSFe',
                           'Sigma_WM','Sigma_GM','Sigma_CSF','Sigma_WMe','Sigma_GMe','Sigma_CSFe']:
                    Data_DF.loc[idx,tissue] = aux_df[tissue].values[0]
    Data_DF       = Data_DF.infer_objects()
    Data_DF['FA'] = Data_DF['FA'].astype(int)
    Data_DF['GMvsWM']  = 100 * (Data_DF['Smean_GMe']  - Data_DF['Smean_WMe']) / ((Data_DF['Smean_GMe']  + Data_DF['Smean_WMe'])/2)
    Data_DF['CSFvsWM'] = 100 * (Data_DF['Smean_CSFe'] - Data_DF['Smean_WMe']) / ((Data_DF['Smean_CSFe'] + Data_DF['Smean_WMe'])/2)
    Data_DF['CSFvsGM'] = 100 * (Data_DF['Smean_CSFe'] - Data_DF['Smean_GMe']) / ((Data_DF['Smean_CSFe'] + Data_DF['Smean_GMe'])/2)
    return Data_DF