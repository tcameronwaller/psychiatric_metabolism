#!/bin/bash

################################################################################
# Author: T. Cameron Waller
# Date, first execution: 24 May 2023
# Date, last execution: 26 November 2023
# Date, review: 13 December 2023
################################################################################
# Note



################################################################################
# Organize paths.

# Identifiers or designators of parameter version and preparation batch.
identifier_preparation="tcw_2023-12-14_test"
identifier_parameter="tcw_2023-12-14_test"

# Directories.
cd ~/paths
path_directory_reference=$(<"./reference_tcw.txt")
path_directory_process=$(<"./process_psychiatric_metabolism.txt")
path_directory_dock="${path_directory_process}/dock" # parent directory for procedural reads and writes

path_directory_source="${path_directory_dock}/gwas_preparation_${identifier_preparation}/4_filter_constrain_gwas_values"
path_directory_product="${path_directory_dock}/gwas_preparation_${identifier_preparation}/5_fill_dbsnp_rs_identifiers"

# Files.

# Scripts.
path_directory_partner_scripts="${path_directory_process}/partner/scripts"
path_file_script_fill_dbsnp="${path_directory_partner_scripts}/gwas_clean/fill_reference_snp_cluster_identifier.sh"

# Initialize directories.
rm -r $path_directory_product # caution
mkdir -p $path_directory_product
cd $path_directory_product

###########################################################################
# Organize parameters.

strict="false"
report="true"

################################################################################
# Execute procedure.



##########
# Copy the GWAS summary statistics from the previous process.
# Most sets of GWAS summary statistics do not need extra processing.
# Subsequent processes on a few studies will replace the appropriate files.
cp $path_directory_source/*.txt.gz $path_directory_product

##########
# Fill missing SNP rsIDs from dbSNP.



##########
# 37872160_williams_2023

/usr/bin/bash $path_file_script_fill_dbsnp \
"${path_directory_source}/37872160_williams_2023.txt.gz" \
"${path_directory_product}/37872160_williams_2023.txt.gz" \
$strict \
$report



#
