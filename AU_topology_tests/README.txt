#AU-test 

These scripts are used to proform AU topology tests to comapre gene trees where LGT is detected with a constrained tree with no LGT

## Step 1: Generating a constrained topology

The constraints file should have the following format
((A,A,A)(B,B,B),C,C,C);   where A = recipient clade; B = donor clade; C = others

In this study we used the perl script 'constrain_topology.pl' to produce a constrained newick trees where Alloteropsis as well as the donor clade monophyly is enforced. 

## Step 2: Preform toplogy tests based on site-wise likelihood 

The file 'topology_test.sh' implements all the steps to perform AU-test: site-wise likelihood are produced for constrained and unconstrained trees and compared with Consel. Dependencies: raxML, R, remove_edges.R, SMS_site.sh and sms_CON_site.sh and Consel.

The modified SMS (Lefort et al., 2017) scripts (SMS_site.sh and sms_CON_site.sh) are modified to output site-wise liklihoods, and the sms_CON_site.sh is also able to contstrain the trees.   

Lefort, V., Longueville, J. E., & Gascuel, O. (2017). SMS: smart model selection in PhyML. Molecular biology and evolution, 34(9), 2422-2424.




