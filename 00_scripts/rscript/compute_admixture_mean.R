#!/usr/bin/Rscript

argv <- commandArgs(T)

admix <- argv[1]

a=read.table(admix)
b=read.table("../../01_info_file/strata.txt")[,2]
mat=aggregate(a[,c(2:4)],list(b),mean)

#outdata = eval(parse(file = admix))
 
write.table(mat , paste(admix,"mean.txt",sep="."), 
	quote=F, 
	row.names=F, 
	col.names=F)



