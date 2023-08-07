
"""

This module contains functions for the collection, aggregation, and organization
of polygenic scores that represent abundance of metabolites in the blood.

"""

###############################################################################
# Notes

###############################################################################
# Installation and importation

# Standard

import sys
#print(sys.path)
import os
import math
import statistics
import pickle
import copy
import random
import itertools

# Relevant

import numpy
import pandas
import scipy.stats

# Custom
import partner.utility as utility

###############################################################################
# Functionality


##########
# Initialization


def initialize_directories(
    restore=None,
    path_dock=None,
):
    """
    Initialize directories for procedure's product files.

    arguments:
        restore (bool): whether to remove previous versions of data
        path_dock (str): path to dock directory for source and product
            directories and files

    raises:

    returns:
        (dict<str>): collection of paths to directories for procedure's files

    """

    # Collect paths.
    paths = dict()
    # Define paths to directories.
    paths["dock"] = path_dock
    paths["assembly"] = os.path.join(path_dock, "assembly")
    paths["raw"] = os.path.join(
        path_dock, "assembly", "raw"
    )
    paths["inspection"] = os.path.join(
        path_dock, "assembly", "inspection"
    )
    # Remove previous files to avoid version or batch confusion.
    if restore:
        utility.remove_directory(path=paths["assembly"])
    # Initialize directories.
    utility.create_directories(
        path=paths["assembly"]
    )
    utility.create_directories(
        path=paths["raw"]
    )
    utility.create_directories(
        path=paths["inspection"]
    )
    # Return information.
    return paths


##########
# Read


def read_source(
    path_dock=None,
    report=None,
):
    """
    Reads and organizes source information from file.

    Notice that Pandas does not accommodate missing values within series of
    integer variable types.

    arguments:
        path_dock (str): path to dock directory for source and product
            directories and files
        report (bool): whether to print reports

    raises:

    returns:
        (object): source information

    """

    # Specify directories and files.
    path_table_ukbiobank_variables = os.path.join(
        path_dock, "parameters", "uk_biobank", "table_ukbiobank_phenotype_variables.tsv"
    )
    path_exclusion_identifiers = os.path.join(
        path_dock, "access", "list_exclusion_identifiers.txt"
    )
    path_table_identifier_pairs = os.path.join(
        path_dock, "access", "table_identifier_pairs.csv"
    )
    path_table_ukb_41826 = os.path.join(
        path_dock, "access", "ukb41826.raw.csv"
    )
    path_table_ukb_43878 = os.path.join(
        path_dock, "access", "ukb43878.raw.csv"
    )
    # Read all column names from UK Biobank tables.
    columns_accession = read_collect_ukbiobank_accession_column_names(
        path_table_ukb_41826=path_table_ukb_41826,
        path_table_ukb_43878=path_table_ukb_43878,
    )
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print("unique column names: " + str(len(columns_accession)))
        print(columns_accession)
        utility.print_terminal_partition(level=2)
        pass
    # Determine variable types.
    table_ukbiobank_variables = pandas.read_csv(
        path_table_ukbiobank_variables,
        sep="\t",
        header=0,
    )
    variables_types = extract_organize_variables_types(
        table_ukbiobank_variables=table_ukbiobank_variables,
        columns=columns_accession,
        extra_pairs={
            "IID": "string",
            "eid": "string",
        },
    )
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print(variables_types["31-0.0"])
        print("20117-0.0: " + str(variables_types["20117-0.0"]))
    # Read information from file.
    exclusion_identifiers = utility.read_file_text_list(
        delimiter="\n",
        path_file=path_exclusion_identifiers
    )
    table_identifier_pairs = pandas.read_csv(
        path_table_identifier_pairs,
        sep=",",
        header=0,
        dtype="string",
    )
    table_ukb_41826 = pandas.read_csv(
        path_table_ukb_41826,
        sep=",", # "," or "\t"
        header=0,
        dtype=variables_types,
        na_values=["<NA>"],
        keep_default_na=True,
    )
    table_ukb_43878 = pandas.read_csv(
        path_table_ukb_43878,
        sep=",", # "," or "\t"
        header=0,
        dtype=variables_types,
        na_values=["<NA>"],
        keep_default_na=True,
    )
    # Compile and return information.
    return {
        "table_ukbiobank_variables": table_ukbiobank_variables,
        "columns_accession": columns_accession,
        "exclusion_identifiers": exclusion_identifiers,
        "table_identifier_pairs": table_identifier_pairs,
        "table_ukb_41826": table_ukb_41826,
        "table_ukb_43878": table_ukb_43878,
    }


##########
# Metabolites


def determine_metabolite_valid_identity(
    name=None,
):
    """
    Determine whether a single metabolite has a valid identity from Metabolon.

    arguments:
        name (str): name of metabolite from Metabolon reference

    raises:

    returns:
        (float): ordinal representation of person's frequency of alcohol
            consumption

    """

    # Determine whether the variable has a valid (non-missing) value.
    if (len(str(name)) > 2):
        # The variable has a valid value.
        if (str(name).strip().lower().startswith("x-")):
            # Metabolite has an indefinite identity.
            identity = 0
        else:
            # Metabolite has a definite identity.
            identity = 1
    else:
        # Name is empty.
        #identity = float("nan")
        identity = 0
    # Return information.
    return identity


def select_organize_metabolites_valid_identities_scores(
    table_names=None,
    table_scores=None,
    report=None,
):
    """
    Selects identifiers of metabolites from Metabolon with valid identities.

    arguments:
        table_names (object): Pandas data frame of metabolites' identifiers and
            names from Metabolon
        table_scores (object): Pandas data frame of metabolites' genetic scores
            across UK Biobank cohort
        report (bool): whether to print reports

    raises:

    returns:
        (dict): collection of information about metabolites, their identifiers,
            and their names

    """

    # Copy information.
    table_names = table_names.copy(deep=True)
    table_scores = table_scores.copy(deep=True)
    # Translate column names.
    translations = dict()
    translations["metabolonID"] = "identifier"
    translations["metabolonDescription"] = "name"
    table_names.rename(
        columns=translations,
        inplace=True,
    )
    # Determine whether metabolite has a valid identity.
    table_names["identity"] = table_names.apply(
        lambda row:
            determine_metabolite_valid_identity(
                name=row["name"],
            ),
        axis="columns", # apply across rows
    )
    # Select metabolites with valid identities.
    table_identity = table_names.loc[
        (table_names["identity"] > 0.5), :
    ]
    metabolites_identity = table_identity["identifier"].to_list()
    names_identity = table_identity["name"].to_list()
    # Organize table.
    table_names["identifier"].astype("string")
    table_names.set_index(
        "identifier",
        drop=True,
        inplace=True,
    )
    # Remove table columns for metabolites with null genetic scores.
    table_scores.dropna(
        axis="columns",
        how="all",
        subset=None,
        inplace=True,
    )
    # Select metabolites with valid identities and valid genetic scores.
    metabolites_scores = table_scores.columns.to_list()
    metabolites_valid = utility.filter_common_elements(
        list_minor=metabolites_identity,
        list_major=metabolites_scores,
    )
    # Compile information.
    pail = dict()
    pail["table"] = table_names
    pail["metabolites_valid"] = metabolites_valid
    # Report.
    if report:
        # Column name translations.
        utility.print_terminal_partition(level=2)
        print("Report from select_metabolites_with_valid_identities()")
        utility.print_terminal_partition(level=3)
        print(
            "Count of identifiable metabolites: " +
            str(len(metabolites_identity))
        )
        print(
            "Count of identifiable metabolites with scores: " +
            str(len(metabolites_valid))
        )
        utility.print_terminal_partition(level=3)
        print(table_names)
    # Return information.
    return pail


##########
# Write


def write_product_raw(
    information=None,
    path_parent=None,
):
    """
    Writes product information to file.

    arguments:
        information (object): information to write to file
        path_parent (str): path to parent directory
            raises:

    returns:

    """

    # Specify directories and files.
    path_table_ukb_41826_text = os.path.join(
        path_parent, "table_ukb_41826.tsv"
    )
    # Write information to file.
    information["table_ukb_41826"].to_csv(
        path_or_buf=path_table_ukb_41826_text,
        sep="\t",
        header=True,
        index=True,
    )
    pass


def write_product_inspection(
    information=None,
    path_parent=None,
):
    """
    Writes product information to file.

    arguments:
        information (object): information to write to file
        path_parent (str): path to parent directory
            raises:

    returns:

    """

    # Specify directories and files.
    path_table_text = os.path.join(
        path_parent, "table_phenotypes.tsv"
    )
    # Write information to file.
    information["table_phenotypes"].to_csv(
        path_or_buf=path_table_text,
        sep="\t",
        header=True,
        index=True,
    )
    pass


def write_product_assembly(
    information=None,
    path_parent=None,
):
    """
    Writes product information to file.

    arguments:
        information (object): information to write to file
        path_parent (str): path to parent directory
            raises:

    returns:

    """

    # Specify directories and files.
    path_table_phenotypes = os.path.join(
        path_parent, "table_phenotypes.pickle"
    )
    path_table_phenotypes_text = os.path.join(
        path_parent, "table_phenotypes.tsv"
    )
    # Write information to file.
    information["table_phenotypes"].to_pickle(
        path_table_phenotypes
    )
    information["table_phenotypes"].to_csv(
        path_or_buf=path_table_phenotypes_text,
        sep="\t",
        header=True,
        index=True,
    )
    pass


def write_product(
    information=None,
    paths=None,
):
    """
    Writes product information to file.

    arguments:
        information (object): information to write to file
        paths (dict<str>): collection of paths to directories for procedure's
            files

    raises:

    returns:

    """

    write_product_raw(
        information=information["raw"],
        path_parent=paths["raw"],
    )
    write_product_inspection(
        information=information["inspection"],
        path_parent=paths["inspection"],
    )
    write_product_assembly(
        information=information["assembly"],
        path_parent=paths["assembly"],
    )
    pass

###############################################################################
# Procedure


def execute_procedure(
    path_dock=None,
):
    """
    Function to execute module's main behavior.

    arguments:
        path_dock (str): path to dock directory for source and product
            directories and files

    raises:

    returns:

    """

    utility.print_terminal_partition(level=1)
    print(path_dock)
    print("version check: 3")

    # TODO: steps to complete here...
    # 1. write script to move metabolite GEM PRSs to a new directory in "dock"
    # 2. read all contents of the PRSice output directory (need to move to "dock" first)
    # 3. filter to keep only the relevant files... probably on basis of file suffixes
    # 4. iterate on the files in the directory...
    # --- collect information for each metabolite during iteration (sort of a collection)
    # 5. for each metabolite, read PRS table in Pandas, specifying gzip compression
    # 6. calculate PRS-PCA by modification of Coombes' method
    # 7. keep PC1 and collect within a dataframe for all metabolites

    # Initialize directories.
    paths = initialize_directories(
        restore=True,
        path_dock=path_dock,
    )
    # Read source information from file.
    # Exclusion identifiers are "eid".
    source = read_source(
        path_dock=path_dock,
        report=True,
    )

    # Collect information.
    information = dict()
    # Write product information to file.
    write_product(
        paths=paths,
        information=information
    )
    pass



if (__name__ == "__main__"):
    execute_procedure()
