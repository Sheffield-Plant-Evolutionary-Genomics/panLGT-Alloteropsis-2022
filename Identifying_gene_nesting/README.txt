## ID sister relationships

This process gene trees and idetifies the sister branch/clade to a query sequence, and then their combined sister branch/clade. It also reports the bootstrap values.


## Step 1: sister relation ships for all query sequences

to un the scrip

perl id_sister.pl Direcoty_of_gene_trees query_sequence_ID

The clades are defined based on the sequence names within the perl script itself and is set up at present for use in this study. 

The file 'id_sister.pl' contains a Perl script that produces a tabular file reporting the group identity of the sequence sister to the Alloteropsis gene and the one of their combined sister group. 
The file 'tree_filtering_1.pl' contains a Perl script to filter out automatically no-LGT trees based on the table produced by the previous script.

#Identifify secondary candidates # 4 files

The file 'main_fragment.sh' articulates commands to generate coverage plots of the close relatives and potential donors up/downstream of LGT candidates. Dependencies: R, samtools, bedtools, LGT_figs_Part1.R LGT_figs_Part2.R and split_annotated_seq.pl.

#AU-test # 4 files

The file 'constrain_topology.pl' is used to produce constrained newick trees where Alloteropsis as well as the donor clade monophyly are enforced. 
The file 'topology_test.sh' implements all the steps to perform AU-test: site-wise likelihood are produced for constrained and unconstrained trees and compared with Consel. Dependencies: raxML, R, remove_edges.R, SMS and sms_CON_site.sh and Consel.




