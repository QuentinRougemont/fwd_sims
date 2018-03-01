#!/bin/bash

ITERATION=100
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

#launch loop
for i in $(eval echo "{1..$ITERATION}")
do
    toEval="cat 00_scripts/colosse/02.slim2admixture.general.sh  | \
        sed 's/__IDX__/$i/g' | \
        sed 's/__mod__/$model/g'"
    eval $toEval  > TOTAL_"$model"_"$i".sh
done
#launch scripts
#exit
for i in $(ls TOTAL*sh)
do
chmod +x $i
msub "$i"
done
