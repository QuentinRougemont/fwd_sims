# Quick and dirty pipeline for Froward sims

## Purpose

simple pipeline to perform forward simulation and test for admixture between population

## Dependncies

Slim [forward simulator](https://messerlab.org/slim/)

Admixture software avaible [here](https://www.genetics.ucla.edu/software/admixture/)
#or :

Plink software available [here](https://www.cog-genomics.org/plink2)

To create your own scenario make sure to read the Slim doc

## software installation

```bash
unzip SLiM.zip
cd SLiM
make
then add path to bashrc
cd ../

wget https://www.genetics.ucla.edu/software/admixture/binaries/admixture_linux-1.3.0.tar.gz

tar -xvf admixture*.tar.gz

#then add to your bin/
mkdir plink ;cd plink

wget https://www.cog-genomics.org/static/bin/plink180221/plink_linux_x86_64.zip

unzip *.zip

#then add path to bashrc

```
