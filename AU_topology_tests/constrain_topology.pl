use strict;
###REQUIREMENT: One file listing all headers for each donor group and for Alloteropsis##########
#### Output constrained newick tree such as ((A,A,A)(B,B,B),C,C,C);   where A = recipient clade; B = donor clade; C = others for each file in list_tree#########
my(@trees,@allo,@donors,@others,$f,@sourced,@source_allo,$donor);

my $usage = "Give donor group as argument\n";
$donor=shift or die($usage);
open (my $file, "<header_donors_$donor");#list all donors headers in this group (eg. Cenchrineae, Andropogoneae...)
while (my $line = <$file>){
	chomp $line;
	push @sourced,$line;
}

open (my $file, "<allo");#list all Alloteropsis sequences (native+LGT)
while (my $line = <$file>){
	chomp $line;
	push @source_allo,$line;
}

`ls *fasta > list_tree`;
open (my $file, "<list_tree");
while (my $line = <$file>){
	chomp $line;
	push @trees,$line;
}

$f=0;
while ($f<@trees){
open (OUT, '>', "$trees[$f].CONSTRAINTS");
open (IN, '<', "$trees[$f]");
undef @others;
undef @allo;
undef @donors;
	while(!eof(IN)){
		my $line=readline *IN;
		chomp $line;
		if($line=~ m/>/){
			my @prov= undef;
			@prov=split />/,$line;
			$line=$prov[1];
			print $prov[1];
			if($line ~~ @source_allo){
				push @allo,$line.",";}
			elsif($line ~~ @sourced){
				push @donors,$line.",";}
			else{
				push @others,$line.",";}
			#my $sp=substr $prov[0],1;
			#print $sp;
			#if($prov[0]=~ m/Allo/){
				#push @allo,$sp.",";
			#}
			#else{
			#push @others,$sp.",";
			#}
		}
	}
print OUT "((";
print OUT @allo;
print OUT "),(";
print OUT @donors;
print OUT "),";
print OUT @others;
print OUT ");";
close(OUT);
close(IN);
$f++;
}

