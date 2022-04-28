The folder contains 12 scripts that were used to detect and validate LGT in the five reference genomes.

#Generate alignments and build trees from protein-coding sequences # 2 files
The file 'cds_to_trees.sh' contains all the commands used to build alignments of orthogroups from a set of CDS and to build trees from the resulting alignments. Dependencies: 'unwrap.pl', Blastn, mafft, phyML and SMS.

#Identify Alloteropsis phylogenetic placement for each gene and filter midpoint-rooted trees compatible with a LGT scenario # 2 files

The file 'id_sister.pl' contains a Perl script that produces a tabular file reporting the group identity of the sequence sister to the Alloteropsis gene and the one of their combined sister group. 
The file 'tree_filtering_1.pl' contains a Perl script to filter out automatically no-LGT trees based on the table produced by the previous script.

#Identifify secondary candidates # 4 files

The file 'main_fragment.sh' articulates commands to generate coverage plots of the close relatives and potential donors up/downstream of LGT candidates. Dependencies: R, samtools, bedtools, LGT_figs_Part1.R LGT_figs_Part2.R and split_annotated_seq.pl.

#AU-test # 4 files

The file 'constrain_topology.pl' is used to produce constrained newick trees where Alloteropsis as well as the donor clade monophyly are enforced. 
The file 'topology_test.sh' implements all the steps to perform AU-test: site-wise likelihood are produced for constrained and unconstrained trees and compared with Consel. Dependencies: raxML, R, remove_edges.R, SMS and sms_CON_site.sh and Consel.




