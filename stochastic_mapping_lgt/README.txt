The folder contains two datasets and two files with R scripts to first run the stochastic mapping and then summarize the results.

# LGT data

The 'data_lgt' file contains the gene presence-absence information for all LGT. Each row is an individual, and each column is a LGT. '0' indicates the LGT is absent from the individual, while '1' indicates the LGT was detected.

# Phylogenetic trees

The 'consensus_trees.txt' contains the phylogenetic trees, in nexus format. These are time-calibrated species trees produced with BEAST2. Each tree is based on a random set of five orthologous nuclear genes.

# R script to run the stochastic mapping

The 'R.stoch.map' contains the script to run the stochastic mapping.

It first calculates the likelihood of each LGT for each of the 100 species trees. The results are written in a 'likelihoods' file, which allows the analyses to restart from there if needed.

The script then runs the stochastic mapping for each LGT. It then extracts the LGT origins for each of the five reference genomes, if there is a single origin inferred along its ancestors (else, a 'NA' is put). The results are then written in five files, one per reference genome. The stochastic mapping is repeated 100 times.

# R script to analyse the stochastic mapping results

The 'R.analyses' script summarizes the stochastic mapping results, performs statistical analyses and produces figures.

First, for each of the 100 stochastic mapping replicates, the number of LGT per 1 Ma time slice from 0 to 11 Ma is recorded. For each reference genome and each time slice, the mean number of LGT across replicates is also recorded.

Second, the number of LGT without an inferred age is recorded.

Third, the rate of LGT gains ('int') and the rate of LGT losses (one minus 'slope') are recorded for each of the 100 stochastic mapping replicates.

Fourth, the number of LGT per time slice are plotted against time for the individual stochastic mapping repeats (Figure S3).

Fifth, for each genome, the mean number of LGT per time slice is plotted against time, and the rate of LGT gains and LGT losses are calculated using an exponential decay model (Figure 3a).

Sixth, the different estimates are plotted by genome, including the number of LGT that would have been gained if the missing data were evenly distributed across time slice (Figure 3b, 3c, and 3d).
