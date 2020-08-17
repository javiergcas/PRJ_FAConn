set -e

PRJDIR='/data/SFIM_FlipAngle/PRJ_FAConn2/'

echo "#swarm -f ./FA05_CreateNiis_and_Masks.SWARM.sh -g 32 -t 32 --partition quick,norm" > ./FA05_CreateNiis_and_Masks.SWARM.sh

for SBJ in P001 P002 P004 P005 P006 P007 P008 P009 P010 P012 P013 P014 P017 P018 P019 P020
do
  for FA in 015 050 077 090
  do
      echo "export SBJ=${SBJ} FA=${FA}; sh ./FA05_CreateNiis_and_Masks.sh" >> ./FA05_CreateNiis_and_Masks.SWARM.sh
  done
done
