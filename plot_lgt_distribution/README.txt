The folder contains four datasets and one file R scripts to plot the LGT distribution.

# LGT data

The 'data_lgt' file contains the gene presence-absence information for all LGT. Each row is an individual, and each column is a LGT. '0' indicates the LGT is absent from the individual, while '1' indicates the LGT was detected.

# Donor identity

The 'donor.txt' text file lists, for each LGT, the identity of the group of donor. It is in the same order as the 'data_lgt' file.

# Block number

The 'block.txt' text file lists, for each LGT, the number of the block that contains it. It is in the same order as the 'data_lgt' file.

# Consensus tree

The file contains the consensus species tree computed across the 100 species trees inferred from random sets of five nuclear orthologs.

# R script to plot the presence-absence data

The 'R.plot.phylo' text file contains the R script to plot the LGT presence-absence data.

First, it assigns each individual to one of five groups. These are later used to colour the points.

Second, it plots the presence-absence data by gene, to produce the right panel of Figure 1.

Third, it plots the data as genomic blocks, to produce Figure S1.
