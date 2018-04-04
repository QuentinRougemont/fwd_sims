#!/bin/bash

model=model3 #$1
mkdir 02_vcf/"$model"
mkdir 03_matrices/"$model"
NUMBER=__IDX__
# launch slim file
  toEval="cat 00_scripts/models/script_slim_template."$model".sh | \
      sed 's/__NB__/$NUMBER/g'"
   eval $toEval >SLIM_"$NUMBER".sh

# launch slim
slim SLIM_"$NUMBER".sh

# launch admixture
cd 02_vcf/"$model"

inputvcf="$(echo test.slim."$NUMBER".vcf|sed 's/.vcf//g')"

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

#prepare matrix
paste 01_info_file/individuals.list.txt \
    <(cut -f 1 02_vcf/"$model"/test.slim."$NUMBER".impute.3.Q) \
    >03_matrices/"$model"/matrix.admixture."$NUMBER".txt
#exit
