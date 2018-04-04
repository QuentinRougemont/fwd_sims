#!/bin/bash

ITERATION=$1

#prepare indivduals list
awk '{print $1}' 01_info_file/strata.txt|grep -v 'INDIV' >01_info_file/individuals.list.txt

#launch loop
for i in $(eval echo "{1..$ITERATION}")
do
  toEval="cat 00_scripts/slim2randomforest_colosse.sh | sed 's/__IDX__/$i/g'"
    eval $toEval >TOTAL_"$i".sh
done

#launch scripts

for i in $(ls TOTAL*sh)
do
chmod +x $i
msub "$i"
done
