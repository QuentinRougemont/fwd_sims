#!/bin/bash
#PBS -A ihv-653-aa
#PBS -N slim2.__mod__.__IDX__
#PBS -o slim2.__mod__.__IDX__.out
#PBS -e slim2.__mod__.__IDX__.err
#PBS -l walltime=12:10:00
#PBS -M YOUREMAIL
####PBS -m ea
#PBS -l nodes=1:ppn=8
#PBS -r n

# Move to job submission directory
cd $PBS_O_WORKDIR

#load packages if necessary
#source /clumeq/bin/enable_cc_cvmfs
#module load vcftools

#Global Env
NUMBER=__IDX__
model=__mod__
mkdir 02_vcf/"$model"
mkdir 03_results/"$model"

# launch slim file
  toEval="cat 00_scripts/models/slim."$model".sh | \
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
####################################################################
#compute fst  and heterozygosity
info="../../01_info_file/pop"
pop1=$(wc -l $info/slr |awk '{print $1}')
pop2=$(wc -l $info/ldm |awk '{print $1}')
pop3=$(wc -l $info/src |awk '{print $1}')
pop2a=$(( $pop1 + 1 ))
pop2b=$(( $pop1 + $pop2 ))
pop3a=$(( $pop1 + $pop2 + 1))
pop3b=$(( $pop1 + $pop2 + $pop3 ))

grep "POS" "$inputvcf".vcf | \
    perl -pe 's/\t/\n/g' | \
    sed 1,9d | \
    sed -n 1,"$pop1"p > pop1
grep "POS" "$inputvcf".vcf | \
    perl -pe 's/\t/\n/g' | \
    sed 1,9d | \
    sed -n "$pop2a","$pop2b"p > pop2

grep "POS" "$inputvcf".vcf | \
    perl -pe 's/\t/\n/g' | \
    sed 1,9d | \
    sed -n "$pop3a","$pop3b"p > pop3

outfolder="vcffst"
mkdir "$outfolder"
for i in $(ls pop* ) ;
do
    for j in  $(ls pop*) ;
    do
        if [ "$i" != "$j" ] ; then
            if [[ "$i" > "$j" ]] ; then
                vcftools --vcf "$inputvcf".vcf \
                    --weir-fst-pop "$i" \
                    --weir-fst-pop "$j" \
                    --out "$outfolder"/fst_"$inputvcf"_"$i"_vs_"$j" ;
            fi
        fi
    done ;
done
het="vcfhet"
mkdir "$het"
vcftools --vcf "$inputvcf".vcf  --out "$het"/het_"$inputvcf"

cd ../../

####################################################################
#prepare matrix
paste 01_info_file/individuals.list.txt \
    <(cut -f 1 02_vcf/"$model"/slim."$NUMBER".impute.3.Q) \
    >03_results/"$model"/matrix.admixture."$NUMBER".txt
#exit

#mv TOTAL*sh SLIM*sh *err *out 10_log_files/ 
