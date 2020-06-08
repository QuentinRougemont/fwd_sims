# Quick and dirty pipeline for Forward simulations.

# Purpose:

simple pipeline to perform forward simulation and test for admixture between population

this pipeline was original used to test for:  
* the dilution effect following admixture of a small pop into a large pop.
* dilution + selective effect due to fitness differences between the pop.
The results were published [here](https://onlinelibrary.wiley.com/doi/full/10.1111/eva.12765)

other simple modifications include: 
* computation of Fst/admixture/Heterozygotie under 4pop linear stepping stone models
* compputation of Fst/admixture/Het under under more complex models


## Dependencies:

**Slim** [forward simulator](https://messerlab.org/slim/)

**Admixture** software avaible [here](https://www.genetics.ucla.edu/software/admixture/)


**Plink** software available [here](https://www.cog-genomics.org/plink2)


**vcftools** software available [here](https://github.com/vcftools/vcftools.git)
To create your own scenario make sure to read the Slim doc

**R** software eventually with LEA R package available from [bioconductor](https://www.bioconductor.org/packages/3.7/bioc/html/LEA.html)
see also script `00_scripts/rscript/01.structure.lea.R` for fast installation.

## software installation for LINUX USERS:

```bash
wget http://benhaller.com/slim/SLiM.zip
unzip SLiM.zip
mkdir build
cd build
cmake ../SLiM
make slim
#then add path to bashrc or cp to bin
cd ../

wget https://www.genetics.ucla.edu/software/admixture/binaries/admixture_linux-1.3.0.tar.gz

tar -xvf admixture*.tar.gz

#then add path to bashrc or cp to bin/
mkdir plink ;cd plink

wget https://www.cog-genomics.org/static/bin/plink180221/plink_linux_x86_64.zip

unzip *.zip

#then add path to bashrc or cp to bin

cd ../
git clone https://github.com/vcftools/vcftools.git
./autogen.sh
./configure --prefix=/path/to/vcftools/
make
make install

```

## Running a model:

1. pick a model in 00_scripts/models/*sh.
2. edit the model if necessary
3. set the number of forward simulation in `./00_scripts/01.launch_slim.sh`
4. runs as follows:
```bash
./00_scripts/01.launch_slim.sh model"$id" 
```

## References:

Haller, B.C., & Messer, P.W. (2017). SLiM 2: Flexible, interactive forward genetic simulations. Molecular Biology and Evolution 34(1), 230–240. [DOI](http://dx.doi.org/10.1093/molbev/msw211)
