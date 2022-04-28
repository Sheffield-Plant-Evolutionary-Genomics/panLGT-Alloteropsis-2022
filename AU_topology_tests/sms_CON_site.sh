#!/bin/bash
#
# This is the master script of SMS.
# It requires functions defined in the other SMS scripts.
#
# Author : Vincent Lefort & Jean-Emmanuel Longueville
#          <lefort(at)lirmm.fr>
# Copyright (C) 2016 Vincent Lefort, Jean-Emmanuel Longueville, CNRS
# All parts of the source except where indicated are distributed under the GNU public licence.
# See http://www.opensource.org for details.
#
#Parameters :
# -i : $inAln      - input alignment in PHYLIP format
# -d : $dType      - data type 'aa' or 'nt'
# -o : $outDir     - path to output directory
# -p : $outCSV     - output CSV filename
# -c : $criterion  - 'AIC' or 'BIC'
# -u : $inTree     - input tree in Newick format
# -t : $inferTree  - add this option to infer a PhyML tree with selected model
# -s : $treeSearch - 'NNI' or 'SPR'
# -r : $randTrees  - number of random starting trees
# -b - $support    - branch support (aLRT or bootstrap replicates)
# -h : Prints help
#


help() {
	echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	echo "This script runs SMS to select the substitution model which best fits the input data."
	echo "It may also run PhyML with the selected model."
	echo "SMS options :"
	echo -e "\t -h = Help"
	echo -e "\t -i = **Mandatory** Input alignment file in PHYLIP format"
	echo -e "\t -d = **Mandatory** Data type : 'aa' or 'nt'"
	echo -e "\t -o = Output directory"
	echo -e "\t -p = Output CSV filename"
	echo -e "\t -c = Statistical criterion to select the model : 'AIC' (default) or 'BIC'"
	echo -e "\t -u = Input starting tree (Newick format)"
	echo -e "\t -t = Use this option if you want SMS to infer a tree with PhyML using the SMS selected model"
	echo " PhyML options :"
	echo -e "\t -s = Type of tree improvement : 'NNI (default)' or 'SPR'"
	echo -e "\t -r = Number of random starting trees : 0 (default)"
	echo -e "\t -b = Branch Support : >0 for bootstraps, -4 for aLRT, 0 (default)"
}

exitok() {
	# Test the return status of a function and exit in case of error
	# @param $1 : return status
	# @param $2 : message to print
	
	if [ "$1" -ne 0 ] ; then
		echo "Error : $2" >&2
		exit 1
	fi
}

isinteger() {
	# Test the argument is a valid integer number
	# @param $1 : the variable to check
	
	if [ "$1" -eq "$1" ] 2>/dev/null
	then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

prepareFile() {
	# Check a file already exists, remove it if any
	# Create the file and set the right permissions
	# @param $1 : file path

	if [ -f "$1" ] ; then
		rm "$1"
		exitok $? "Cannot delete file : '$1'"
	fi
	touch "$1"
	exitok $? "Cannot create file : '$1'"
	chmod ug+w "$1"
}

criterionName() {
	# Convert $criterion (upper case) into criterion name
	# including lower case characters if any
	# @param $1 : criterion
	
	if [ "$1" == "AICC" ] ; then
		echo "AICc"
	else
		echo "$1"
	fi
}

decorationName() {
	# Remove '+F' from the decoration name only for DNA
	# @param $1 : data type
	# @param $2 : decoration
	
	if [ "$1" == "nt" ] ; then
		echo "${2%+F}"
	else
		echo "$2"
	fi
}

####################################################################################################
##########################               Default values                    #########################
####################################################################################################
# Path to SMS directory
binDir=`dirname $0`/

# Statistical criterion used to compare the models
criterion="AIC"

# Run SMS only (do not infer a tree with the selected model)
inferTree="FALSE"


####################################################################################################
##########################               Get parameters                   ##########################
####################################################################################################
while getopts ti:d:o::p::c::u::s:r:b:h option
do
	case "$option" in
		#SMS options
		h)
			help
			exit 0
		 ;;
		i) inAln="$OPTARG"
			;;
		d) dType="$OPTARG"
			;;
		o) outDir="$OPTARG"
			;;
		p) outCSV="$OPTARG"
			;;
		c) criterion=`echo "$OPTARG" | tr '[:lower:]' '[:upper:]'`
			;;
		u) inTree="$OPTARG"
			;;
		t) inferTree="TRUE"
			;;
		#PhyML options
		s) treeSearch=`echo "$OPTARG" | tr '[:lower:]' '[:upper:]' `
			;;
		r) randTrees="$OPTARG"
			;;
		b) support="$OPTARG"
			;;
		\:)
			echo "Type ./sms.sh -h to print the help">&2
			exit 1
			;;
		\?)
			echo "Unknown option">&2
			exit 1
			;;
	esac
done


####################################################################################################
#########################              Check parameters                   ##########################
####################################################################################################
if [ -z "$inAln" ] ; then
	echo "You must provide an input file (-i option)" >&2
	exit 1
fi
if [ ! -f "$inAln" ] ; then
	echo "Invalid input file : '$inAln' (-i option)" >&2
	exit 1
fi
if [ "$dType" != "aa" ] && [ "$dType" != "nt" ] ; then
	echo "Invalid data type : '$dType' (-d option)" >&2
	exit 1
fi
if [ "$criterion" != "AIC" ] && [ "$criterion" != "BIC" ] ; then
	echo "Invalid criterion : '$criterion' (-c option)" >&2
	exit 1
fi
if [ -n "$inTree" ] && [ ! -f "$inTree" ] ; then
	echo "Invalid input file : '$inTree' (-u option)" >&2
	exit 1
fi


####################################################################################################
########################              Check dependencies                   #########################
####################################################################################################
which bc >/dev/null 2>&1
exitok $? "The arbitrary precision calculator 'bc' is not installed"

if [ "$dType" == "aa" ] ; then
	echo "q()" | R --vanilla >/dev/null 2>&1
	exitok $? "The R package 'r-base' is not installed"
	which Rscript >/dev/null 2>&1
	exitok $? "The R package 'r-base' is not installed"
fi


####################################################################################################
#######################              Check  PhyML options                   ########################
####################################################################################################
if [ "$inferTree" == "TRUE" ] ; then
	# Check type of tree improvement
	if [ -n "$treeSearch" ] && [ "$treeSearch" != "NNI" ] && [ "$treeSearch" != "SPR" ]; then
		echo "Invalid value for type of tree improvement : '$treeSearch' (-s option)" >&2
	fi
	# Check number of random starting trees
	if [ -n "$randTrees" ] ; then
		if [ "$treeSearch" != "SPR" ] ; then
			echo "The random starting trees (-r option) is only valid with SPR tree searching (-s option)" >&2
			exit 1
		elif [ $(isinteger "$randTrees") == "FALSE" ] || [ $(echo "$randTrees < 1" | bc -l) -eq 1 ] || [ $(echo "$randTrees > 10" | bc -l) -eq 1 ] ; then
			echo "Invalid number of random starting trees : '$randTrees' (-r option)" >&2
			exit 1
		fi
	fi
	# Check branch support
	if [ -n "$support" ] ; then
		if [ $(isinteger "$support") == "FALSE" ] || [ $(echo "$support < -5" | bc -l) -eq 1 ] ; then
			echo "Invalid value for branch support : '$support' (-b option)" >&2
			exit 1
		fi
	fi
fi


####################################################################################################
#####################              Prepare files & directories                  ####################
####################################################################################################

# Output directory default value is the input file directory
if [ -z "$outDir" ] ; then
	outDir=`dirname "$inAln"`
fi

# Add a teminating "/"
if [ "${outDir: -1}" != "/" ] ; then
	outDir="$outDir"/
fi

# Output CSV filename default value
if [ -z "$outCSV" ] ; then
	outCSV="$outDir""sms.csv"
fi

# Create output directory if needed
if [ ! -d "$outDir" ]; then
	mkdir "$outDir"
	exitok $? "Cannot create output directory : '$outDir'"
	chmod ug+w "$outDir"
fi

# SMS directory to store files used during model selection
smsDir="$outDir"sms/
if [ ! -d "$smsDir" ] ; then
	mkdir "$smsDir"
	exitok $? "Cannot create sms directory : '$smsDir'"
	chmod ug+w "$smsDir"
else
	rm "$smsDir"* >/dev/null 2>&1
fi

# Get number of taxa and sites
nTaxa=`head -n 1 "$inAln" | awk '{print $1}'`
nSite=`head -n 1 "$inAln" | awk '{print $2}'`

# Check nTaxa & nSite are integers
if [ $(isinteger "$nTaxa") == "FALSE" ] ; then
	echo "Invalid number of taxa. Check input file format." >&2
	exit 1
fi
if [ $(isinteger "$nSite") == "FALSE" ] ; then
	echo "Invalid number of sites. Check input file format." >&2
	exit 1
fi

# Compute number of branches : 2 * nTaxa - 3
nBran=`echo "(2 * $nTaxa) - 3" | bc -l`


####################################################################################################
##############################               SMS START               ###############################
####################################################################################################
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "                     Starting SMS v1.8.1"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Input alignment    : `basename $inAln`"
echo "Data type          : $(if [ "$dType" == "nt" ] ; then echo "DNA" ; else echo "Protein" ; fi )"
echo "Number of taxa     : $nTaxa"
echo "Number of sites    : $nSite"
echo "Number of branches : $nBran"
echo "Criterion          : `criterionName $criterion`"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# Include SMS configuration file
source "$binDir"sms.cfg

# Include functions to compute AIC and BIC
source "$binDir"criterion.sh

# Include functions for each step of the SMS strategy
source "$binDir"strategy.sh

# Copy input alignment
cp "$inAln" "$ALNFILEPATH"
exitok $? "Cannot copy input file '$inAln' to '$ALNFILEPATH'"

# Prepare SMS log file
prepareFile "$LOGFILEPATH"

# Prepare SMS file which stores all results
prepareFile "$RESULTSFILEPATH"

# Prepare SMS fixed topology file
prepareFile "$TOPOLOGYFILEPATH"

# Prepare SMS protein model frequencies file
if [ "$dType" == "aa" ] ; then
	source "$binDir"distance.sh
	prepareFile "$MODELSFQFILEPATH"
fi


####################################################################################################
################################               Step 1               ################################
####################################################################################################
echo "Step 1 : Set a fixed topology"
if [ "$dType" == "nt" ] ; then
	model="$TOPOLOGYMODELNT"
	deco="$TOPOLOGYDECONT"
else
	model="$TOPOLOGYMODELAA"
	deco="$TOPOLOGYDECOAA"
fi
# function : setTopology [data type] [model] [decoration] [criterion] [#branches] [#sites] [input tree]
curCritVal=`setTopology "$dType" "$model" "$deco" "$criterion" "$nBran" "$nSite" "$inTree"`
if [ "$?" -ne 0 ] ; then
	exit 1
fi
# Check fixed topology file is empty
if [ ! -s "$TOPOLOGYFILEPATH" ] ; then
	exit 1
fi

if [ -n "$curCritVal" ] ; then
	echo -e "\t`criterionName $criterion`=$curCritVal"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
fi


####################################################################################################
################################               Step 2               ################################
####################################################################################################
echo "Step 2 : Select the best decoration"
# function : bestDecoration [data type] [model] [criterion] [#branches] [#sites]
bestDeco=`bestDecoration "$dType" "$model" "$criterion" "$nBran" "$nSite"`
# function : parseResult [model] [decoration] [requested value]
curCritVal=`parseResult "$model" "$bestDeco" "$criterion"`

# If selected decoration has '+I' then get the proportion of invariant sites
if [[ "$bestDeco" =~ "+I" ]] ; then
	fileStat="$ALNFILEPATH""_phyml_stats_""$model$bestDeco""-lr.txt"
	# function : parsePhyMLoutput [file stat] [value]
	curInvar=`parsePhyMLoutput "$fileStat" "invar"`
fi

echo -e "\t`criterionName $criterion`=$curCritVal\tdecoration : '`decorationName $dType $bestDeco`'"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


####################################################################################################
################################               Step 3               ################################
####################################################################################################
echo "Step 3 : Select the best matrix"
# function : bestMatrix [decoration] [data type] [criterion] [#branches] [#taxa] [#sites] [invar]
bestModelDeco=`bestMatrix "$bestDeco" "$dType" "$criterion" "$nBran" "$nTaxa" "$nSite" "$curInvar"`

# 'bestMatrix' function returns the best model and the associated decoration (the best decoration found in step 2 with -F/+F for proteins)
# The string has to be parsed to extract the model and the decoration
bestModel=`echo "$bestModelDeco" | awk '{print $1}'`
bestDeco=`echo "$bestModelDeco" | awk '{print $2}'`
# function : parseResult [model] [decoration] [requested value] [alpha] [p-invar]
curCritVal=`parseResult "$bestModel" "$bestDeco" "$criterion" "" "$curInvar"`

echo -e "\t`criterionName $criterion`=$curCritVal\tmatrix : '$bestModel'"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


####################################################################################################
################################               Step 4               ################################
####################################################################################################
echo "Step 4 : Select the best final decoration"
# function : bestFinal [data type] [model] [criterion] [#branches] [#sites]
bestDeco=`bestFinal "$dType" "$bestModel" "$criterion" "$nBran" "$nSite"`
# function : parseResult [model] [decoration] [requested value]
curCritVal=`parseResult "$bestModel" "$bestDeco" "$criterion"`

echo -e "\t`criterionName $criterion`=$curCritVal\tdecoration : '`decorationName $dType $bestDeco`'"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


####################################################################################################
###############################               SMS END               ################################
####################################################################################################

# Sort tested models according to criterion and create output CSV file
echo "Model;Decoration;K;Llk;AIC;BIC" >"$outCSV"
# Remove '+F' from the decoration name only for DNA
if [ "$dType" == "nt" ] ; then
	# Do not keep results obtained at Step 3 with bestModel
	if [ "$criterion" == "AIC" ] ; then
		cat "$RESULTSFILEPATH" | tr '.' ',' | sort -g -k 7 | sed "s/+F//" | tr "\t" ";" | tr -d "_" | sed "/f;$bestModel/d" | sed "s/^[ef];[ef];//" >>"$outCSV"
	elif [ "$criterion" == "BIC" ] ; then
		cat "$RESULTSFILEPATH" | tr '.' ',' | sort -g -k 8 | sed "s/+F//" | tr "\t" ";" | tr -d "_" | sed "/f;$bestModel/d" | sed "s/^[ef];[ef];//" >>"$outCSV"
	fi
else
	# Do not keep results obtained at Step 3 with bestModel
	if [ "$criterion" == "AIC" ] ; then
		cat "$RESULTSFILEPATH" | tr '.' ',' | sort -g -k 7 | tr "\t" ";" | tr -d "_" | sed "/f;$bestModel/d" | sed "s/^[ef];[ef];//" >>"$outCSV"
	elif [ "$criterion" == "BIC" ] ; then
		cat "$RESULTSFILEPATH" | tr '.' ',' | sort -g -k 8 | tr "\t" ";" | tr -d "_" | sed "/f;$bestModel/d" | sed "s/^[ef];[ef];//" >>"$outCSV"
	fi
fi

# File to parse to get PhyML parameters values
fileStat="$ALNFILEPATH""_phyml_stats_""$bestModel$bestDeco""-lr.txt"

# User friendly output detailing how to configure PhyML options for the selected model
echo -e "Selected model\t\t\t\t: $bestModel `decorationName $dType $bestDeco`"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo -e "Substitution model\t\t\t: $bestModel"
# Equilibrium frequencies
if [ "$dType" == "nt" ] ; then
	echo -e "Equilibrium frequencies\t\t\t: ML optimized"
else
	if [[ "$bestDeco" =~ "+F" ]] ; then
		echo -e "Equilibrium frequencies\t\t\t: Empirical"
	else
		echo -e "Equilibrium frequencies\t\t\t: Model"
	fi
fi
# Ts/Tv ratio
if [ "$bestModel" == "HKY85" ] ; then
	echo -e "Transition / transversion ratio\t\t: estimated"
fi
# Invariant sites
if [[ "$bestDeco" =~ "+I" ]] ; then
	# function : parsePhyMLoutput [file stat] [value]
	invar=`parsePhyMLoutput "$fileStat" "invar"`
	echo -e "Proportion of invariable sites\t\t: estimated ($invar)"
else
	echo -e "Proportion of invariable sites\t\t: fixed (0.0)"
fi
# Gamma law
if [[ "$bestDeco" =~ "+G" ]] ; then
	# function : parsePhyMLoutput [file stat] [value]
	alpha=`parsePhyMLoutput "$fileStat" "alpha"`
	echo -e "Number of substitution rate categories\t: $NBGAMMACAT"
	echo -e "Gamma shape parameter\t\t\t: estimated ($alpha)"
else
	echo -e "Number of substitution rate categories\t: 1"
fi
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


####################################################################################################
##############################               Citations               ###############################
####################################################################################################
echo
echo "Suggested citations:"
echo "SMS"
echo " Vincent Lefort, Jean-Emmanuel Longueville, Olivier Gascuel."
echo " \"SMS: Smart Model Selection in PhyML.\""
echo " Molecular Biology and Evolution, msx149, 2017."
echo "PhyML"
echo " S. Guindon, JF. Dufayard, V. Lefort, M. Anisimova, W. Hordijk, O. Gascuel"
echo " \"New algorithms and methods to estimate maximum-likelihood phylogenies: assessing the performance of PhyML 3.0.\""
echo " Systematic Biology. 2010. 59(3):307-321."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


####################################################################################################
################               Optional additional step : infer tree               #################
####################################################################################################
if [ "$inferTree" == "TRUE" ] ; then
    echo
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Additional step : Infer tree with model : '$bestModel $bestDeco'"
	# Get nucleotides frequencies
	if [ "$dType" == "nt" ] ; then
		fqA=`parsePhyMLoutput "$fileStat" "fqA"`
		fqC=`parsePhyMLoutput "$fileStat" "fqC"`
		fqG=`parsePhyMLoutput "$fileStat" "fqG"`
		fqT=`parsePhyMLoutput "$fileStat" "fqT"`
		fq="$fqA,$fqC,$fqG,$fqT"
	else
		fq=""
	fi
	# Copy input alignment
	phyAln="$outDir"`basename "$inAln"`
	if [ ! -f "$phyAln" ] ; then
		cp "$inAln" "$phyAln"
		exitok $? "Cannot copy input file '$inAln' to '$phyAln'"
	fi
	# Build PhyML command line
	cmd="-i $phyAln -d $dType -o tlr "
	# Add model options
	cmd="$cmd"`model2cmd "$bestModel"`
	# Add decoration options
	cmd="$cmd"`deco2cmd "$bestDeco" "$dType" "$alpha" "$invar" "$fq"`
	# Add tree searching option
	if [ -n "$treeSearch" ] ; then
		cmd="$cmd -s $treeSearch "
	fi
	# Add random starting trees option
	if [ -n "$randTrees" ] ; then
		cmd="$cmd --rand_start --n_rand_starts $randTrees "
	fi
	# Add branch support option
	if [ -n "$support" ] ; then
		cmd="$cmd -b $support "
	fi
	# Add input tree topology option
	if [ -n "$inTree" ] ; then
		cmd="$cmd -u $inTree "
	fi
	cmd="$cmd --no_memory_check --quiet -u CONSTRAINTS --constraint_file=CONSTRAINTS --print_site_lnl"
	echo -e "Inferring tree with PhyML\n\tphyml $cmd" >>"$LOGFILEPATH"
	cmd="$PHYMLBIN $cmd"
	# Run PhyML
	eval "$cmd"
	exit "$?"
fi

exit 0

