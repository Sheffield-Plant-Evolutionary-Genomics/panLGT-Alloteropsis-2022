The folder contains six files and one folder. The folder contains the alignments of BUSCO orthologs, in phylip format, and five scripts that are used to prepare the files and analyse the results of BEAST2 analyses.

# Perl script to prepare the xml file

The file 'xmlprepare.pl' contains a Perl script that lists the phylip format alignments available in the 'clean-phy' folder, picks five of them randomly, then writes a xml format file in a new folder named 'repeat.X.run1/run.X.xml. The text file 'end.xml' is used when printing the files into the xml format. The folder is then copied into a 'repeat.X.run2' folder. The process is repeated 100 times. The list of genes used in each repeat is printed in the text file 'gene_summary'.

# R script to monitor the runs

The text file 'R.process' contains a R script to remove trees corresponding to the burn-in period and then verify that the two runs have converged, merge the posterior samples from the two runs, and calculate the ESS from them.

# R script to combined the sampled trees

The 'R.combine_trees' contains a R script to combine the posterior trees from the two runs into a single file named 'repeat.X.trees' in the 'summary_trees' folder.

# Perl script to infer and combine consensus trees

The file 'combine_annotate_trees.pl' contains a Perl script that uses treeannotator to compute the consensus tree from the posterior trees of each repeat, and then combine the 100 consensus trees into a single file named 'consensus_trees.txt'

The path to treeannotator needs to be changed, replacing '~/prog/BEAST_with_JRE.v2.6.4.Linux/beast/bin/treeannotator' on line 11 with the correct path.

# R code to plot the trees

The text file 'R.densitree' contains a R script to plot the trees using Densitree, and to produce the left panel of Figure 1.
