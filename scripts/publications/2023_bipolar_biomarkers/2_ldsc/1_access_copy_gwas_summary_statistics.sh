#!/bin/bash


################################################################################
# Organize paths.

# Directories.
cd ~/paths
path_directory_gwas_summaries=$(<"./gwas_summaries_waller_metabolism.txt")
path_directory_gwas="${path_directory_gwas_summaries}/organization"
path_directory_process=$(<"./process_psychiatric_metabolism.txt")
path_directory_dock="${path_directory_process}/dock"
name_source_directory="5_gwas_effective_observations" # Name of directory with source GWAS summary statistics.
path_directory_source="${path_directory_gwas}/gwas_biomarkers_tcw_2023-05-25/${name_source_directory}"
path_directory_product_parent="${path_directory_dock}/ldsc_gwas_biomarkers_tcw_2023-05-25"
path_directory_product_child="${path_directory_product_parent}/${name_source_directory}"
path_directory_product="${path_directory_product_parent}/gwas_summaries_source"

# Initialize directories.
rm -r $path_directory_product # caution
mkdir -p $path_directory_product_parent
cd $path_directory_product_parent

################################################################################
# Execute procedure.

cp -r $path_directory_source $path_directory_product_parent
mv $path_directory_product_child $path_directory_product

################################################################################
# Report.
if [[ "$report" == "true" ]]; then
  echo "----------"
  echo "Script complete:"
  echo "1_access_copy_gwas_summary_statistics.sh"
  echo "----------"
fi
