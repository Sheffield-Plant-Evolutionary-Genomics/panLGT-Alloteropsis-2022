#!/bin/bash
#$ -l h_rt=167:00:00
#$ -l mem=4G
#$ -l rmem=4G
#$ -o out.log

#Setting array

FILE= #cds fasta file

##PREP one file per gene
mkdir ${FILE}
cd ${FILE}
mkdir query
cd query
ls ${FILE}* | head -n 1 | while read line ; do perl unwrap.pl "$line" UNWRAPPED.fa  ; done
cat UNWRAPPED.fa | cut -f 1 | cut -f 1 -d ' ' > UNWRAPPED2.fa

grep ">" UNWRAPPED2.fa | cut -f 1 | cut -f 1 -d ' ' | sed 's/>//g' > NAMES.txt
cat NAMES.txt | while read line ; do grep "$line" -A1 UNWRAPPED2.fa > "$line" ; done
rm UNWRAPPED2.fa UNWRAPPED.fa

##PREP blastDB's
#for file in *.cds ; do makeblastdb -dbtype nucl -in ${file}; done
cat ../../BLASTDB_36 | grep -v "$FILE" > ../BlastDB
ls * > ../"$FILE"_genes

## Step 1 -Takes a list of genes ("$FILE"_genes) and a list of blast databases (BlastDB) and blasting all the genes in all of the blast data bases. First an intermediate file is made ($i) with sequence id, the length of alignment, and aligned part of the subject sequence. The top match is then then taken (head n- 1) but any other matches with the same name (do grep "$line3) are also recovered and will be combined at a later point.

mkdir ../BLAST_RESULTS
cat ../BlastDB | while read line ; do mkdir ../BLAST_RESULTS/"$line" ; done
cat ../"$FILE"_genes | while read line ; do cat ../BlastDB | while read line2 ; do blastn -query "$line" -db /mnt/fastdata-sharc/bo4pra/DONORS36/"$line2" -outfmt '6 sseqid length sseq' > ../"$line".txt ; cat ../"$line".txt | cut -f 1 | head -n 1 | while read line3 ; do grep "$line3" ../"$line".txt  >> ../BLAST_RESULTS/"$line2"/"$line"_"$line2" ; done ; done ; rm ../"$line".txt ; done


## Step 2 - next step now cycles through the blasted genes, the first awk prints the sum gene length (if you have two fragments it adds together) which become "$line3", the next sed is replacing the end of the line with a tab and line3 (sum gene length). The next awk is checking column 3 for sums greater than or equal to 300, this is the first filtering step. Next step is taking only the first 2 columns (Gene name and seq). sed 's/^/>/g' replaces the start of the line with > (we are now turning the file into a fasta file),  sed 's/\s/\n/g' is replacing "whitesapces" with a new line, this seperates the gene name and sequences. cut -f 1,2 -d '_' | sed 's/.CDS//g' is cutting the species names down so it will just be "Setaria_italica for example. sed 's/-//g' is removing all - (this will be in the sequnce)  $ means ends of line, \t is tab, ^ start of line, \n is new line, sed 's//g' where g is globally.
mkdir ../Results_3
cat ../"$FILE"_genes | while read line ; do cat ../BlastDB | while read line2 ; do cat ../BLAST_RESULTS/"$line2"/"$line"_"$line2" |  awk ' {sum+=$2} END {print sum}' | while read line3 ; do  sed 's/$/\t'$line3'/g' ../BLAST_RESULTS/"$line2"/"$line"_"$line2" |  awk '$4 >=300' | cut -f 1,3 | sed 's/^/>/g' | sed 's/\s/\n/g' | cut -f 1,2 -d '_' | sed 's/.CDS//g' | sed 's/-//g' | sed 's/Echinochloa_crusgalli/Echinochloa_crus-galli/g' >> ../Results_3/"$line"    ; done ; done ; done

## Step 3 -Takes a list of the Alloteropsis genes, then takes the combined blasted fasta files for all  of the 35 other species (../Results_3/"$line") and aligns them to the original gene sequence "$line"
mkdir ../ALN1
unset MAFFT_BINARIES
cat ../"$FILE"_genes | while read line ; do mafft --addfragments ../Results_3/"$line" "$line" > ../ALN1/"$line" ; done

mkdir ../ALN_MAFFT_FRAGMENTS
cp ../ALN1/* ../ALN_MAFFT_FRAGMENTS


## Step 4a

cat ../"$FILE"_genes | while read line ; do awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < ../ALN1/"$line" > ../ALN1/"$line"_unwrap ; done
cat ../"$FILE"_genes | while read line ; do tail -n +2 ../ALN1/"$line"_unwrap > ../ALN1/"$line" ; rm ../ALN1/"$line"_unwrap ; done


##Step 5, cycles through the genes and grabs the species names from the files in ALN1, these are then sorted and the awk prints the number of times they are present in the file (this is so we can identify genes with multiple fragments that need combining. Species with only 1 fragment identified (| grep "\s1$" | cut -f 1 -d ' '  ), and only these species and sequences are added to the gene file in ALN2
mkdir ../ALN2
cat ../"$FILE"_genes | while read line ; do grep ">" ../ALN1/"$line" | cut -f 2 -d ">" | sort | awk '{count[$1]++} END {for (word in count) print word, count[word]}' | grep "\s1$" | cut -f 1 -d ' '  | while read line2 ; do grep "$line2" -A 1 ../ALN1/"$line" >> ../ALN2/"$line" ; done; done


## Step 6 - similar to step 5 but grabs species with more than one fragment, it does this in a diffrernt way than the other step though
mkdir ../ALN3
cat ../BlastDB | while read line ; do mkdir ../ALN3/"$line" ; done
cat ../"$FILE"_genes | while read line ; do cat ../BlastDB | while read line2 ; do var1=$(echo "$line2" | cut -f 1 -d '.' | cut -f 1,2 -d '_' ) ; grep ">$var1" ../ALN1/"$line"  | cut -f 2 -d ">" | sort | awk '{count[$1]++} END {for (word in count) print word, count[word]}' |  grep -v "\s1$" | cut -f 1 -d ' ' | while read line3 ; do grep "$line3" -A 1 ../ALN1/"$line" > ../ALN3/"$line2"/"$line"_"$line2" ; done; done ; done

## Step 7 - generates a consensus sequence from the fragments 
mkdir ../ALN4
cat ../BlastDB | while read line ; do mkdir ../ALN4/"$line" ; done
cat ../BlastDB | while read line ; do ls ../ALN3/"$line"/ | while read line2 ; do perl /mnt/fastdata-sharc/bo4pra/consensus.pl -in ../ALN3/"$line"/"$line2"  -out ../ALN4/"$line"/"$line2" -iupac ; done ; done

## Step 8 - the perl script in step 7 renames the species in the files to >../ALN3/"Species"/"Genename"_"Species"_consensus, this step renames them to just the species name once more
mkdir ../ALN5
cat ../"$FILE"_genes | while read line ; do cat ../BlastDB | while read line2 ; do cat ../ALN4/"$line2"/"$line"_"$line2" | sed '/>/c\>'$line2''  >> ../ALN5/"$line" ; done ; done
*** STEP ABOVE TO CHANGE NAMES ***

## Step 9 - Now the genes with multiple fragments have been merged into a consensus, they are added to a file with the genes that had one copy (ALN2) from step 5.
mkdir ../ALN_FINAL
cat ../"$FILE"_genes | while read line ; do cat ../ALN2/"$line" ../ALN5/"$line"* > ../ALN_FINAL/"$line" ; done

## Step 10### Convert to phylip format with FastatoPhylip.pl from Wenjie Deng
### Step 11 ### Build tree for each alignment with phyML-GTR or sms
# ls *phy > list_of_trees.txt
# i=$(expr $SGE_TASK_ID) 
# head -$i list_of_trees.txt | tail -1  | while read line ; do phyml -i "$line" -v e -b 100 --quiet -m GTR ; done
#do ./sms-1.8.1/sms.sh -i ./"$line" -d nt -c aic -o ./trees_"$line" -b 100 -t ; done
