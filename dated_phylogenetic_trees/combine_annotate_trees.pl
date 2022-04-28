use strict;

my($i,$line,@temp);

open(OUT,">consensus_trees.txt");
print OUT "#NEXUS\n\nBegin taxa;\n	Dimensions ntax=45;\n		Taxlabels\n			angusta_4003\n			angusta_4006\n			angusta_MRL48\n			angusta_TAN1601\n			angusta_ZAM1720-04\n			angusta_ZAM1930-17\n			angusta_ZAM1950-10\n			cimicina_4005\n			cimicina_A.cim\n			cimicina_MSV627\n			cimicina_RCH20\n			semialata_AUS1\n			semialata_AUS16-04-03\n			semialata_AUS16-16-03\n			semialata_AUS16-16-04\n			semialata_AUS16-33-02\n			semialata_AUS16-33-03\n			semialata_BF-2\n			semialata_BL\n			semialata_CRL4-6\n			semialata_China-Gin1\n			semialata_GMT9\n			semialata_JM\n			semialata_KWT3\n			semialata_L01A\n			semialata_L02O\n			semialata_L04A\n			semialata_L04B\n			semialata_MSV2365\n			semialata_Maj-3\n			semialata_PHIL16-01\n			semialata_SRL17-02-03\n			semialata_TAN16-02-04\n			semialata_TAN16-03-01\n			semialata_TAN16-03-08\n			semialata_TW10\n			semialata_ZAM15-03-03\n			semialata_ZAM15-05-10\n			semialata_ZAM15-07-19\n			semialata_ZAM17-01-1_7\n			semialata_ZAM17-05-03\n			semialata_ZAM17-23-05\n			semialata_ZAM19-46-10\n			semialata_ZAM19-46-19\n			semialata_ZIM15-04-61\n			;\nEnd;\nBegin trees;\n	Translate\n		   1 angusta_4003,\n		   2 angusta_4006,\n		   3 angusta_MRL48,\n		   4 angusta_TAN1601,\n		   5 angusta_ZAM1720-04,\n		   6 angusta_ZAM1930-17,\n		   7 angusta_ZAM1950-10,\n		   8 cimicina_4005,\n		   9 cimicina_A.cim,\n		  10 cimicina_MSV627,\n		  11 cimicina_RCH20,\n		  12 semialata_AUS1,\n		  13 semialata_AUS16-04-03,\n		  14 semialata_AUS16-16-03,\n		  15 semialata_AUS16-16-04,\n		  16 semialata_AUS16-33-02,\n		  17 semialata_AUS16-33-03,\n		  18 semialata_BF-2,\n		  19 semialata_BL,\n		  20 semialata_CRL4-6,\n		  21 semialata_China-Gin1,\n		  22 semialata_GMT9,\n		  23 semialata_JM,\n		  24 semialata_KWT3,\n		  25 semialata_L01A,\n		  26 semialata_L02O,\n		  27 semialata_L04A,\n		  28 semialata_L04B,\n		  29 semialata_MSV2365,\n		  30 semialata_Maj-3,\n		  31 semialata_PHIL16-01,\n		  32 semialata_SRL17-02-03,\n		  33 semialata_TAN16-02-04,\n		  34 semialata_TAN16-03-01,\n		  35 semialata_TAN16-03-08,\n		  36 semialata_TW10,\n		  37 semialata_ZAM15-03-03,\n		  38 semialata_ZAM15-05-10,\n		  39 semialata_ZAM15-07-19,\n		  40 semialata_ZAM17-01-1_7,\n		  41 semialata_ZAM17-05-03,\n		  42 semialata_ZAM17-23-05,\n		  43 semialata_ZAM19-46-10,\n		  44 semialata_ZAM19-46-19,\n		  45 semialata_ZIM15-04-61\n;\n";

$i=0;
while($i<100){
#`~/prog/BEAST_with_JRE.v2.6.4.Linux/beast/bin/logcombiner -burnin 25 -log repeat.$i.run*/species.trees -o summary_trees/repeat.$i.trees`;
`~/prog/BEAST_with_JRE.v2.6.4.Linux/beast/bin/treeannotator -heights median -burnin 0 -limit 0 summary_trees/repeat.$i.trees summary_trees/repeat.$i.tre`;
open(IN,"<summary_trees/repeat.$i.tre");
while(!eof(IN)){
    $line=readline *IN;
    chomp($line);
    if($line=~ m/TREE/){
        @temp=split / = /,$line;
        print OUT "tree TREE".$i." = ".$temp[1]."\n";
        }
    }
close(IN);
$i++;
}
print OUT "END;\n";
close(OUT);

















#~/prog/BEAST_with_JRE.v2.6.4.Linux/beast/bin/logcombiner -burnin 25 -resample 10000000 -log repeat.*.run*/species.trees -o repeat.all.trees

#~/prog/BEAST_with_JRE.v2.6.4.Linux/beast/bin/treeannotator -heights median -burnin 0 -limit 0 repeat.all.trees repeat.all.tre

