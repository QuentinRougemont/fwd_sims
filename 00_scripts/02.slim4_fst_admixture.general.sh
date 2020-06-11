#!/bin/bash

#load vcftools
#module load compilers/gcc/5.4
#Global Env
NUMBER=__IDX__
model=__mod__
maf=__MAF__
mkdir -p 02_vcf/"$model"       #.maf"$maf"  #2>/dev/null
mkdir -p 03_results/"$model"   #.maf"$maf" #2>/dev/null 
mkdir -p 04_summaries/"$model".maf"$maf" #2>/dev/null        

#mkdir -p 03_results/"$model" #2>/dev/null
#mkdir -p 04_summaries/"$model" #2>/dev/null
# launch slim file
  toEval="cat 00_scripts/models/script_slim_template."$model".sh | \
      sed 's/__NB__/$NUMBER/g' | \
      sed 's/__mode__/$model/g' " 
      eval $toEval >SLIM_"$model"_"$NUMBER".sh

#recover MINOR allele frequency :
echo $maf
####################################################################
# launch slim
slim SLIM_"$model"_"$NUMBER".sh

####################################################################
# launch admixture
cd 02_vcf/"$model" #.maf"$maf"
inputvcf="$(echo slim."$NUMBER".vcf|sed 's/.vcf//g')"

#comment these line if unwanted
#COLOSSE dependencies
#source /clumeq/bin/enable_cc_cvmfs
#module load vcftools
#module load r/3.4.0

#plink --vcf "$inputvcf".vcf \
#    --recode \
#    --out "$inputvcf".impute \
#    --double-id \
#    --allow-extra-chr 
#plink --file "$inputvcf".impute \
#    --make-bed \
#    --out "$inputvcf".impute \
#    --allow-extra-chr 

#RUN ADMIXTURE
#admixture "$inputvcf".impute.bed 3
input="$inputvcf"

#Alternative admixture estimation with LEA R package
#Rscript 00_scripts/rscript/01.structure.lea_"$model"_"$NUMBER".R "$inputvcf"
#€  toEval="cat ../../00_scripts/rscript/01.structure.lea.R | \
#      sed 's/__NB__/$NUMBER/g' | \
#      sed 's/__mode__/$model/g'"
#      eval $toEval >../../00_scripts/rscript/01.structure.lea_"$model"_"$NUMBER".R

#Rscript ../../00_scripts/rscript/01.structure.lea_"$model"_"$NUMBER".R "$inputvcf".vcf

####################################################################

#compute fst  and heterozygosity
info="../../01_info_file/pop"
cat $info/pop1 |awk '{print $1}' >pop1
cat $info/pop2 |awk '{print $1}' >pop2
cat $info/pop3 |awk '{print $1}' >pop3
cat $info/pop4 |awk '{print $1}' >pop4

#filter vcf if necessary
if [ ! -z "$maf" ]
then
    echo "a MAF filtering will be perform"
    echo "MAF value will be $maf "
    vcftools --vcf "$inputvcf".vcf --maf $maf \
        --out $inputvcf."$maf" --recode 
fi

#then compute summary statistics
outfolder="vcffst"."$maf"
mkdir "$outfolder"
for i in $(ls pop* ) ; 
do 
    for j in  $(ls pop*) ; 
    do
        if [ "$i" != "$j" ] ; then
            if [[ "$i" > "$j" ]] ; then 
                vcftools --vcf "$inputvcf"."$maf".recode.vcf \
                    --weir-fst-pop "$i" \
                    --weir-fst-pop "$j" \
                    --out "$outfolder"/fst_"$inputvcf"_"$i"_vs_"$j"
		    #echo -e " 
		    cut -f 3 "$outfolder"/fst_"$inputvcf"_"$i"_vs_"$j".weir.fst |\
			sed '1d' |grep -v "na" | \
			awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' > \
			../../04_summaries/"$model".maf"$maf"/mean."$inputvcf"_"$i"_vs_"$j".fst ; 
            fi
        fi
    done ; 
done
#exit

#### heterozygosity computation ####
het="vcfhet".maf"$maf"
mkdir "$het" 2>/dev/null
vcftools --vcf "$inputvcf"."$maf".recode.vcf --het --out "$het"/het_"$inputvcf"."$maf" 

paste ../../01_info_file/individuals.list.txt \
	<(sed 1d "$het"/het_"$inputvcf"."$maf".het |cut -f 2- ) \
	> "$het"/het_"$inputvcf"."$maf" 

cd "$het"
#mean het
Rscript ../../../00_scripts/rscript/compute_mean_het.R het_"$inputvcf"."$maf" 

cd ../../../

mv 02_vcf/"$model"/"$het"/*mean_het 04_summaries/"$model".maf"$maf"/

#reshpae mean Fst over replicate for R analysis:
cd 04_summaries

for i in "$model".maf"$maf"/*fst ; 
do
    sed "s#^#$i\t#g" $i |\
    sed 's/\//\t/g' |\
    sed 's/mean.slim./rep/' >> "$model".maf"$maf".fst ;
done

####################################################################
#prepare matrix
#only for Admixture analysis
#paste 01_info_file/individuals.list.txt \
#    <(cut -f 1 02_vcf/"$model"/slim."$NUMBER".impute.3.Q) \
#    >03_results/"$model"/matrix.admixture."$NUMBER".txt
#exit
#cd 03_results/"$model"
#Rscript ../../00_scripts/rscript/compute_admixture_mean.R matrix.admixture."$NUMBER".txt
#cd ../../
#mv 03_results/"$model"/matrix.admixture*.mean.txt 04_summaries/"$model"/  
#mv TOTAL*sh SLIM*sh *err *out 10_log_files/ 
