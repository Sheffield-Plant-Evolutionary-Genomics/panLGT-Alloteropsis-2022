#!/bin/bash
#SBATCH -p workq
#SBATCH -t 04:00:00
#SBATCH -a 1-3

$user=""
sms=/work/$user/sms-1.8.1
infiles=/work/$user/to_run
consel=/work/$user/consel/bin
RCOMS=/work/$user/remove_edges.R # use phytools in R to remove edge lengths
results=/work/$user/AU_RESULTS

### constraints and phy should have the same filenames
### constraints  format = ((A,A,A)(B,B,B),C,C,C);   where A = recipient clade; B = donor clade; C = others

module load bioinfo/standard-RAxML-8.2.11

phy=/work/$user/PHY
constraints=/work/$user/CONSTRAINTS


i=$(expr $SLURM_ARRAY_TASK_ID)

### step 1: calculate site-wise liklehood for LGT tree

head -$i ${infiles} | tail -1 | while read line ; do mkdir -p TREES/TREES_"$line"/LGT ; cd TREES/TREES_"$line"/LGT ; cp ${phy}/"$line".phy . ; done

cd /work/$user/

head -$i ${infiles} | tail -1 | while read line ; do cd TREES/TREES_"$line"/LGT ; ${sms}/sms_site.sh -i "$line".phy -d nt -t ; done

cd /work/$user/

# ### step 2: generate constraints file using raxml and then calculate site-wise liklehood for NO-LGT tree

head -$i ${infiles} | tail -1 | while read line ; do mkdir TREES/TREES_"$line"/NO_LGT ; cd TREES/TREES_"$line"/NO_LGT ; cp ${phy}/"$line".phy . ; cp ${constraints}/"$line".fasta CONSTRAINTS-1 ; done

cd /work/$user/

module load system/R-3.4.3

head -$i ${infiles} | tail -1 | while read line ; do cd TREES/TREES_"$line"/NO_LGT ; raxmlHPC -m GTRGAMMA -p 12345 -n CONSTRAINTS-2 -s "$line".phy -g CONSTRAINTS-1 ; R CMD BATCH ${RCOMS} ; done
cd /work/$user/
head -$i ${infiles} | tail -1 | while read line ; do cd TREES/TREES_"$line"/NO_LGT ; ${sms}/sms_CON_site.sh -i "$line".phy -d nt -t ; done

cd /work/$user/


### step 3: run AU-test

head -$i ${infiles} | tail -1 | while read line ; do cd TREES/TREES_"$line" ; cat LGT/*lk.txt NO_LGT/*lk.txt > lk.txt ; ${consel}/makermt --phyml lk.txt ; ${consel}/consel lk ; ${consel}/catpv lk > RESULTS_"$line" ; done


### step 3: combine results (output is tab delim file with: likelihood_LGT	likelihood_NO-LGT	AU_p_value)

mkdir -p ${results}
cd /work/$user/

head -$i ${infiles} | tail -1 | while read line ; do cd TREES/TREES_"$line" ; cat RESULTS_* | awk -v OFS="\t" '$1=$1' | cut -f 5 | tail -n 1 > A ; cat LGT/*stats* | grep "Log-likelihood" | cut -f 2 -d ':' | cut -f 4 > B ; cat NO_LGT/*stats* | grep "Log-likelihood" | cut -f 2 -d ':' | cut -f 4 > C ; paste B C A > ${results}/"$line" ; done
