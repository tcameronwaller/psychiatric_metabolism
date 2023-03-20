#!/bin/bash

################################################################################
# Author: T. Cameron Waller
# Date, first execution: 15 March 2023
# Date, last execution: 20 March 2023
# Review: TCW; ___
################################################################################
# Note



################################################################################
# Organize paths.

# Directories.
cd ~/paths
path_directory_process=$(<"./process_psychiatric_metabolism.txt")
path_directory_dock="${path_directory_process}/dock" # parent directory for procedural reads and writes
path_directory_source_genotypes="${path_directory_dock}/genotypes_mayo_bipolar_disorder_1_2_merge"
path_directory_source_effects="${path_directory_dock}/test_sbayesr_body_mass_tcw_2023-03-01/sbayesr_snp_effects_grch38"
path_directory_product="${path_directory_dock}/test_sbayesr_body_mass_tcw_2023-03-01/test_polygenic_scores"

# Files.
path_file_source_effects="${path_directory_source_effects}/BMI_GIANTUKB_EUR_grch38_standard.txt.gz"
name_file_genotypes_prefix="MERGED.maf0.dosR20.3.noDups.chr"
name_file_genotypes_suffix=".dose.vcf.gz"
name_file_product_prefix="BMI_GIANTUKB_EUR_chromosome_"
name_file_product_suffix=""
#path_file_product="${path_directory_product}/${name_file_product_prefix}${chromosome}${name_file_product_suffix}"

# Scripts.
path_script_drive_calculate="${path_directory_process}/promiscuity/scripts/plink/calculate_polygenic_score.sh"

# Initialize directories.
rm -r $path_directory_product
mkdir -p $path_directory_product
cd $path_directory_product

###########################################################################
# Organize parameters.

chromosome_x="false"
threads=4
report="true"

###########################################################################
# Execute procedure.

# Iterate on relevant chromosomes.
if [[ "$chromosome_x" == "true" ]]; then
  chromosomes=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "X")
else
  chromosomes=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22")
fi
for chromosome in "${chromosomes[@]}"; do
  # Define paths and names to files for current chromosome.
  # Files.
  path_file_source_genotypes="${path_directory_source_genotypes}/${name_file_genotypes_prefix}${chromosome}${name_file_genotypes_suffix}"
  name_base_file_product="${name_file_product_prefix}${chromosome}${name_file_product_suffix}"
  # Calculate polygenic scores for a single chromosome.
  /usr/bin/bash $path_script_drive_calculate \
  $path_file_source_effects \
  $path_file_source_genotypes \
  $path_directory_product \
  $name_base_file_product \
  $threads \
  $report
done



################################################################################
# Report.

if [[ "$report" == "true" ]]; then
  echo "----------"
  echo "Script:"
  echo "15_calculate_polygenic_scores.sh"
  echo "----------"
fi



#
