echo "#swarm -f FA09a_BringCleanDataToMNI.SWARM.sh -g 32 -t 32 --partition quick,normal; watch -n 30 squeue -u javiergc" > FA09a_BringCleanDataToMNI.SWARM.sh
for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  for FA in 015 050 077 090
  do
    echo "export SBJ=${SBJ} FA=${FA}; sh ./FA09a_BringCleanDataToMNI.sh" >> FA09a_BringCleanDataToMNI.SWARM.sh
  done
done
