#!/bin/bash
#PBS -A ihv-653-aa
#PBS -N slim2.__IDX__
#PBS -o slim2.__IDX__.out
#PBS -e slim2.__IDX__.err
#PBS -l walltime=12:10:00
#PBS -M YOUREMAIL
####PBS -m ea
#PBS -l nodes=1:ppn=8
#PBS -r n

# Move to job submission directory
cd $PBS_O_WORKDIR

#Global Env
NUMBER=__IDX__
model=__mod__
mkdir 02_vcf/"$model"
mkdir 03_results/"$model"

# launch slim file
  toEval="cat 00_scripts/models/script_slim_template."$model".sh | \
      sed 's/__NB__/$NUMBER/g'"
   eval $toEval >SLIM_"$NUMBER".sh

####################################################################
# launch slim
slim SLIM_"$NUMBER".sh

####################################################################
# launch admixture
cd 02_vcf/"$model"

inputvcf="$(echo slim."$NUMBER".vcf|sed 's/.vcf//g')"

plink --vcf "$inputvcf".vcf \
    --recode \
    --out "$inputvcf".impute \
    --double-id \
    --allow-extra-chr 
plink --file "$inputvcf".impute \
    --make-bed \
    --out "$inputvcf".impute \
    --allow-extra-chr 

admixture "$inputvcf".impute.bed 3

cd ../../

####################################################################
#prepare matrix
paste 01_info_file/individuals.list.txt \
    <(cut -f 1 02_vcf/"$model"/slim."$NUMBER".impute.3.Q) \
    >03_results/"$model"/matrix.admixture."$NUMBER".txt
#exit

mv TOTAL*sh SLIM*sh *err *out 10_log_files/ 
