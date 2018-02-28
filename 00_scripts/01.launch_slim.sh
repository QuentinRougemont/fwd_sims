#!/bin/bash


ITERATION=$1
#model=$2
#prepare indivduals list
awk '{print $1}' 01_info_file/strata.txt| \
    grep -v 'INDIV' \
    >01_info_file/individuals.list.txt

#launch loop
for i in $(eval echo "{1..$ITERATION}")
do
  toEval="cat 00_scripts/02.slim2admixture.sh | sed 's/__IDX__/$i/g'"
    eval $toEval > TOTAL_"$i".sh
done

#launch scripts

for i in $(ls TOTAL*sh)
do
chmod +x $i
./"$i"
done

