#!/bin/bash

################################################################################
# Author: T. Cameron Waller
# Date, first execution: 3 October 2023
# Date, last execution: 3 October 2023
# Date, review: 3 October 2023
################################################################################
# Note

# count of files: 123

################################################################################
# Organize paths.

# Directories.
cd ~/paths
path_directory_gwas_summaries=$(<"./gwas_summaries_waller_metabolism.txt")
path_directory_process=$(<"./process_psychiatric_metabolism.txt")
path_directory_dock="${path_directory_process}/dock"

path_directory_parent_source=$path_directory_dock
path_directory_parent_product="${path_directory_gwas_summaries}/organization"

path_directory_source="${path_directory_dock}/gwas_biomarkers_tcw_2023-09-29"
path_directory_product="${path_directory_gwas_summaries}/organization/gwas_biomarkers_tcw_2023-09-29"

# Initialize directories.
rm -r $path_directory_product # caution

################################################################################
# Organize parameters.

report="true"
set -x

################################################################################
# Execute procedure.

cd $path_directory_parent_product
pwd
du -hs ./*

cd $path_directory_source
pwd
du -hs ./*

cp -r $path_directory_source $path_directory_product

cd $path_directory_product
pwd
du -hs ./*



#
