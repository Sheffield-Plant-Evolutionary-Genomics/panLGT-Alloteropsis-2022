The folder contains two datasets and two files with R scripts to first run the stochastic mapping and then summarize the results of gene losses.

# Loss data

The 'data_losses' file contains the gene presence-absence information for all native genes that were variable among the five reference genomes. Each row is an individual, and each column is a gene. '0' indicates the gene is absent from the individual, while '1' indicates the gene was detected.

# Phylogenetic trees

The 'consensus_trees.txt' contains the phylogenetic trees, in nexus format. These are time-calibrated species trees produced with BEAST2. Each tree is based on a random set of five orthologous nuclear genes.

# R script to run the stochastic mapping

The 'R.stoch.map' contains the script to run the stochastic mapping.

It first inverts 0 and 1 in the dataset, to then use analyses analogous to those applied to LGT.

The likelihood of each gene for each of the 100 species trees is then calculated. The results are written in a 'likelihoods' file, which allows the analyses to restart from there if needed.

The script then runs the stochastic mapping for each gene. It then extracts the gene loss ages for each of the five reference genomes, if there is a single loss inferred along its ancestors (else, a 'NA' is put). The results are then written in five files, one per reference genome. The stochastic mapping is repeated 100 times.

# R script to analyse the stochastic mapping results

The 'R.analyses' script summarizes the stochastic mapping results, performs statistical analyses and produces figures.

First, for each of the 100 stochastic mapping replicates, the number of gene losses per 1 Ma time slice from 0 to 11 Ma is recorded. For each reference genome and each time slice, the mean number of gene losses across replicates is also recorded.

Second, the number of genes without an inferred age of loss is recorded.

Third, the mean rate of losses is calculated across the eight most recent time slices for each of the five reference genomes. The number of losses assuming the missing data are evenly spread across time slices is also calculated, as well as the proportion of analysed genes lost every Ma.

Fourth, the mean rate of losses is calculated for each replicate, and the quantiles are extracted.

Fifth, the inferred number of losses are plotted against time, for each of the five reference genomes (Figure S4).

Sixth, the estimated rates of losses are written in an 'estimates.txt' text file.
