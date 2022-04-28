#Generate alignments and build trees from protein-coding sequences # 2 files

The file 'cds_to_trees.sh' contains all the commands used to build alignments of orthogroups from a set of CDS and to build trees from the resulting alignments. Dependencies: 'unwrap.pl', Blastn, mafft, phyML and SMS.

The same script is used for the 37-taxa trees only using thre top-hit match, and the denser trees with more taxa and all blast matches over a theshold length (300bp) are used. the only difference between these two runs are the number of blast databses used, and the "head -n 1" needs to be removed from Step 1 so that more than the top hit blast match is used 
