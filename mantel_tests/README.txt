The folder contains three datasets and two files with R scripts to first produce a map of the samples and then perform Mantel tests

# LGT data

The 'data_lgt' file contains the gene presence-absence information for all LGT. Each row is an individual, and each column is a LGT. '0' indicates the LGT is absent from the individual, while '1' indicates the LGT was detected.

# Individual coordinates

The 'coordinates' text file indicates, for each individual, the latitude and longitude where it was collected, the nuclear_Clade to which is belongs, the colour_group to be used in the map, whether the individual corresponds to one of the five reference genomes, and whether two selected LGT are present or absent.

# Phylogenetic trees

The 'consensus_trees.txt' contains the phylogenetic trees, in nexus format. These are time-calibrated species trees produced with BEAST2. Each tree is based on a random set of five orthologous nuclear genes.

# R script to produce the maps

The 'R.map' text file contains the R script that produces the maps presented in Figure 2.

# R script to perform the Mantel tests

The 'R.mantel' text file contains the R script that will perform the Mantel tests.

First, it computes the pairwise geographic distances from the GPS coordinates.

Second, it computes the minimum pairwise divergence time across the 100 phylogenetic trees.

Third, it computes the number of LGT in common for each pair of individual.

Fourth, it compares the distances matrices using Mantel tests. In a first analysis, permutations are used to compare the number of shared LGT to the pairwise divergence times. In a second analysis, the residuals of a regression of the number of LGT by the pairwise divergence times are compared to the pairwise geographic distances using a new set of permutations. The results are plotted to produce Figure S2.
