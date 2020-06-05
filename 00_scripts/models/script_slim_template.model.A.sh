 // set up a simple neutral simulation
 // We rescale everything by a factor of ten
initialize() {
    initializeMutationRate(2e-7);
    // m1 mutation type: neutral
    initializeMutationType("m1", 0.5, "f", 0.0);
    // g1 genomic element type: uses m1 for all mutations
    initializeGenomicElementType("g1", m1, 1.0);
    // uniform chromosome of length 1Mb with uniform recombination
    initializeGenomicElement(g1, 0, 4999999);
    initializeRecombinationRate(9.999999e-08);
}

// create a population of 100 000 individuals // rescaled by 10 //time are all rescale by 10
1 {
    subpopCount = 4;
    for (i in 1:subpopCount)
       sim.addSubpop(i, 500);
    for (i in 2:subpopCount)
       sim.subpopulations[i-1].setMigrationRates(i-1, 0.1);
    for (i in 1:(subpopCount-1))
        sim.subpopulations[i-1].setMigrationRates(i+1, 0.1);
}
// extract the appropriate number of samples by pop and output vcf file
10000 late() {allIndividuals = sim.subpopulations.individuals;
pop1=sample(p1.individuals,50,F);
pop2=sample(p2.individuals,50,F);
pop3=sample(p3.individuals,50,F);
pop4=sample(p4.individuals,50,F);
combined=c(pop2,pop1,pop3,pop4); combined.genomes.outputVCF(filePath="02_vcf/__mode__/slim.__NB__.vcf",outputMultiallelics=F);}

