use strict;

my($line,@listalignments,$i,$j,$n,$nl,@numbers,@names,@temp,$nbgenes);

`ls clean-phy >list`;
open(IN,"<list");
$i=0;
while(!eof(IN)){
    $line=readline *IN;
    chomp($line);
    push @listalignments,$line;
    $i++;
    }
$nbgenes=$i-1;
close(IN);
#print @listalignments."\n";
#print $listalignments[0]."\n";
open(IN,"<clean-phy/$listalignments[0]") or die "can't open file clean-phy/$listalignments[0]\n";

$i=0;
while(!eof(IN)){
    $line=readline *IN;
    chomp($line);
    @temp=split /\s+/,$line;
    $temp[0]=~ s/Alloteropsis_//g;
    $temp[0]=~ s/\.vertical//g;
    if($i>0){push @names,$temp[0];}
    $i++;
    }
close(IN);

open(OUTNUM,">gene_summary");
$j=0;
while($j<100){
undef @numbers;
while(@numbers<5){
    $n=int(rand($nbgenes));
    if($n~~ @numbers){}
    else{push @numbers,$n};
    }

print OUTNUM $j."\t";
`mkdir repeat.$j.run1`;
open (OUT,">repeat.$j.run1/repeat.sh");
print OUT "#!\/bin\/bash\n#\$ -l rmem=16G\n../../BEAST_with_JRE.v2.6.4.Linux/beast/bin/beast run.$j.xml\n";
close(OUT);
open(OUT,">repeat.$j.run1/run.$j.xml");
print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><beast beautitemplate='Standard' beautistatus='' namespace=\"beast.core:beast.evolution.alignment:beast.evolution.tree.coalescent:beast.core.util:beast.evolution.nuc:beast.evolution.operators:beast.evolution.sitemodel:beast.evolution.substitutionmodel:beast.evolution.likelihood\" required=\"\" version=\"2.6\">\n\n";
$i=0;
while($i<5){
    $n=$numbers[$i];
    print OUTNUM "\t".$listalignments[$n];
    print OUT "<data\nid=\"gene".($i+1)."\"\nspec=\"Alignment\"\nname=\"alignment\">\n";
    open(IN,"<clean-phy/$listalignments[$n]") or die "can't open file clean-phy/$listalignments[$n]\n";
    while(!eof(IN)){
        $line=readline *IN;
        chomp($line);
        if($line=~ m/Alloteropsis/){
            @temp=split /\s+/,$line;
  #          $temp[0]=~ s/Alloteropsis_//g;
            $temp[0]=~ s/\.vertical//g;
            print OUT "<sequence id=\"seq_".$temp[0]."_".$i."\" spec=\"Sequence\" taxon=\"".$temp[0]."\" totalcount=\"4\" value=\"$temp[1]\"\/>\n";
            }
        }
    print OUT "</data>\n\n";
    $i++;
    }
close(OUT);
print OUTNUM "\n";
`cat end.xml >>repeat.$j.run1/run.$j.xml`;
`cp -r repeat.$j.run1 repeat.$j.run2`;
$j++;
}
close(OUTNUM);
