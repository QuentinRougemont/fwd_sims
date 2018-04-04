#!/usr/bin/Rscript
##!/usr/local/bioinfo/src/R/R-3.2.2/bin/Rscript

#if("LEA" %in% rownames(installed.packages()) == FALSE) {source("http://bioconductor.org/biocLite.R") ; biocLite("LEA") }

library(LEA)

#conversion to genotype format
argv <- commandArgs(T)
input <- argv[1]
dir.create('04_lea/')
dir.create('04_lea/model26.slim.90')

output = vcf2geno(input,"04_lea/model26.slim.90/slim.90.genotype.geno")
#dir.create('04_lea/__mode_.slim._NB__')
#1. Estimating K
obj.at = snmf("./04_lea/model26.slim.90/slim.90.genotype.geno", K = 3, ploidy = 2, entropy = T,repetitions=10,alpha=10,percentage=0.05,
              CPU = 12, project = "new")

#pdf(file="CV.full.data.pdf",12,8)
#plot(obj.at, col = "blue4", cex = 1.4, pch = 19)
#dev.off()
pop <- as.matrix((read.table("../../01_info_file/strata.txt")[,2] )) #pop names
ce = cross.entropy(obj.at, K = 3)
best = which.min(ce)

qmatrix = Q(obj.at, K = 3, best)

#K = ncol(qmatrix)
#Npop <-  length(unique(pop))

b=aggregate(qmatrix,list(pop),mean) 
write.table(b, paste("lea.model26slim.90.mean.txt",sep="."), 
	quote=F, 
	row.names=F, 
	col.names=F)


#tmp1<- mapply(rowsum, as.data.frame(qmatrix), as.data.frame(pop))
#dimnames(tmp1)<- list(levels(factor(pop[,c(1)]))) #, 1:nrow(samp.siz.1[,c(1)]))
#tmp<-as.matrix(table(pop))
#tmp=rep(cbind(tmp),ncol(qmatrix))
#qpop<-tmp1/tmp


