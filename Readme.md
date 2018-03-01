# Quick and dirty pipeline for Froward simulations.

# Purpose:

simple pipeline to perform forward simulation and test for admixture between population

## Dependencies:

**Slim** [forward simulator](https://messerlab.org/slim/)

**Admixture** software avaible [here](https://www.genetics.ucla.edu/software/admixture/)


**Plink** software available [here](https://www.cog-genomics.org/plink2)

To create your own scenario make sure to read the Slim doc

## software installation

```bash
wget http://benhaller.com/slim/SLiM.zip
unzip SLiM.zip
cd SLiM
make
#then add path to bashrc or cp to bin
cd ../

wget https://www.genetics.ucla.edu/software/admixture/binaries/admixture_linux-1.3.0.tar.gz

tar -xvf admixture*.tar.gz

#then add path to bashrc or cp to bin/
mkdir plink ;cd plink

wget https://www.cog-genomics.org/static/bin/plink180221/plink_linux_x86_64.zip

unzip *.zip

#then add path to bashrc or cp to bin

```

## References:

Haller, B.C., & Messer, P.W. (2017). SLiM 2: Flexible, interactive forward genetic simulations. Molecular Biology and Evolution 34(1), 230–240. [DOI](http://dx.doi.org/10.1093/molbev/msw211)
