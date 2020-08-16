echo "#swarm -f FA02_Preproc_Anat.SWARM.sh -g 32 -t 32 --partition quick,normal" > FA02_Preproc_Anat.SWARM.sh
for sbj in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
    echo "export SBJ=${sbj}; sh ./FA02_Preproc_Anat.sh" >> FA02_Preproc_Anat.SWARM.sh
done
