 // set up a simple neutral simulation
 // We rescale everything by a factor of 20
initialize() {
    initializeMutationRate(2e-7);
    // m1 mutation type: neutral
    initializeMutationType("m1", 0.5, "f", 0.0);
    // g1 genomic element type: uses m1 for all mutations
    initializeGenomicElementType("g1", m1, 1.0);
    // uniform chromosome of length 1Mb with uniform recombination
    initializeGenomicElement(g1, 0, 999999);
    //assumed inital r = 1e-08 and rescaled using 1/2*(1-(1-2r)^n)
    initializeRecombinationRate(2e-07);
}

// create a population of 50 000 individuals // rescaled by 20 //time are all rescale by 20
1 {
        sim.addSubpop("p1", 500);
}
6250 {
    subpopCount = 4;
    for (i in 2:subpopCount)
       sim.addSubpop(i, 2500);
    for (i in 2:subpopCount)
       sim.subpopulations[i-1].setMigrationRates(i-1, 0.01);
    for (i in 1:(subpopCount-1))
        sim.subpopulations[i-1].setMigrationRates(i+1, 0.01);
}
// extract the appropriate number of samples by pop and output vcf file
//we let the pop evolved for 50 000 generation again rescaled by 20
2500 late() {allIndividuals = sim.subpopulations.individuals;
pop1=sample(p1.individuals,50,F);
pop2=sample(p2.individuals,50,F);
pop3=sample(p3.individuals,50,F);
pop4=sample(p4.individuals,50,F);
combined=c(pop2,pop1,pop3,pop4); combined.genomes.outputVCF(filePath="02_vcf/__mode__/slim.__NB__.vcf",outputMultiallelics=F);}

