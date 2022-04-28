use strict;

my (@results, $k);
my $sp=shift;

$k=0;
open (IN, "<results_sister_$sp");
open (OUT, ">results_sister_mix_$sp");
while (my $line = <IN>){
	chomp $line;
	@results=split /\t/,$line;
	if ($results[4]=~ m/mixed/ or $results[7]=~ m/mixed/){}
	else{
		print OUT $line."\n";
	}
	$k++;
}

use strict;

my (@results, $k);
my $sp=shift;

$k=0;
open (OUT, ">results_sister_pani_$sp");
open (IN, "<results_sister_mix_$sp");
while (my $line = <IN>){
	chomp $line;
	@results=split /\t/,$line;
	if($results[4]=~ m/paniceae/ and $results[7]=~ m/paniceae/){
		if($results[3]=~ m/Cyrtococcum_patens/ and $results[6]=~ m/Lasiacis_sorghoidea/){
			print OUT $line."\n";}
		if($results[6]=~ m/Cyrtococcum_patens/ and $results[3]=~ m/Lasiacis_sorghoidea/){
			print OUT $line."\n";}
		if($results[3]=~ m/Dichanthelium/ and $results[6]=~ m/Dichanthelium/){
			print OUT $line."\n";}
	}
	else{
		print OUT $line."\n";
	}
	$k++;
}
use strict;

my (@results, $k);
my $sp=shift;

$k=0;
open (OUT, ">results_sister_nest_$sp");
open (IN, "<results_sister_pani_$sp");
while (my $line = <IN>){
	chomp $line;
	@results=split /\t/,$line;
	#if ($results[1]>=50 or $results[2]>=50){
	if ($results[4]=~ m/$results[7]/){
		unless ($results[4]=~ m/mcp/ or $results[4]=~ m/NA/ or $results[4]=~ m/andropasp/ or $results[4]=~ m/other/){
		print OUT $line."\n";}
	}
	elsif($results[3]=~ m/Cyrtococcum_patens/ and $results[6]=~ m/Lasiacis_sorghoidea/){
	print OUT $line."\n";
	}
	elsif($results[3]=~ m/Lasiacis_sorghoidea/ and $results[6]=~ m/Cyrtococcum_patens/)
	{
	print OUT $line."\n";
	}
	elsif($results[3]=~ m/Dichanthelium/ and $results[6]=~ m/Dichanthelium/)
	{
	print OUT $line."\n";
	}
	elsif($results[4]=~ m/melinidinae/ and $results[7]=~ m/cenchrinae/)
	{
	print OUT $line."\n";		
	}
	$k++;
}
use strict;

my (@results, $k);
my $sp=shift;
$k=0;
open (OUT, ">results_sister_tri_$sp");
open (IN, "<results_sister_boot_$sp");
while (my $line = <IN>){
	chomp $line;
	@results=split /\t/,$line;
	if ($results[1]>=50 or $results[2]>=50){
		print OUT $line."\n";
	}
	$k++;
}


