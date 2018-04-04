#!/usr/bin/Rscript

ls()
rm(list=ls())
ls()

#load packages
library(stats)
library(randomForest)
library(devtools)
library(reshape2)
library(ggplot2)
library(stringr)
library(stringi)
library(plyr)
library(dplyr) # load this package after plyr to work properly
library(tidyr)
library(readr)
library(randomForestSRC)
library(doParallel)
library(parallel)
library(foreach)
library(purrr)
library(utils)

#upload genetic matrix
matrix.geno<-read.table("03_matrices/matrix.genetic.__NB__.txt",header=TRUE)
names.matrix<-read.table("03_matrices/loci.matrix.__NB__.txt",header=F)
rownames(matrix.geno) = names.matrix [,1]

#upload admixture
matrix.admixture<-read.table("03_matrices/matrix.admixture.__NB__.txt",header=F)
admix=matrix.admixture[,2]

#upload strata
strata<-read.table("01_info_file/strata.txt",header=T)

x=admix
geno_res=NULL
for (i in 1:nrow(matrix.geno)){
  y=as.numeric(matrix.geno[i,])
  w=glm(y~x)
  geno_res=cbind(geno_res,w$residuals)
  }
treatment=as.factor(substr(strata[,2],4,6))


######## random forest wild vs hatchery STEP 1 #######################
######################################################################
rf=randomForest(geno_res,treatment,importance=TRUE,ntree=1000000)
imp=importance(rf, type=1)

#pdf("plotimp1.pdf")
#plot(sort(imp))
#dev.off()

#pdf("plotgrp1.pdf")
#plot(treatment,rf$votes[,1])
#dev.off()
rf$err.rate[1000000,]
#Obtenir seulement les SNP important (valeur depend du coude obtenue avec la figure 
minIMP=0
impSNP=which(imp>=minIMP)
geno_impSNP=geno_res[,impSNP]
marker=c(1:ncol(matrix.geno))
marker_impSNP=marker[impSNP]

######## random forest wild vs hatchery STEP 2 #######################
######################################################################

rf2=randomForest(geno_impSNP,treatment,importance=TRUE,ntree=1000000)
imp2=importance(rf2, type=1)
#pdf("plotimp2.pdf")
#plot(sort(imp2))
#dev.off()

#pdf("plotgrp2.pdf")
#plot(treatment,rf2$votes[,1])
#dev.off()
rf2$err.rate[1000000,]

#Obtenir seulement les SNP important (valeur depend du coude obtenue avec la figure
impSNP2=which(imp2>=minIMP)
geno_impSNP2=geno_impSNP[,impSNP2]
marker_impSNP2=marker_impSNP[impSNP2]

######## random forest wild vs hatchery STEP 3 ############################
######################################################################
rf3=randomForest(geno_impSNP2,treatment,importance=TRUE,ntree=1000000)
imp3=importance(rf3, type=1)

#pdf("plotimp3.pdf")
#par(mfrow=c(1,2))
#plot(sort(imp3),ylab="Permuted importance",xlab="SNPs")
#abline(h=25)
save(rf3,file="04_results/rf3.__NB__.Rda")
#dev.off()
message("rf ok")
#pdf("plotgrp3.pdf")
#plot(treatment,rf3$votes[,1],ylab="Votes",xlab="Treatment")
#dev.off()
rf3$err.rate[1000000,]

#Obtenir seulement les SNP important (valeur depend du coude obtenue avec la figure
impSNP3=which(imp3>=minIMP)
geno_impSNP3=geno_impSNP[,impSNP3]
marker_impSNP3=marker_impSNP[impSNP3]
summary(geno_impSNP3)
str(geno_impSNP3)

str(geno_impSNP)
#extract imp > 40
impSNPinfo40=which(imp3>=40)
geno_impSNPinfo40=geno_impSNP[,impSNPinfo40]
marker_impSNPinfo40=marker_impSNP[impSNPinfo40]
data.info40<-cbind.data.frame(matrix.admixture[,1:2],geno_impSNPinfo40)
markerstemp40<-t(data.info40)
marker.names40<-rownames(markerstemp40)
write.table(marker.names40,file="04_results/selected_markers40.__NB__.txt",quote=F)


impSNPinfo25=which(imp3>=25)
geno_impSNPinfo25=geno_impSNP[,impSNPinfo25]
marker_impSNPinfo25=marker_impSNP[impSNPinfo25]
data.info25<-cbind.data.frame(matrix.admixture[,1:2],geno_impSNPinfo25)
markerstemp25<-t(data.info25)
marker.names25<-rownames(markerstemp25)
write.table(marker.names25,file="04_results/selected_markers25.__NB__.txt",quote=F)
err.rate.df<-rf3$err.rate[1000000,]
write.table(err.rate.df,file="04_results/selected_marker25.err.rate.__NB__.txt",quote=F)
