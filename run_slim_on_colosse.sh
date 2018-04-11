#!/bin/bash
#PBS -A ihv-653-aa
#PBS -N slim2_
#PBS -o slim2.out
#PBS -e slim2.err
#PBS -l walltime=44:10:00
##PBS -M YOUREMAIL
##PBS -m ea
#PBS -l nodes=1:ppn=8
#PBS -r n

# Move to job submission directory
cd $PBS_O_WORKDIR


#01.launch_slim.sh
for i in $(cat list_model);
do
	./00_scripts/01.launch_slim.sh model$i
done
#
