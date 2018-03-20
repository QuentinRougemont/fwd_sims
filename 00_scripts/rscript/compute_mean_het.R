#!/usr/bin/Rscript
#We compute het with plink

#then:
argv <- commandArgs(T)

het <- argv[1]

a=read.table(het)
a[,6]=(1-a[,2]/a[,4]) #ob het
a[,7]=(1-a[,3]/a[,4])
a[,8]=substr(a[,1],1,3)

#outdata = eval(parse(text = het))
 
b=aggregate(a[,6],list(a[,8]),mean)
write.table(b,paste(het,"mean_het",sep="."), 
	quote=F, 
	row.names=F, 
	col.names=F)
