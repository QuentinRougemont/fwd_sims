
// set up a simple neutral simulation
initialize() {
	initializeMutationRate(1e-7);
	// m1 mutation type: neutral
	initializeMutationType("m1", 0.5, "f", 0.0);
	// g1 genomic element type: uses m1 for all mutations
	initializeGenomicElementType("g1", m1, 1.0);
	// uniform chromosome of length 10000 kb with uniform recombination
	initializeGenomicElement(g1, 0, 9999999);
	initializeRecombinationRate(1e-8);
}

// create a population of 10000 individuals
1 {
	sim.addSubpop("p1", 2000);
}
1000 {
    sim.addSubpopSplit("p2", 700, p1); 
    sim.addSubpopSplit("p3", 700, p1);
    p1.setSubpopulationSize(700);
}
// P1 = SLR
// P2 = LDM
// P3 = Stock

// add migration rate
1001 {
p1.setMigrationRates(p2,0.001);
p2.setMigrationRates(p1,0.001);
}
3685  {
p1.setMigrationRates(p3, 0.01);
p2.setMigrationRates(p3, 0.01);
}

// extract the appropriate number of samples by pop and output vcf file
3700 late() {allIndividuals = sim.subpopulations.individuals;
pop1=sample(p1.individuals,224,F);
pop2=sample(p2.individuals,56,F);
pop3=sample(p3.individuals,100,F);
combined=c(pop1,pop2,pop3); combined.genomes.outputVCF(filePath="02_vcf/model1/test.slim.__NB__.vcf",outputMultiallelics=F);}
