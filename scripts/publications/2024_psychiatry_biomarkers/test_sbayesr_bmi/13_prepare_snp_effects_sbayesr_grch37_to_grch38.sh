#!/bin/bash

################################################################################
################################################################################
################################################################################
# Author: T. Cameron Waller
# Date, first execution: 10 March 2023
# Date, last execution: 21 March 2023
################################################################################
################################################################################
################################################################################
# Note

# TODO: TCW; 4 April 2023
# PIPE: iterate on a list of child files within a parent directory



################################################################################
################################################################################
################################################################################



################################################################################
# Organize paths.

# Directories.
cd ~/paths
path_directory_reference=$(<"./reference_tcw.txt")
path_directory_process=$(<"./process_psychiatric_metabolism.txt")
path_directory_dock="${path_directory_process}/dock" # parent directory for procedural reads and writes

path_directory_source_1="${path_directory_dock}/test_sbayesr_body_mass_tcw_2023-03-21/sbayesr_effects_1_combination"
path_directory_source_2="${path_directory_dock}/test_sbayesr_body_mass_tcw_2023-03-21/sbayesr_effects_2_combination"
path_directory_source_3="${path_directory_dock}/test_sbayesr_body_mass_tcw_2023-03-21/sbayesr_effects_3_combination"
path_directory_product="${path_directory_dock}/test_sbayesr_body_mass_tcw_2023-03-21/sbayesr_effects_grch38"

# Files.
path_file_1_grch37="${path_directory_source_1}/BMI_GIANTUKB_EUR_tcw_2023-03-21.snpRes"
path_file_2_grch37="${path_directory_source_2}/BMI_GIANTUKB_EUR_tcw_2023-03-21.snpRes"
path_file_3_grch37="${path_directory_source_3}/BMI_GIANTUKB_EUR_tcw_2023-03-21.snpRes"
path_file_1_grch37_ucsc_bed="${path_directory_product}/BMI_GIANTUKB_EUR_1_grch37.bed.gz"
path_file_2_grch37_ucsc_bed="${path_directory_product}/BMI_GIANTUKB_EUR_2_grch37.bed.gz"
path_file_3_grch37_ucsc_bed="${path_directory_product}/BMI_GIANTUKB_EUR_3_grch37.bed.gz"
#path_file_chain_grch37_to_grch38="${path_directory_reference}/assembly_chains/ucsc/hg19ToHg38.over.chain.gz"
path_file_chain_grch37_to_grch38="${path_directory_reference}/crossmap/ensembl/GRCh37_to_GRCh38.chain.gz"
path_file_1_grch38_ucsc_bed="${path_directory_product}/BMI_GIANTUKB_EUR_1_grch38.bed.gz"
path_file_2_grch38_ucsc_bed="${path_directory_product}/BMI_GIANTUKB_EUR_2_grch38.bed.gz"
path_file_3_grch38_ucsc_bed="${path_directory_product}/BMI_GIANTUKB_EUR_3_grch38.bed.gz"
path_file_1_grch38="${path_directory_product}/BMI_GIANTUKB_EUR_1_grch38_standard.txt.gz"
path_file_2_grch38="${path_directory_product}/BMI_GIANTUKB_EUR_2_grch38_standard.txt.gz"
path_file_3_grch38="${path_directory_product}/BMI_GIANTUKB_EUR_3_grch38_standard.txt.gz"

# Scripts.
path_script_ucsc_bed="${path_directory_process}/promiscuity/scripts/gctb/translate_snp_effects_sbayesr_to_ucsc_bed.sh"
path_script_map="${path_directory_process}/promiscuity/scripts/crossmap/map_genomic_feature_bed.sh"
#path_script_standard="${path_directory_process}/promiscuity/scripts/gctb/translate_snp_effects_ucsc_bed_to_standard.sh"
path_script_standard="${path_directory_process}/promiscuity/scripts/gctb/translate_snp_effects_ucsc_bed_to_standard_identifier.sh"

# Initialize directories.
rm -r $path_directory_product
mkdir -p $path_directory_product
cd $path_directory_product



###########################################################################
# Organize parameters.

threads=1
report="true"

###########################################################################
# Execute procedure.

##########
# Translate SBayesR SNP effect weights format from SBayesR to CrossMap UCSC BED.

if true; then
  # 1.
  /usr/bin/bash $path_script_ucsc_bed \
  $path_file_1_grch37 \
  $path_file_1_grch37_ucsc_bed \
  $report
  # 2.
  /usr/bin/bash $path_script_ucsc_bed \
  $path_file_2_grch37 \
  $path_file_2_grch37_ucsc_bed \
  $report
  # 3.
  /usr/bin/bash $path_script_ucsc_bed \
  $path_file_3_grch37 \
  $path_file_3_grch37_ucsc_bed \
  $report
fi

##########
# Translate SBayesR SNP effect weights in CrossMap from GRCh37 to GRCh38.

if true; then
  # 1.
  /usr/bin/bash $path_script_map \
  $path_file_1_grch37_ucsc_bed \
  $path_file_1_grch38_ucsc_bed \
  $path_file_chain_grch37_to_grch38 \
  $threads \
  $report
  # 2.
  /usr/bin/bash $path_script_map \
  $path_file_2_grch37_ucsc_bed \
  $path_file_2_grch38_ucsc_bed \
  $path_file_chain_grch37_to_grch38 \
  $threads \
  $report
  # 3.
  /usr/bin/bash $path_script_map \
  $path_file_3_grch37_ucsc_bed \
  $path_file_3_grch38_ucsc_bed \
  $path_file_chain_grch37_to_grch38 \
  $threads \
  $report
fi

##########
# Translate SBayesR SNP effect weights format from CrossMap UCSC BED to team standard with special identifiers.
# The format of variant (SNP) identifiers must match the target genotypes.

if true; then
  # 1.
  /usr/bin/bash $path_script_standard \
  $path_file_1_grch38_ucsc_bed \
  $path_file_1_grch38 \
  $report
  # 2.
  /usr/bin/bash $path_script_standard \
  $path_file_2_grch38_ucsc_bed \
  $path_file_2_grch38 \
  $report
  # 3.
  /usr/bin/bash $path_script_standard \
  $path_file_3_grch38_ucsc_bed \
  $path_file_3_grch38 \
  $report
fi


################################################################################
# Report.

if [[ "$report" == "true" ]]; then
  echo "----------"
  echo "Script:"
  echo "12_translate_snp_effects_sbayesr_grch37_to_grch38.sh"
  echo "----------"
fi



#
