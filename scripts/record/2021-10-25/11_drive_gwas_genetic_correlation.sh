#!/bin/bash

###########################################################################
###########################################################################
###########################################################################
# ...
###########################################################################
###########################################################################
###########################################################################

################################################################################
# General parameters.

################################################################################
# Organize paths.
# Read private, local file paths.
cd ~/paths
path_process=$(<"./process_psychiatric_metabolism.txt")
path_dock="$path_process/dock"

###########################################################################
# Define main comparisons.

cohorts_models="body_white_bipolar_strict"
#cohorts_models="body_white_bipolar_loose"
name_gwas_munge_file="gwas_munge.sumstats.gz"
path_gwas_source_container="${path_dock}/gwas_process/${cohorts_models}"

# Define array of primary studies.
primaries=()
primaries+=("30124842_yengo_2018;${path_dock}/gwas_process/30124842_yengo_2018/${name_gwas_munge_file}")

# Define array of secondary studies.
secondaries=()
# Iterate on directories for GWAS on cohorts and hormones.
cd $path_gwas_source_container
for path_directory in `find . -maxdepth 1 -mindepth 1 -type d -not -name .`; do
  if [ -d "$path_directory" ]; then
    # Current content item is a directory.
    # Extract directory's base name.
    study="$(basename -- $path_directory)"
    #echo $directory
    # Determine whether directory contains valid GWAS summary statistics.
    matches=$(find "${path_gwas_source_container}/${study}" -name "$name_gwas_munge_file")
    match_file=${matches[0]}
    if [[ -n $matches && -f $match_file ]]; then
      secondaries+=("$study;${path_gwas_source_container}/${study}/${name_gwas_munge_file}")
    fi
  fi
done

# Assemble array of batch instance details.
comparison_container="community_control_versus_strict_case"
comparisons=()
for primary in "${primaries[@]}"; do
  for secondary in "${secondaries[@]}"; do
    comparisons+=("${comparison_container};${primary};${secondary}")
  done
done

################################################################################
# Append custom comparisons that do not follow the same pattern.

##########
# Strict definition of Bipolar Disorder
if true; then
  # Body Mass Index without logarithmic transformation.
  pairs=()
  pairs+=("white_bipolar_strict_control_unadjust_body;white_bipolar_strict_case_unadjust_body")
  pairs+=("white_bipolar_strict_control_sex_body;white_bipolar_strict_case_sex_body")
  pairs+=("white_bipolar_strict_control_sex_age_body;white_bipolar_strict_case_sex_age_body")
  # Construct paths.
  comparison_container="strict_control_versus_strict_case"
  cohorts_models="body_white_bipolar_strict"
  name_gwas_munge_file="gwas_munge.sumstats.gz"
  path_gwas_source_container="${path_dock}/gwas_process/${cohorts_models}"
  for pair in "${pairs[@]}"; do
    IFS=";" read -r -a array <<< "${pair}"
    study_primary="${array[0]}"
    study_secondary="${array[1]}"
    comparisons+=("${comparison_container};${study_primary};${path_gwas_source_container}/${study_primary}/${name_gwas_munge_file};${study_secondary};${path_gwas_source_container}/${study_secondary}/${name_gwas_munge_file}")
  done
fi

##########
# Loose definition of Bipolar Disorder
if true; then
  # Loose definition of Bipolar Disorder.
  # Body Mass Index without logarithmic transformation.
  pairs=()
  pairs+=("white_bipolar_loose_control_unadjust_body;white_bipolar_loose_case_unadjust_body")
  pairs+=("white_bipolar_loose_control_sex_body;white_bipolar_loose_case_sex_body")
  pairs+=("white_bipolar_loose_control_sex_age_body;white_bipolar_loose_case_sex_age_body")
  # Construct paths.
  comparison_container="loose_control_versus_loose_case"
  cohorts_models="body_white_bipolar_loose"
  name_gwas_munge_file="gwas_munge.sumstats.gz"
  path_gwas_source_container="${path_dock}/gwas_process/${cohorts_models}"
  for pair in "${pairs[@]}"; do
    IFS=";" read -r -a array <<< "${pair}"
    study_primary="${array[0]}"
    study_secondary="${array[1]}"
    comparisons+=("${comparison_container};${study_primary};${path_gwas_source_container}/${study_primary}/${name_gwas_munge_file};${study_secondary};${path_gwas_source_container}/${study_secondary}/${name_gwas_munge_file}")
  done
fi

##########
# Explicit comparison pairs that do not follow previous patterns.
comparison_container="strict_case_versus_loose_case"
path_strict="${path_dock}/gwas_process/body_white_bipolar_strict"
path_loose="${path_dock}/gwas_process/body_white_bipolar_loose"
name_gwas_munge_file="gwas_munge.sumstats.gz"
comparisons+=("${comparison_container};white_bipolar_strict_case_unadjust_body;${path_strict}/white_bipolar_strict_case_unadjust_body/${name_gwas_munge_file};white_bipolar_loose_case_unadjust_body;${path_loose}/white_bipolar_loose_case_unadjust_body/${name_gwas_munge_file}")
comparisons+=("${comparison_container};white_bipolar_strict_case_sex_body;${path_strict}/white_bipolar_strict_case_sex_body/${name_gwas_munge_file};white_bipolar_loose_case_sex_body;${path_loose}/white_bipolar_loose_case_sex_body/${name_gwas_munge_file}")
comparisons+=("${comparison_container};white_bipolar_strict_case_sex_age_body;${path_strict}/white_bipolar_strict_case_sex_age_body/${name_gwas_munge_file};white_bipolar_loose_case_sex_age_body;${path_loose}/white_bipolar_loose_case_sex_age_body/${name_gwas_munge_file}")

################################################################################
# Drive genetic correlations across comparisons.
# Format for array of comparisons.
# "study_primary;path_gwas_primary_munge_suffix;study_secondary;path_gwas_secondary_munge_suffix"

for comparison in "${comparisons[@]}"; do

  ##############################################################################
  # Extract details for comparison.
  IFS=";" read -r -a array <<< "${comparison}"
  comparison_container="${array[0]}"
  study_primary="${array[1]}"
  path_gwas_primary_munge_suffix="${array[2]}"
  study_secondary="${array[3]}"
  path_gwas_secondary_munge_suffix="${array[4]}"
  echo "----------"
  echo "comparison container: ${comparison_container}"
  echo "primary study: ${study_primary}"
  echo "path: ${path_gwas_primary_munge_suffix}"
  echo "secondary study: ${study_secondary}"
  echo "path: ${path_gwas_secondary_munge_suffix}"

  if true; then
    ##############################################################################
    # LDSC Genetic Correlation.
    # Paths.
    path_genetic_reference="${path_dock}/access/genetic_reference"
    #study_primary=""
    #study_secondary=""
    #path_gwas_primary_munge_suffix=""
    #path_gwas_secondary_munge_suffix=""
    path_genetic_correlation_parent="${path_dock}/genetic_correlation/${comparison_container}/${study_primary}/${study_secondary}"
    rm -r $path_genetic_correlation_parent
    mkdir -p $path_genetic_correlation_parent
    # Scripts.
    path_promiscuity_scripts="${path_process}/promiscuity/scripts"
    path_scripts_gwas_process="${path_promiscuity_scripts}/gwas_process"
    path_script_drive_ldsc_gwas_genetic_correlation="${path_scripts_gwas_process}/drive_ldsc_gwas_genetic_correlation.sh"
    # Parameters.
    report="true" # "true" or "false"
    /usr/bin/bash "$path_script_drive_ldsc_gwas_genetic_correlation" \
    $path_gwas_primary_munge_suffix \
    $path_gwas_secondary_munge_suffix \
    $path_genetic_correlation_parent \
    $path_genetic_reference \
    $report
  fi
done
