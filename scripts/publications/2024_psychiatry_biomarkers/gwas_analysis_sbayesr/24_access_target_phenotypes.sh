#!/bin/bash

################################################################################
# Author: T. Cameron Waller
# Date, first execution: 31 August 2022
# Date, last execution: 10 April 2023 <-- Need to re-run for newer pheno data (TCW; 16 May 2023)
# Review: TCW; 10 April 2023
################################################################################
# Note

# Plan to keep all phenotype variables from the 13 May 2022 phenotype data set
# for Bipolar Disorder cases with a name prefix "2022-05-13_".

################################################################################
# Organize paths.

# Directories.
cd ~/paths
path_directory_storage=$(<"./storage_waller_metabolism.txt")

# Genotypes of all ancestries in Mayo Bipolar Disorder Biobank 1-2-Merge cases
#path_directory_genotypes=$(<"./genotypes_mayo_bipolar_disorder_1_2_merge.txt")
# Regeneron genotypes of all ancestries in Mayo Bipolar Disorder 1-2-Merge cases
#path_directory_genotypes=$(<"./genotypes_regeneron_mayo_bipolar_disorder_1_2_merge.txt")

# Regeneron genotypes of all ancestries in Mayo Bipolar Disorder 1-2-Merge cases and Mayo Clinic Biobank controls
path_directory_genotypes=$(<"./genotypes_regeneron_mayo_bipolar_disorder_1_2_merge_mayo_control.txt") # cases from Mayo Bipolar 1-2-Merge and controls from Mayo Clinic Biobank
# PCA on Regeneron genotypes of all ancestries in Mayo Bipolar Disorder 1-2-Merge cases and Mayo Clinic Biobank controls
# path = "genotype_regeneron_pca_mayo_bipolar_disorder_1_2_merge_mayo_control_all.txt"
# file = "Top20_PCs.csv"
path_directory_genotype_pca_all=$(<"./genotype_regeneron_pca_mayo_bipolar_disorder_1_2_merge_mayo_control_all.txt")
# PCA on Regeneron genotypes of European ancestry in Mayo Bipolar Disorder 1-2-Merge cases and Mayo Clinic Biobank controls
# path = "genotype_regeneron_pca_mayo_bipolar_disorder_1_2_merge_mayo_control_europe.txt"
# file = "Top20_PCs.csv"
path_directory_genotype_pca_europe=$(<"./genotype_regeneron_pca_mayo_bipolar_disorder_1_2_merge_mayo_control_europe.txt")

path_directory_phenotypes=$(<"./phenotypes_mayo_bipolar_disorder.txt")
path_directory_process=$(<"./process_psychiatric_metabolism.txt")
path_directory_dock="${path_directory_process}/dock" # parent directory for procedural reads and writes
path_directory_product="${path_directory_dock}/phenotypes_mayo_bipolar_disorder_1_2_merge"

# Files.
name_file_identifier="210421_id_matching_gwas.csv" # file date: 21 April 2021
#name_file_genetic_sex_case="MERGED.maf0.01.dosR20.8.noDups.fam" # file date: 20 May 2022 <-- Need to update for new genotypes; TCW; 4 April 2023
name_file_genetic_sex_case="GWAS_MERGED_BPphe_wMCBBctrl.maf0.01.dosR20.8.noDups.noSM.fam" # file date: 10 February 2023
name_file_genotype_pca="Top20_PCs.csv"
name_file_genotype_pca_all="Top20_PCs_all.csv" # file date: 13 February 2023
name_file_genotype_pca_europe="Top20_PCs_europe.csv" # file date: 13 February 2023

# Phenotype data for Bipolar Disorder cases (mostly).

name_file_phenotype_case_old="220513_BP_phenotypes.csv" # file date: 13 May 2022; Richard S. Pendegraft prepared and shared this file on 13 May 2022
name_file_phenotype_case_new="thyroid_prs.csv" # file date: 25 April 2023; Richard S. Pendegraft and Brandon J. Coombes, PhD prepared and shared this file on 25 April 2023
name_file_phenotype_supplement_1="220325_BP_phenotypes.csv" # file date: 31 March 2021
name_file_phenotype_supplement_2="211221_BP_phenotypes.csv" # file date: 23 December 2021
name_file_phenotype_supplement_3="210902_BP_phenotypes.csv" # file date: 2 September 2021
name_file_phenotype_supplement_4="210609_BP_phenotypes.csv" # file date: 9 June 2021
name_file_phenotype_supplement_5="210422_BP_phenotypes.csv" # file date: 5 May 2021
name_file_phenotype_supplement_6="210330_BP_phenotypes.csv" # file date: 13 April 2021
name_file_phenotype_supplement_7="phen_bp.csv" # file date: 5 September 2022

# Phenotype data for controls.
name_file_phenotype_control="gwas_TCF7L2_bib.csv" # file date: 9 September 2022; Joanna M. Biernacka shared this file on 9 September 2022

path_file_identifier_source="${path_directory_phenotypes}/${name_file_identifier}"
path_file_genetic_sex_case_source="${path_directory_genotypes}/${name_file_genetic_sex_case}"
path_file_genotype_pca_all_source="${path_directory_genotype_pca_all}/${name_file_genotype_pca}" # file date: 13 February 2023
path_file_genotype_pca_europe_source="${path_directory_genotype_pca_europe}/${name_file_genotype_pca}" # file date: 13 February 2023
path_file_phenotype_case_old_source="${path_directory_phenotypes}/${name_file_phenotype_case_old}"
path_file_phenotype_case_new_source="${path_directory_storage}/phenotypes/${name_file_phenotype_case_new}"
path_file_phenotype_supplement_1_source="${path_directory_phenotypes}/${name_file_phenotype_supplement_1}"
path_file_phenotype_supplement_2_source="${path_directory_phenotypes}/${name_file_phenotype_supplement_2}"
path_file_phenotype_supplement_3_source="${path_directory_phenotypes}/${name_file_phenotype_supplement_3}"
path_file_phenotype_supplement_4_source="${path_directory_phenotypes}/${name_file_phenotype_supplement_4}"
path_file_phenotype_supplement_5_source="${path_directory_phenotypes}/${name_file_phenotype_supplement_5}"
path_file_phenotype_supplement_6_source="${path_directory_phenotypes}/${name_file_phenotype_supplement_6}"
path_file_phenotype_supplement_7_source="${path_directory_phenotypes}/${name_file_phenotype_supplement_7}"
path_file_phenotype_control_source="${path_directory_storage}/phenotypes/${name_file_phenotype_control}"

path_file_identifier_product="${path_directory_product}/${name_file_identifier}"
path_file_genetic_sex_case_product="${path_directory_product}/${name_file_genetic_sex_case}"
path_file_genotype_pca_all_product="${path_directory_product}/${name_file_genotype_pca_all}"
path_file_genotype_pca_europe_product="${path_directory_product}/${name_file_genotype_pca_europe}"
path_file_phenotype_case_old_product="${path_directory_product}/${name_file_phenotype_case_old}"
path_file_phenotype_case_new_product="${path_directory_product}/${name_file_phenotype_case_new}"

path_file_phenotype_supplement_1_product="${path_directory_product}/${name_file_phenotype_supplement_1}"
path_file_phenotype_supplement_2_product="${path_directory_product}/${name_file_phenotype_supplement_2}"
path_file_phenotype_supplement_3_product="${path_directory_product}/${name_file_phenotype_supplement_3}"
path_file_phenotype_supplement_4_product="${path_directory_product}/${name_file_phenotype_supplement_4}"
path_file_phenotype_supplement_5_product="${path_directory_product}/${name_file_phenotype_supplement_5}"
path_file_phenotype_supplement_6_product="${path_directory_product}/${name_file_phenotype_supplement_6}"
path_file_phenotype_supplement_7_product="${path_directory_product}/${name_file_phenotype_supplement_7}"
path_file_phenotype_control_product="${path_directory_product}/${name_file_phenotype_control}"

# Initialize directories.
#rm -r $path_directory_product # Caution!
mkdir -p $path_directory_product
cd $path_directory_product

################################################################################
# Organize parameters.



################################################################################
# Execute procedure.

# Echo each command to console.
set -x

# Copy files.
cp $path_file_identifier_source $path_file_identifier_product
cp $path_file_genetic_sex_case_source $path_file_genetic_sex_case_product
cp $path_file_genotype_pca_all_source $path_file_genotype_pca_all_product
cp $path_file_genotype_pca_europe_source $path_file_genotype_pca_europe_product

cp $path_file_phenotype_case_old_source $path_file_phenotype_case_old_product
cp $path_file_phenotype_case_new_source $path_file_phenotype_case_new_product
cp $path_file_phenotype_supplement_1_source $path_file_phenotype_supplement_1_product
cp $path_file_phenotype_supplement_2_source $path_file_phenotype_supplement_2_product
cp $path_file_phenotype_supplement_3_source $path_file_phenotype_supplement_3_product
cp $path_file_phenotype_supplement_4_source $path_file_phenotype_supplement_4_product
cp $path_file_phenotype_supplement_5_source $path_file_phenotype_supplement_5_product
cp $path_file_phenotype_supplement_6_source $path_file_phenotype_supplement_6_product
cp $path_file_phenotype_supplement_7_source $path_file_phenotype_supplement_7_product
cp $path_file_phenotype_control_source $path_file_phenotype_control_product


#
