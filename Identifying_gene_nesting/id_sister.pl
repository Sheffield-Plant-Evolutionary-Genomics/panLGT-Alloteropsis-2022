use strict;

my($tree,@tree_cut,$i,$nameprov,$blreading,$bvreading,@group,@sisters,@sisters2,$semialata,$bootstrap,$folder,@treefiles,$j,$boot1,$boot2,$k,$echino,$echino1,$echino2);
my(@paniceae,@cenchrinae,@bep,@chloridoideae,@other,@paspaleae,@melinidinae,@panicum,@andropogoneae);
my($paniceae_count,$cenchrinae_count,$bep_count,$chloridoideae_count,$other_count,$paspaleae_count,$melinidinae_count,$panicum_count,$andropogoneae_count);

@paniceae=("Acroceras_zizanioides","Cyrtococcum_patens","Dichanthelium_clandestinum","Dichanthelium_oligosanthes","Digitaria_ciliaris","Homopholis_proluta","Lasiacis_sorghoidea","Panicum_pygmaeum","Sacciolepis_striata");
@cenchrinae=("Cenchrus_americanus","Setaria_barbata","setaria_italica");
@bep=("brachypodium_distachyon","hordeum_vulgare","leersia_perrieri","oryza_sativa","Poeae_spp","triticum_aestivum");
@chloridoideae=("Dactyloctenium_aegyptium","Eragrostis_tef","Oropetium_thomaeum","Zoysia_japonica");
@other=("Chasmanthium_latifolium","Danthonia_californica","Stipagrostis_hirtigluma");
@paspaleae=("Hymenachne_amplexicaulis","Otachyrinae_spp","Paspalum_fimbriatum");
@melinidinae=("Megathirsus_maximus");
@panicum=("Panicum_hallii","Panicum_queenslandicum","Panicum_vigratum");
@andropogoneae=("sorghum_bicolor","zea_mays");

$folder=$ARGV[0];
if(not $folder){die "forgot to specify a folder\n";}

`ls $folder/*phyml_tree.txt >list_trees`;

#$tree="((((((((Paspalum_fimbriatum:0.05315901,(Hymenachne_amplexicaulis:0.02965566,Otachyrinae_spp:0.03373466)97:0.0153187)100:0.02523481,zea_mays:0.09813171)97:0.01298781,(Cyrtococcum_patens:0.0569121,((Panicum_queenslandicum:0.01682194,Panicum_hallii:0.01216195)100:0.03079131,(Dichanthelium_clandestinum:0.00288363,Dichanthelium_oligosanthes:0.00646181)96:0.02002557)72:0.00655885)81:0.01499054)68:0.0265112,(Panicum_pygmaeum:0.03030886,(Homopholis_proluta:0.03299191,(((setaria_italica:0.01575365,(Setaria_barbata:0.01669581,Cenchrus_americanus:0.03353789)71:0.00362161)85:0.02553629,(Sacciolepis_striata:0.0372731,Digitaria_ciliaris:0.05019398)96:0.01283437)24:0.00133218,((Acroceras_zizanioides:0.04907078,((Echinochloa_stagnina:0.00232862,Echinochloa_crusgalli:0.00183758)100:0.0441026,(Panicum_vigratum:0.04512719,ASEM_C4_00084:0.04656175)38:0.00238627)53:0.00337235)20:0.00112179,Lasiacis_sorghoidea:0.04887761)36:0.00230704)73:0.02921038)72:0.01343289)58:0.01381934)55:0.01660822,Chasmanthium_latifolium:0.09757951)91:0.02106562,(Stipagrostis_hirtigluma:0.10224271,(Dactyloctenium_aegyptium:0.09481914,Eragrostis_tef:0.06386771)98:0.045322)63:0.01284151)24:2.498e-05,Danthonia_californica:0.08332094)100:0.03636223,(((triticum_aestivum:0.02147066,hordeum_vulgare:0.04654187):0.08159273,Poeae_spp:0.13146301)100:0.02465448,leersia_perrieri:0.18729435)95:0.02439742)Root;";

open(FILE1,"<list_trees");
$i=0;
while(!eof(FILE1)){
	$treefiles[$i]=readline *FILE1;
	$treefiles[$i]=~ s/\n//g;
	$treefiles[$i]=~ s/\r//g;
	$i++;
	}
close(FILE1);

open(OUTFILE,">results_sister");
print OUTFILE "gene\tboot1\tboot2\tsister1\tsister1_group\techino1\tsister2\tsister2_group\techino2\n";
$j=0;
while($j<@treefiles){
open(FILE1,"<$treefiles[$j]");
$tree=readline *FILE1;
$tree=~ s/\n//g;
$tree=~ s/\r//g;

undef @group;
undef @sisters;
undef @sisters2;
undef $semialata;
@tree_cut=split(//,$tree);
$i=0;
$blreading=0;
$bvreading=0;
$boot1="NA";
$boot2="NA";
$echino1=0;
$echino2=0;

$bootstrap="";
while($i<@tree_cut){
if($tree_cut[$i] eq "("){$nameprov="";$bvreading=0;}
elsif($tree_cut[$i] eq ","){
	$bvreading=0;
	if($nameprov ne ""){
		if($nameprov=~ m/ASEM/){$semialata=$nameprov;}
		push @group,[$nameprov];
		$nameprov="";
		}
	$blreading=0;
	}
elsif($tree_cut[$i] eq ")"){
	$bvreading=1;
	if($boot1 eq "prov"){$boot1=$bootstrap;}
	if($boot2 eq "prov"){$boot2=$bootstrap;}
	if($nameprov ne ""){
		if($nameprov=~ m/ASEM/){$semialata=$nameprov;}
		push @group,[$nameprov];
		$nameprov="";
		}
	if($boot1 eq "NA" and @group>1){
		$k=0;
		$echino=0;
		while($k<@{$group[-1]}){
			if($group[-1][$k]=~ m/Echinochloa/){$echino++;}
			$k++;
			}
		if($semialata~~ @{$group[-2]} and $echino==@{$group[-1]}){$echino1=$echino1+$echino;}
		if($semialata~~ @{$group[-2]} and $echino<@{$group[-1]}){
			@sisters=@{$group[-1]};
			$echino1=$echino1+$echino;;
			$boot1="prov";
			}
		$k=0;
		$echino=0;
		while($k<@{$group[-2]}){
			if($group[-2][$k]=~ m/Echinochloa/){$echino++;}
			$k++;
			}
		if($semialata~~ @{$group[-1]} and $echino==@{$group[-2]}){$echino1=$echino1+$echino;}
		if($semialata~~ @{$group[-1]} and $echino<@{$group[-2]}){
			@sisters=@{$group[-2]};
			$echino1=$echino1+$echino;
			$boot1="prov";
			}
		}
	elsif($boot2 eq "NA"){
		$k=0;
		$echino=0;
		while($k<@{$group[-2]}){
			if($group[-2][$k]=~ m/Echinochloa/){$echino++;}
			$k++;
			}
		if($semialata~~@{$group[-1]} and $echino==@{$group[-2]}){$echino2=$echino2+$echino;}
		if($semialata~~@{$group[-1]} and $echino<@{$group[-2]}){
			@sisters2=@{$group[-2]};
			$echino2=$echino2+$echino;
			$boot2="prov";
			}
		$k=0;
		$echino=0;
		while($k<@{$group[-1]}){
			if($group[-1][$k]=~ m/Echinochloa/){$echino++;}
			$k++;
			}
		if($semialata~~@{$group[-2]} and $echino==@{$group[-1]}){$echino2=$echino2+$echino;}
		if($semialata~~@{$group[-2]} and $echino<@{$group[-1]}){
			@sisters2=@{$group[-1]};
			$echino2=$echino2+$echino;
			$boot2="prov";
			}
		}
	if(@group>1){
		push @{$group[-2]},@{$group[-1]};
		splice (@group,-1);
		}
	$bootstrap="";
	}
elsif($tree_cut[$i] eq ":"){
	$blreading=1;
	$bvreading=0;
	}
elsif($tree_cut[$i] eq ";"){
	$bvreading=0;
	}
elsif($bvreading==1){
	$bootstrap=$bootstrap.$tree_cut[$i];
	}
elsif($blreading==0 and $bvreading==0){$nameprov=$nameprov.$tree_cut[$i];}
$i++;
}

print OUTFILE $semialata."\t";
if($boot1 ne "" and $boot1 ne "prov"){print OUTFILE $boot1."\t";}
else{print OUTFILE "NA\t";}
if($boot2 ne "" and $boot2 ne "prov"){print OUTFILE $boot2."\t";}
else{print OUTFILE "NA\t";}

$i=1;
print OUTFILE $sisters[0];
if($sisters[0]~~@paniceae){$paniceae_count=1;}else{$paniceae_count=0;}
if($sisters[0]~~@cenchrinae){$cenchrinae_count=1;}else{$cenchrinae_count=0;}
if($sisters[0]~~@bep){$bep_count=1;}else{$bep_count=0;}
if($sisters[0]~~@chloridoideae){$chloridoideae_count=1;}else{$chloridoideae_count=0;}
if($sisters[0]~~@other){$other_count=1;}else{$other_count=0;}
if($sisters[0]~~@paspaleae){$paspaleae_count=1;}else{$paspaleae_count=0;}
if($sisters[0]~~@melinidinae){$melinidinae_count=1;}else{$melinidinae_count=0;}
if($sisters[0]~~@panicum){$panicum_count=1;}else{$panicum_count=0;}
if($sisters[0]~~@andropogoneae){$andropogoneae_count=1;}else{$andropogoneae_count=0;}
if($sisters[0]=~ m/Echinochloa/){$echino=1;}else{$echino=0;}
while($i<@sisters){
	if($sisters[$i]~~@paniceae){$paniceae_count++;}
	if($sisters[$i]~~@cenchrinae){$cenchrinae_count++;}
	if($sisters[$i]~~@bep){$bep_count++;}
	if($sisters[$i]~~@chloridoideae){$chloridoideae_count++;}
	if($sisters[$i]~~@other){$other_count++;}
	if($sisters[$i]~~@paspaleae){$paspaleae_count++;}
	if($sisters[$i]~~@melinidinae){$melinidinae_count++;}
	if($sisters[$i]~~@panicum){$panicum_count++;}
	if($sisters[$i]~~@andropogoneae){$andropogoneae_count++;}
	if($sisters[$i]=~ m/Echinochloa/){$echino++;}
	print OUTFILE ",".$sisters[$i];
	$i++;
	}
if($sisters[0] eq ""){print OUTFILE "\tNA";}
elsif($paniceae_count==@sisters or $echino+$paniceae_count==@sisters){print OUTFILE "\tpaniceae";}
elsif($cenchrinae_count==@sisters or $echino+$cenchrinae_count==@sisters){print OUTFILE "\tcenchrinae";}
elsif($bep_count==@sisters or $bep_count+$echino==@sisters){print OUTFILE "\tbep";}
elsif($chloridoideae_count==@sisters or $chloridoideae_count+$echino==@sisters){print OUTFILE "\tchloridoideae";}
elsif($other_count==@sisters or $other_count+$echino==@sisters){print OUTFILE "\tother";}
elsif($paspaleae_count==@sisters or $paspaleae_count+$echino==@sisters){print OUTFILE "\tpaspaleae";}
elsif($melinidinae_count==@sisters or $melinidinae_count+$echino==@sisters){print OUTFILE "\tmelinidinae";}
elsif($panicum_count==@sisters or $panicum_count+$echino==@sisters){print OUTFILE "\tpanicum";}
elsif($andropogoneae_count==@sisters or $andropogoneae_count+$echino==@sisters){print OUTFILE "\tandropogoneae";}
elsif($cenchrinae_count+$melinidinae_count+$panicum_count==@sisters or $cenchrinae_count+$melinidinae_count+$panicum_count+$echino==@sisters){print OUTFILE "\tmcp";}
elsif($andropogoneae_count+$paspaleae_count==@sisters or $andropogoneae_count+$paspaleae_count+$echino==@sisters){print OUTFILE "\tandropasp";}
else{print OUTFILE "\tmixed";}

print OUTFILE "\t".$echino1;
$i=1;
print OUTFILE "\t";
print OUTFILE $sisters2[0];
if($sisters2[0]~~@paniceae){$paniceae_count=1;}else{$paniceae_count=0;}
if($sisters2[0]~~@cenchrinae){$cenchrinae_count=1;}else{$cenchrinae_count=0;}
if($sisters2[0]~~@bep){$bep_count=1;}else{$bep_count=0;}
if($sisters2[0]~~@chloridoideae){$chloridoideae_count=1;}else{$chloridoideae_count=0;}
if($sisters2[0]~~@other){$other_count=1;}else{$other_count=0;}
if($sisters2[0]~~@paspaleae){$paspaleae_count=1;}else{$paspaleae_count=0;}
if($sisters2[0]~~@melinidinae){$melinidinae_count=1;}else{$melinidinae_count=0;}
if($sisters2[0]~~@panicum){$panicum_count=1;}else{$panicum_count=0;}
if($sisters2[0]~~@andropogoneae){$andropogoneae_count=1;}else{$andropogoneae_count=0;}
if($sisters2[0]=~ m/Echinochloa/){$echino=1;}else{$echino=0;}
while($i<@sisters2){
	if($sisters2[$i]~~@paniceae){$paniceae_count++;}
	if($sisters2[$i]~~@cenchrinae){$cenchrinae_count++;}
	if($sisters2[$i]~~@bep){$bep_count++;}
	if($sisters2[$i]~~@chloridoideae){$chloridoideae_count++;}
	if($sisters2[$i]~~@other){$other_count++;}
	if($sisters2[$i]~~@paspaleae){$paspaleae_count++;}
	if($sisters2[$i]~~@melinidinae){$melinidinae_count++;}
	if($sisters2[$i]~~@panicum){$panicum_count++;}
	if($sisters2[$i]~~@andropogoneae){$andropogoneae_count++;}
	if($sisters2[$i]=~ m/Echinochloa/){$echino++;}
	print OUTFILE ",".$sisters2[$i];
	$i++;
	}
if($sisters2[0] eq ""){print OUTFILE "\tNA";}
elsif($paniceae_count==@sisters2 or $echino+$paniceae_count==@sisters2){print OUTFILE "\tpaniceae";}
elsif($cenchrinae_count==@sisters2 or $echino+$cenchrinae_count==@sisters2){print OUTFILE "\tcenchrinae";}
elsif($bep_count==@sisters2 or $bep_count+$echino==@sisters2){print OUTFILE "\tbep";}
elsif($chloridoideae_count==@sisters2 or $chloridoideae_count+$echino==@sisters2){print OUTFILE "\tchloridoideae";}
elsif($other_count==@sisters2 or $other_count+$echino==@sisters2){print OUTFILE "\tother";}
elsif($paspaleae_count==@sisters2 or $paspaleae_count+$echino==@sisters2){print OUTFILE "\tpaspaleae";}
elsif($melinidinae_count==@sisters2 or $melinidinae_count+$echino==@sisters2){print OUTFILE "\tmelinidinae";}
elsif($panicum_count==@sisters2 or $panicum_count+$echino==@sisters2){print OUTFILE "\tpanicum";}
elsif($andropogoneae_count==@sisters2 or $andropogoneae_count+$echino==@sisters2){print OUTFILE "\tandropogoneae";}
elsif($cenchrinae_count+$melinidinae_count+$panicum_count==@sisters2 or $cenchrinae_count+$melinidinae_count+$panicum_count+$echino==@sisters2){print OUTFILE "\tmcp";}
elsif($andropogoneae_count+$paspaleae_count==@sisters2 or $andropogoneae_count+$paspaleae_count+$echino==@sisters2){print OUTFILE "\tandropasp";}
else{print OUTFILE "\tmixed";}
print OUTFILE "\t".$echino2."\n";
$j++;
}
