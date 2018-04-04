#!/bin/bash
#PBS -A ihv-653-aa
#PBS -N slim2.__mod__.__IDX__
#PBS -o slim2.__mod__.__IDX__.out
#PBS -e slim2.__mod__.__IDX__.err
#PBS -l walltime=02:10:00
##PBS -M YOUREMAIL
###PBS -m ea
#PBS -l nodes=1:ppn=8
#PBS -r n

# Move to job submission directory
#cd $PBS_O_WORKDIR

#load vcftools
#source /clumeq/bin/enable_cc_cvmfs
#module load vcftools
#module load r/3.4.0
#module load compilers/gcc/5.4
#Global Env
NUMBER=__IDX__
model=__mod__
mkdir 02_vcf/"$model"
mkdir 03_results/"$model"
mkdir 04_summaries/"$model"
# launch slim file
  toEval="cat 00_scripts/models/script_slim_template."$model".sh | \
      sed 's/__NB__/$NUMBER/g' | \
      sed 's/__mode__/$model/g'"
      eval $toEval >SLIM_"$model"_"$NUMBER".sh

####################################################################
# launch slim
slim SLIM_"$model"_"$NUMBER".sh

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
input="$inputvcf"
#
Rscript 00_scripts/rscript/01.structure.lea_"$model"_"$NUMBER".R "$inputvcf"
  toEval="cat ../../00_scripts/rscript/01.structure.lea.R | \
      sed 's/__NB__/$NUMBER/g' | \
      sed 's/__mode__/$model/g'"
      eval $toEval >../../00_scripts/rscript/01.structure.lea_"$model"_"$NUMBER".R

Rscript ../../00_scripts/rscript/01.structure.lea_"$model"_"$NUMBER".R "$inputvcf".vcf

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

source /clumeq/bin/enable_cc_cvmfs
module load vcftools
module load r/3.4.0
module load compilers/gcc/5.4
#
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
                    --out "$outfolder"/fst_"$inputvcf"_"$i"_vs_"$j" 
		    sed '1d' "$outfolder"/fst_"$inputvcf"_"$i"_vs_"$j".weir.fst \
			cut -f 3 |grep -v "na" | \
			awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' > \
			../../04_summaries/"$model"/mean."$inputvcf"_"$i"_vs_"$j".fst ; 
            fi
        fi
    done ; 
done

het="vcfhet"
mkdir "$het"
vcftools --vcf "$inputvcf".vcf --het --out "$het"/het_"$inputvcf" 

paste ../../01_info_file/individuals.list.txt \
	<(sed 1d "$het"/het_"$inputvcf".het |cut -f 2- ) \
	> "$het"/het_"$inputvcf" 

cd "$het"
#mean het
Rscript ../../../00_scripts/rscript/compute_mean_het.R het_"$inputvcf" 

cd ../../../

mv 02_vcf/"$model"/"$het"/*mean_het 04_summaries/"$model"/

####################################################################
#prepare matrix
paste 01_info_file/individuals.list.txt \
    <(cut -f 1 02_vcf/"$model"/slim."$NUMBER".impute.3.Q) \
    >03_results/"$model"/matrix.admixture."$NUMBER".txt
#exit
cd 03_results/"$model"
Rscript ../../00_scripts/rscript/compute_admixture_mean.R matrix.admixture."$NUMBER".txt
cd ../../
mv 03_results/"$model"/matrix.admixture*.mean.txt 04_summaries/"$model"/  
#mv TOTAL*sh SLIM*sh *err *out 10_log_files/ 
