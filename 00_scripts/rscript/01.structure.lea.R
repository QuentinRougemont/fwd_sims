#!/usr/bin/Rscript
##!/usr/local/bioinfo/src/R/R-3.2.2/bin/Rscript

#if("LEA" %in% rownames(installed.packages()) == FALSE) {source("http://bioconductor.org/biocLite.R") ; biocLite("LEA") }

library(LEA)

#conversion to genotype format
argv <- commandArgs(T)
input <- argv[1]
dir.create('04_lea/')
dir.create('04_lea/__mode__.slim.__NB__')

output = vcf2geno(input,"04_lea/__mode__.slim.__NB__/slim.__NB__.genotype.geno")
#dir.create('04_lea/__mode_.slim._NB__')
#1. Estimating K
obj.at = snmf("./04_lea/__mode__.slim.__NB__/slim.__NB__.genotype.geno", K = 3, ploidy = 2, entropy = T,repetitions=10,alpha=10,percentage=0.05,
              CPU = 12, project = "new")

pop <- as.matrix((read.table("../../01_info_file/strata.txt")[,2] )) #pop names
ce = cross.entropy(obj.at, K = 3)
best = which.min(ce)

qmatrix = Q(obj.at, K = 3, best)


b=aggregate(qmatrix,list(pop),mean) 
write.table(b, paste("lea.__mode__slim.__NB__.mean.txt",sep="."), 
	quote=F, 
	row.names=F, 
	col.names=F)

