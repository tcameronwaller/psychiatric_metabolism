#!/bin/bash

################################################################################
# Author: T. Cameron Waller
# Date, first execution: 6 August 2023
# Date, last execution: 16 November 2023
# Date, review: 16 November 2023
################################################################################
# Note

# For a reference on a previous script to set up a large count of comparisons
# between primary and secondary sets of GWAS summary statistics, look at the
# script "6_call_submit_gwas_ldsc_genetic_correlation.sh" in the directory
# "/.../sexy_alcohol/repository/scripts/record/2022-08-01/ldsc_heritability_correlation/".

# TCW; 16 November 2023
# count of batch instances: 621
# batch job: ___

################################################################################
# Organize paths.

# Directories.
cd ~/paths
path_directory_process=$(<"./process_psychiatric_metabolism.txt")
path_directory_dock="${path_directory_process}/dock"
path_directory_reference="${path_directory_dock}/ldsc_gwas_tcw_2023-11-13/2_reference_ldsc"
path_directory_disequilibrium="${path_directory_reference}/disequilibrium/eur_w_ld_chr"

path_directory_source_primary="${path_directory_dock}/ldsc_gwas_tcw_2023-11-13/4_gwas_munge_ldsc"
path_directory_source_secondary="${path_directory_dock}/ldsc_gwas_tcw_2023-11-13/4_gwas_munge_ldsc"
path_directory_product_parent="${path_directory_dock}/ldsc_gwas_tcw_2023-11-13/6_gwas_correlation_ldsc"
path_directory_batch="${path_directory_product_parent}/batch"

# Files.
path_file_batch_instances="${path_directory_batch}/batch_instances.txt"
#path_file_batch_out="${path_directory_batch}/batch_out.txt"
#path_file_batch_error="${path_directory_batch}/batch_error.txt"

# Scripts.
path_directory_partner_scripts="${path_directory_process}/partner/scripts"
path_directory_ldsc="${path_directory_partner_scripts}/ldsc"
path_file_script_ldsc_correlation="${path_directory_ldsc}/estimate_gwas_genetic_correlation_ldsc.sh"
path_file_script_ldsc_correlation_batch_1="${path_directory_ldsc}/ldsc_correlation_batch_1.sh"

# Initialize directories.
rm -r $path_directory_product_parent # caution
rm -r $path_directory_batch # caution
mkdir -p $path_directory_product_parent
mkdir -p $path_directory_batch

# Initialize files.
rm $path_file_batch_instances

################################################################################
# Organize parameters.



##########
# Common parameters.
threads=2
report="true"



##########
# Primary studies.
# Define array of primary studies.
primaries=()
primaries+=("36477530_saunders_2022_alcohol_all")
primaries+=("36477530_saunders_2022_alcohol_no_ukb")
primaries+=("30643251_liu_2019_alcohol_all")
primaries+=("30643251_liu_2019_alcohol_no_ukb")
primaries+=("30482948_walters_2018_eur_all")
primaries+=("30482948_walters_2018_eur_unrel_meta")
primaries+=("30482948_walters_2018_eur_unrel_genotype")
primaries+=("30482948_walters_2018_female")
primaries+=("30482948_walters_2018_male")

##########
# Secondary studies.

# Note: TCW; 10 August 2023
# This list of secondary studies includes most of the GWAS summary statistics in
# the collection of biomarkers and thyroid disorders from TCW in 2023.
# The few exceptions are the 2019 GWAS from Pott et al (PubMed:31169883) that
# were repeated with larger sample sizes in 2021 (PubMed:34822396).

# Define array of secondary studies.
secondaries=()

# Sex hormones.

secondaries+=("31169883_pott_2019_testosterone_all")
secondaries+=("32042192_ruth_2020_testosterone_female")
secondaries+=("33587031_sinnott-armstrong_2021_testosterone_primary_female")
secondaries+=("33587031_sinnott-armstrong_2021_testosterone_secondary_female")
secondaries+=("31169883_pott_2019_testosterone_female")
secondaries+=("32042192_ruth_2020_testosterone_male")
secondaries+=("33587031_sinnott-armstrong_2021_testosterone_primary_male")
secondaries+=("33587031_sinnott-armstrong_2021_testosterone_secondary_male")
secondaries+=("31169883_pott_2019_testosterone_male")
secondaries+=("32042192_ruth_2020_testosterone_bioavailable_female")
secondaries+=("33587031_sinnott-armstrong_2021_testosterone_bioavailable_female")
secondaries+=("32042192_ruth_2020_testosterone_bioavailable_male")
secondaries+=("33587031_sinnott-armstrong_2021_testosterone_bioavailable_male")

secondaries+=("31169883_pott_2019_estradiol_all")
secondaries+=("34255042_schmitz_2021_estradiol_female")
secondaries+=("34255042_schmitz_2021_estradiol_male")
secondaries+=("32042192_ruth_2020_estradiol_male")
secondaries+=("31169883_pott_2019_estradiol_female")
secondaries+=("31169883_pott_2019_estradiol_male")
secondaries+=("34822396_pott_2021_testosterone_estradiol_all")
secondaries+=("34822396_pott_2021_testosterone_estradiol_female")
secondaries+=("34822396_pott_2021_testosterone_estradiol_male")

secondaries+=("34822396_pott_2021_progesterone_all")
secondaries+=("31169883_pott_2019_progesterone_all")
secondaries+=("34822396_pott_2021_progesterone_female")
secondaries+=("31169883_pott_2019_progesterone_female")
secondaries+=("34822396_pott_2021_progesterone_male")
secondaries+=("31169883_pott_2019_progesterone_male")
secondaries+=("34822396_pott_2021_hydroxyprogesterone_all")
secondaries+=("31169883_pott_2019_hydroxyprogesterone_all")
secondaries+=("34822396_pott_2021_hydroxyprogesterone_female")
secondaries+=("31169883_pott_2019_hydroxyprogesterone_female")
secondaries+=("34822396_pott_2021_hydroxyprogesterone_male")
secondaries+=("31169883_pott_2019_hydroxyprogesterone_male")
secondaries+=("31169883_pott_2019_dheas_all")
secondaries+=("31169883_pott_2019_dheas_female")
secondaries+=("31169883_pott_2019_dheas_male")
secondaries+=("34822396_pott_2021_androstenedione_all")
secondaries+=("31169883_pott_2019_androstenedione_all")
secondaries+=("34822396_pott_2021_androstenedione_female")
secondaries+=("31169883_pott_2019_androstenedione_female")
secondaries+=("34822396_pott_2021_androstenedione_male")
secondaries+=("31169883_pott_2019_androstenedione_male")
secondaries+=("34822396_pott_2021_aldosterone_all")
secondaries+=("31169883_pott_2019_aldosterone_all")
secondaries+=("34822396_pott_2021_aldosterone_female")
secondaries+=("31169883_pott_2019_aldosterone_female")
secondaries+=("34822396_pott_2021_aldosterone_male")
secondaries+=("31169883_pott_2019_aldosterone_male")
secondaries+=("33441150_dennis_2021_follitropin")
secondaries+=("29875488_sun_2018_follitropin")
secondaries+=("29875488_sun_2018_follistatin")
secondaries+=("33587031_sinnott-armstrong_2021_lutropin")
secondaries+=("29875488_sun_2018_lutropin")
secondaries+=("33441150_dennis_2021_lutropin")
secondaries+=("29875488_sun_2018_lutropin_beta")

secondaries+=("32042192_ruth_2020_shbg_all")
secondaries+=("00000000_neale_2020_shbg")
secondaries+=("32042192_ruth_2020_shbg_female")
secondaries+=("33587031_sinnott-armstrong_2021_shbg_female")
secondaries+=("32042192_ruth_2020_shbg_male")
secondaries+=("33587031_sinnott-armstrong_2021_shbg_male")
secondaries+=("32042192_ruth_2020_shbg_bmi_all")
secondaries+=("32042192_ruth_2020_shbg_bmi_female")
secondaries+=("32042192_ruth_2020_shbg_bmi_male")

# Biomarkers.
secondaries+=("34017140_mbatchou_2021_albumin")
secondaries+=("34662886_backman_2021_albumin")
secondaries+=("34226706_barton_2021_albumin")
secondaries+=("00000000_neale_2020_albumin")

##########
# Organize multi-dimensional array of information about comparisons.
# [full path to base name of product file] ; \
# [full path to primary source file of LDSC munge GWAS summary statistics] ; \
# [full path to secondary source file of LDSC munge GWAS summary statistics]

comparisons=()
#comparisons+=(
#  "${path_directory_product}/hypothyroidism_against_hyperthyroidism;\
#  ${path_directory_source_primary}/30367059_teumer_2018_hypothyroidism.sumstats.gz;\
#  ${path_directory_source_secondary}/30367059_teumer_2018_hyperthyroidism.sumstats.gz"
#)

if true; then
  # Assemble array of batch instance details.
  for primary in "${primaries[@]}"; do
    for secondary in "${secondaries[@]}"; do
      # Organize paths.
      path_directory_product_child="${path_directory_product_parent}/${primary}"
      mkdir -p $path_directory_product_child
      #name_comparison="${primary}_-_${secondary}"
      name_comparison="${secondary}"
      path_file_base_product="${path_directory_product_child}/${name_comparison}"
      path_file_source_primary="${path_directory_source_primary}/${primary}.sumstats.gz"
      path_file_source_secondary="${path_directory_source_secondary}/${secondary}.sumstats.gz"
      # Assemble parameters for comparison.
      comparisons+=("${path_file_base_product};${path_file_source_primary};${path_file_source_secondary}")
    done
  done
fi



################################################################################
# Report.

count_comparisons=${#comparisons[@]}

# Report.
if [[ "$report" == "true" ]]; then
  echo "----------"
  echo "Source directory:"
  echo $path_directory_source
  echo "count of comparisons: " $count_comparisons
  echo "first file: " ${comparisons[0]} # notice base-zero indexing
  echo "last file: " ${comparisons[$count_comparisons - 1]}
  echo "----------"
fi

sleep 5s

################################################################################
# Execute procedure.



##########
# Simple iteration.
if false; then
  for comparison in "${comparisons[@]}"; do
    # Separate fields from instance.
    # [regression type] ; [full path to source file of GWAS summary statistics] ; [full path to product file of GWAS summary statistics]
    IFS=";" read -r -a array <<< "${comparison}"
    path_file_base_product="${array[0]}"
    path_file_source_primary="${array[1]}"
    path_file_source_secondary="${array[2]}"
    # Estimate Genetic Correlation by LDSC.
    /usr/bin/bash $path_file_script_ldsc_correlation \
    $path_file_source_primary \
    $path_file_source_secondary \
    $path_file_base_product \
    $path_directory_disequilibrium \
    $threads \
    $report
    # Report.
    if [[ "$report" == "true" ]]; then
      echo "----------"
      echo "Script path:"
      echo $path_script
      echo "Product file path:"
      echo $path_file_base_product
      echo "Primary source file path:"
      echo $path_file_source_primary
      echo "Secondary source file path:"
      echo $path_file_source_secondary
      echo "----------"
    fi
  done
fi



##########
# Batch parallelization.
if true; then
  # Organize batch job instances.
  for comparison in "${comparisons[@]}"; do
    # Define parameters in array instance for batch job.
    echo $comparison >> $path_file_batch_instances
  done
  # Call first script in series for batch execution.
  /usr/bin/bash $path_file_script_ldsc_correlation_batch_1 \
  $path_file_batch_instances \
  $path_directory_batch \
  $path_directory_product_parent \
  $path_directory_disequilibrium \
  $path_directory_process \
  $threads \
  $report
fi



################################################################################
# Report.
if [[ "$report" == "true" ]]; then
  echo "----------"
  echo "Script complete:"
  echo $0 # Print full file path to script.
  echo "6_estimate_gwas_genetic_correlation_ldsc.sh"
  echo "----------"
fi



#