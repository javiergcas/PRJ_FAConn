import os.path as osp

PRJDIR  = '/data/SFIM_FlipAngle/PRJ_FAConn'
SBJLIST = ['P001','P002','P004','P005','P006','P007','P008','P009','P010','P012','P013','P014','P017','P018','P019','P020'] 
FAs     = ['015','050','077','090']

PrcsData_Dir  = osp.join(PRJDIR,'PrcsData')
Resources_Dir = osp.join(PRJDIR,'Resources')
Results_Dir   = osp.join(PRJDIR,'Results')
Atlas_Dir     = osp.join(Resources_Dir,'Atlases')

Shaefer2018_Dir = osp.join(Atlas_Dir,'Schaefer2018')

DF_AvailData_Path   = osp.join(Resources_Dir,'Available_Data_Info.pkl')
DF_TSNR_Path        = osp.join(Results_Dir,'TSNR_DF.pkl')
DF_TSNR_VolReg_Path = osp.join(Results_Dir,'TSNR_Volreg_DF.pkl')