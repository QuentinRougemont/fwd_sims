#!/bin/bash

NUMBER=__IDX__
# launch slim file
  toEval="cat 00_scripts/script_slim_template.sh | sed 's/__NB__/$NUMBER/g'"
   eval $toEval >SLIM_"$NUMBER".sh

# launch slim
slim SLIM_"$NUMBER".sh

# launch admixture
cd 02_vcf

inputvcf="$(echo test.slim."$NUMBER".vcf|sed 's/.vcf//g')"

plink --vcf "$inputvcf".vcf --recode --out "$inputvcf".impute --double-id --allow-extra-chr #--chr-set 55
plink --file "$inputvcf".impute --make-bed --out "$inputvcf".impute --allow-extra-chr #--chr-set 55
admixture "$inputvcf".impute.bed 3
cd ..
#exit
#prepare matrix
cut -f 1 02_vcf/test.slim."$NUMBER".impute.3.Q >02_vcf/admixture."$NUMBER".txt
paste 01_info_file/individuals.list.txt 02_vcf/admixture."$NUMBER".txt >03_matrices/matrix.admixture."$NUMBER".txt

#prepare genetic matrix
grep -v '#' 02_vcf/test.slim."$NUMBER".vcf|cut -f -2,10-|sed -e 's/0|0/0/g' -e 's/1|0/1/g' -e 's/0|1/1/g' -e 's/1|1/2/g'|awk '{print $1"_"$2,$0}'|cut -f 1 >03_matrices/loci.matrix."$NUMBER".txt
grep -v '#' 02_vcf/test.slim."$NUMBER".vcf|cut -f -2,10-|sed -e 's/0|0/0/g' -e 's/1|0/1/g' -e 's/0|1/1/g' -e 's/1|1/2/g'|awk '{print $1"_"$2,$0}'|cut -f 3- >03_matrices/TEMP.matrix."$NUMBER".txt

grep 'CHR' 02_vcf/test.slim.1.vcf|cut -f 10- >03_matrices/header."$NUMBER".txt
cat 03_matrices/header."$NUMBER".txt 03_matrices/TEMP.matrix."$NUMBER".txt >03_matrices/matrix_genetic."$NUMBER".txt

rm 03_matrices/TEMP.matrix."$NUMBER".txt
exit

#launch RF
toEval="cat 00_scripts/script_rf_template.R | sed 's/__NB__/$NUMBER/g'"
   eval $toEval > RANDFOR_"$NUMBER".R

Rscript RANDFOR_"$NUMBER".R

#clean up
mv RANDFOR_"$NUMBER".R 99_log
mv SLIM_"$NUMBER".sh 99_log
mv TOTAL_"$NUMBER".sh 99_log
