#!/bin/bash

ITERATION=2
model=$1 #"model6"

if [ -z "$ITERATION" ]
then
    echo "error please provide number of ITER"
    exit    
fi

#model=$2
if [ -z "$model" ]
then
    echo "error! please provide model name"
    exit    
fi

#prepare indivduals list
awk '{print $1}' 01_info_file/strata.txt \
    >01_info_file/individuals.list.txt

#prepare pop list:
mkdir 01_info_file/pop 2>/dev/null
cut -f 2 01_info_file/strata.txt | \
	sort |uniq > 01_info_file/list_pop
for i in $(cat 01_info_file/list_pop) ; 
do
    grep "$i"  01_info_file/strata.txt > 01_info_file/pop/"$i" 
done 

#launch loop
for i in $(eval echo "{1..$ITERATION}")
do
    toEval="cat 02.slim2admixture.general.sh  | \
        sed 's/__IDX__/$i/g' | \
        sed 's/__mod__/$model/g'"
    eval $toEval  > TOTAL_"$model"_"$i".sh
done
#launch scripts
#exit
for i in $(ls TOTAL*sh)
do
chmod +x $i
"./$i"
done

#mv TOTAL*sh SLIM*sh *err *out 10_log_files/ 
