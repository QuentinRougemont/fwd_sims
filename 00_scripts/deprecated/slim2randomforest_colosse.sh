#!/bin/bash
#PBS -A ihv-653-ab
#PBS -N slim2rf.__IDX__
#PBS -o slim2rf.__IDX__.out
#PBS -e slim2rf.__IDX__.err
#PBS -l walltime=24:00:00
#PBS -M YOUREMAIL
####PBS -m ea
#PBS -l nodes=1:ppn=8
#PBS -r n

# Move to job submission directory
cd $PBS_O_WORKDIR

NUMBER=__IDX__

##################################################################################################
################  Module 1: SliM  ################################################################
##################################################################################################


# launch slim file
  toEval="cat 00_scripts/script_slim_template.sh | sed 's/__NB__/$NUMBER/g'"
   eval $toEval >SLIM_"$NUMBER".sh

# launch slim
slim SLIM_"$NUMBER".sh

##################################################################################################
################  Module 2: VCFtools  ############################################################
##################################################################################################


#Clean vcf

vcftools --vcf 02_vcf/test.slim."$NUMBER".vcf --maf 0.05 --remove-filtered-all --recode --max-missing 0.8 --min-alleles 2 --max-alleles 2 --hwe 0.05 --out 02_vcf/dataset."$NUMBER"

# remove LD #NOT IMPLEMENTED
#vcftools --vcf 02_vcf/dataset."$NUMBER".recode.vcf --geno-r2 --min-r2 0.8 --out 02_vcf/LD.sup0.8."$NUMBER"

#awk '{print $1,$2}' 02_vcf/LD.sup0.8."$NUMBER".geno.ld|grep -v 'CHR'|sort -u >02_vcf/list_to_remove."$NUMBER".txt
#vcftools --vcf 02_vcf/dataset.temp."$NUMBER".recode.vcf --exclude list_to_remove."$NUMBER".txt --recode --out 02_vcf/dataset_noLD."$NUMBER"

#clean up
#rm 02_vcf/LD.sup0.8."$NUMBER".geno.ld
#rm 02_vcf/list_to_remove."$NUMBER".txt
rm 02_vcf/test.slim."$NUMBER".vcf
#rm 02_vcf/dataset.temp."$NUMBER".recode.vcf


##################################################################################################
################  Module 3: Admixture ############################################################
##################################################################################################

# launch admixture
cd 02_vcf

inputvcf="$(echo dataset."$NUMBER".recode.vcf|sed 's/.vcf//g')"

plink --vcf "$inputvcf".vcf --recode --out "$inputvcf".impute --double-id --allow-extra-chr --chr-set 55
plink --file "$inputvcf".impute --make-bed --out "$inputvcf".impute --allow-extra-chr --chr-set 55
admixture "$inputvcf".impute.bed 2
cd ..

##################################################################################################
################  Module 4: Prepare matricex #####################################################
##################################################################################################

#prepare matrix
cut -f 1 02_vcf/dataset."$NUMBER".recode.impute.2.Q >02_vcf/admixture."$NUMBER".txt
paste 01_info_file/individuals.list.txt 02_vcf/admixture."$NUMBER".txt >03_matrices/matrix.admixture."$NUMBER".txt

#prepare genetic matrix
grep -v '#' 02_vcf/dataset."$NUMBER".recode.vcf|cut -f -2,10-|sed -e 's/0|0/0/g' -e 's/1|0/1/g' -e 's/0|1/1/g' -e 's/1|1/2/g'|awk '{print $1"_"$2,$0}'|cut -f 1 >03_matrices/loci.matrix."$NUMBER".txt
grep -v '#' 02_vcf/dataset."$NUMBER".recode.vcf|cut -f -2,10-|sed -e 's/0|0/0/g' -e 's/1|0/1/g' -e 's/0|1/1/g' -e 's/1|1/2/g'|awk '{print $1"_"$2,$0}'|cut -f 3- >03_matrices/TEMP.matrix."$NUMBER".txt

grep 'CHR' 02_vcf/dataset."$NUMBER".recode.vcf|cut -f 10- >03_matrices/header."$NUMBER".txt
cat 03_matrices/header."$NUMBER".txt 03_matrices/TEMP.matrix."$NUMBER".txt >03_matrices/matrix.genetic."$NUMBER".txt

rm 03_matrices/TEMP.matrix."$NUMBER".txt
rm 03_matrices/header."$NUMBER".txt


##################################################################################################
################  Module 4: Random Forest ########################################################
##################################################################################################

#launch RF
toEval="cat 00_scripts/script_rf_template.R | sed 's/__NB__/$NUMBER/g'"
   eval $toEval >RANDFOR_"$NUMBER".R

Rscript RANDFOR_"$NUMBER".R

#clean up
mv RANDFOR_"$NUMBER".R 99_log
mv SLIM_"$NUMBER".sh 99_log
mv TOTAL_"$NUMBER".sh 99_log
