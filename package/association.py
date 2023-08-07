
"""
...

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
import time

# Relevant

import numpy
import scipy.stats
import pandas
pandas.options.mode.chained_assignment = None # default = "warn"
import statsmodels.api
import statsmodels.stats.outliers_influence

# Custom
import partner.utility as utility
import uk_biobank.assembly
import uk_biobank.organization

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
    paths["association"] = os.path.join(path_dock, "association")
    # Remove previous files to avoid version or batch confusion.
    if restore:
        utility.remove_directory(path=paths["association"])
    # Initialize directories.
    utility.create_directories(
        path=paths["association"]
    )
    # Return information.
    return paths


##########
# Read

# TODO: vary the PRS p-value threshold for the metabolites' genetic scores...
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
    path_table_phenotypes = os.path.join(
        path_dock, "organization", "table_phenotypes.pickle"
    )
    path_table_metabolites_names = os.path.join(
        path_dock, "organization", "table_metabolites_names.pickle"
    )
    path_metabolites_valid = os.path.join(
        path_dock, "organization", "metabolites_valid.pickle"
    )

    ##################################3
    path_table_metabolites_scores = os.path.join(
        path_dock, "aggregation", "selection",
        "table_metabolites_scores_prs_0_0001.pickle"
    )
    utility.print_terminal_partition(level=1)
    print("PRS pvalue: 0.0001")
    utility.print_terminal_partition(level=2)
    # Pause procedure.
    time.sleep(5.0)
    ##############################################

    # Read information from file.
    table_phenotypes = pandas.read_pickle(
        path_table_phenotypes
    )
    table_metabolites_scores = pandas.read_pickle(
        path_table_metabolites_scores
    )
    table_metabolites_names = pandas.read_pickle(
        path_table_metabolites_names
    )
    with open(path_metabolites_valid, "rb") as file_source:
        metabolites_valid = pickle.load(file_source)
    # Compile and return information.
    return {
        "table_phenotypes": table_phenotypes,
        "table_metabolites_scores": table_metabolites_scores,
        "table_metabolites_names": table_metabolites_names,
        "metabolites_valid": metabolites_valid,
    }


##########
# Iterate on metabolites...


def select_columns_merge_metabolite_phenotype_tables(
    phenotype=None,
    metabolite=None,
    metabolite_variables=None,
    metabolite_columns=None,
    metabolite_translations=None,
    covariates=None,
    table_metabolites_scores=None,
    table_phenotypes=None,
    report=None,
):
    """
    Merges and organizes information from metabolite and phenotype tables.

    arguments:
        phenotype (str): name of column in phenotype table for variable to set
            as dependent variable in regressions
        metabolite (str): identifiers of a single metabolite for which to
            regress genetic scores against phenotypes across UK Biobank
        metabolite_variables (list<str>): names of original columns in
            metabolite table for variables that represent the metabolite to
            include as independent variables in regression
        metabolite_columns (list<str>): names of novel columns in merge table
            for variables that represent the metabolite to include as
            independent variables in regression
        metabolite_translations (dict<str>): translations of original to novel
            columns that represent the metabolite
        covariates (list<str>): names of columns in phenotype table for
            variables to set as covariate independent variables in regressions
        table_metabolites_scores (object): Pandas data frame of metabolites'
            genetic scores across UK Biobank cohort
        table_phenotypes (object): Pandas data frame of phenotype variables
            across UK Biobank cohort
        report (bool): whether to print reports

    raises:

    returns:
        (object): Pandas data frame of dependent and independent variables for
            regression

    """

    # Copy information.
    table_metabolites_scores = table_metabolites_scores.copy(deep=True)
    table_phenotypes = table_phenotypes.copy(deep=True)
    # Rename columns in metabolites table.
    table_metabolites_scores.reset_index(
        level=None,
        inplace=True
    )
    table_metabolites_scores.rename(
        columns=metabolite_translations,
        inplace=True,
    )
    # Select relevant columns from metabolites table.
    columns_metabolites = list()
    columns_metabolites.append("IID")
    columns_metabolites.extend(metabolite_columns)
    table_metabolites_scores.reset_index(
        level=None,
        inplace=True
    )
    table_metabolites_scores = table_metabolites_scores.loc[
        :, table_metabolites_scores.columns.isin(columns_metabolites)
    ]
    # Select relevant columns from phenotypes table.
    columns_phenotypes = list()
    columns_phenotypes.extend(["eid", "IID"])
    columns_phenotypes.append(phenotype)
    columns_phenotypes.extend(covariates)
    table_phenotypes.reset_index(
        level=None,
        inplace=True
    )
    table_phenotypes = table_phenotypes.loc[
        :, table_phenotypes.columns.isin(columns_phenotypes)
    ]
    # Drop any rows with null keys.
    table_metabolites_scores.dropna(
        axis="index",
        how="any",
        subset=["IID"],
        inplace=True,
    )
    table_phenotypes.dropna(
        axis="index",
        how="any",
        subset=["IID"],
        inplace=True,
    )
    # Set keys as indices.
    table_metabolites_scores["IID"].astype("string")
    table_metabolites_scores.set_index(
        "IID",
        drop=True,
        inplace=True,
    )
    table_phenotypes["IID"].astype("string")
    table_phenotypes.set_index(
        "IID",
        drop=True,
        inplace=True,
    )
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print(
            "Report source: select_columns_merge_metabolite_phenotype_tables()"
        )
        utility.print_terminal_partition(level=3)
        print("Tables before merge:")
        print(table_phenotypes)
        print(table_metabolites_scores)
        pass
    # Merge tables using database-style join.
    # Alternative is to use DataFrame.join().
    table_merge = table_phenotypes.merge(
        table_metabolites_scores,
        how="outer",
        left_on="IID",
        #left_index=True,
        right_on="IID",
        #right_index=True,
        suffixes=("_phenotypes", "_metabolites"),
    )
    # Organize new index.
    table_merge.reset_index(
        level=None,
        inplace=True
    )
    table_merge.drop(
        labels=["IID",],
        axis="columns",
        inplace=True
    )
    table_merge.dropna(
        axis="index",
        how="any",
        subset=["eid"],
        inplace=True,
    )
    table_merge["eid"].astype("string")
    table_merge.set_index(
        "eid",
        drop=True,
        inplace=True,
    )
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print(
            "Report source: select_columns_merge_metabolite_phenotype_tables()"
        )
        utility.print_terminal_partition(level=3)
        print("Table after merge:")
        print(table_merge)
        pass
    # Return information.
    return table_merge


def remove_null_records_standardize_variables_scales(
    table=None,
    report=None,
):
    """
    Removes records with null values and standardizes variables' scales.

    arguments:
        table (object): Pandas data frame of dependent and independent variables
            for regression
        report (bool): whether to print reports

    raises:

    returns:
        (object): Pandas data frame of dependent and independent variables for
            regression

    """

    # Copy information.
    table = table.copy(deep=True)
    # Drop any rows with null keys.
    table.dropna(
        axis="index",
        how="any",
        subset=None,
        inplace=True,
    )
    # Standardize variables' scales.
    table_scale = utility.standardize_table_values_by_column(
        table=table,
        report=report,
    )
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print(
            "Report source: remove_null_records_standardize_variables_scales()"
        )
        utility.print_terminal_partition(level=3)
        print("Table after removal of records with null values...")
        print("... and after standardizing scale of each variable:")
        print(table_scale)
        pass
    # Return information.
    return table_scale


def organize_dependent_independent_variables_table(
    phenotype=None,
    metabolite=None,
    metabolite_variables=None,
    metabolite_columns=None,
    metabolite_translations=None,
    covariates=None,
    table_metabolites_scores=None,
    table_phenotypes=None,
    report=None,
):
    """
    Organizes information and regresses metabolites' genetic scores against
    phenotypes across the UK Biobank.

    Metabolites' genetic scores match to persons in the UK Biobank by the "IID"
    for their genotypic information.

    arguments:
        phenotype (str): name of column in phenotype table for variable to set
            as dependent variable in regressions
        metabolite (str): identifiers of a single metabolite for which to
            regress genetic scores against phenotypes across UK Biobank
        metabolite_variables (list<str>): names of original columns in
            metabolite table for variables that represent the metabolite to
            include as independent variables in regression
        metabolite_columns (list<str>): names of novel columns in merge table
            for variables that represent the metabolite to include as
            independent variables in regression
        metabolite_translations (dict<str>): translations of original to novel
            columns that represent the metabolite
        covariates (list<str>): names of columns in phenotype table for
            variables to set as covariate independent variables in regressions
        table_metabolites_scores (object): Pandas data frame of metabolites'
            genetic scores across UK Biobank cohort
        table_phenotypes (object): Pandas data frame of phenotype variables
            across UK Biobank cohort
        report (bool): whether to print reports

    raises:

    returns:
        (object): Pandas data frame of dependent and independent variables for
            regression

    """

    # Select relevant columns and merge tables.
    table_merge = select_columns_merge_metabolite_phenotype_tables(
        phenotype=phenotype,
        metabolite=metabolite,
        metabolite_variables=metabolite_variables,
        metabolite_columns=metabolite_columns,
        metabolite_translations=metabolite_translations,
        covariates=covariates,
        table_metabolites_scores=table_metabolites_scores,
        table_phenotypes=table_phenotypes,
        report=report,
    )
    # Drop records with null values.
    # Standardize scale of variables.
    table_scale = remove_null_records_standardize_variables_scales(
        table=table_merge,
        report=report,
    )
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print("Report source: organize_dependent_independent_variables_table()")
        print("Table ready for regression...")
        print(table_scale)
        pass
    # Return.
    return table_scale


def organize_regress_phenotype_against_metabolite_genetic_scores(
    phenotype=None,
    metabolite=None,
    metabolite_variables=None,
    metabolites=None,
    covariates=None,
    table_metabolites_scores=None,
    table_phenotypes=None,
    regression=None,
    report=None,
):
    """
    Organizes information and regresses metabolites' genetic scores against
    phenotypes across the UK Biobank.

    Metabolites' genetic scores match to persons in the UK Biobank by the "IID"
    for their genotypic information.

    arguments:
        phenotype (str): name of column in phenotype table for variable to set
            as dependent variable in regressions
        metabolite (str): identifier of a single metabolite for which to
            regress genetic scores against phenotypes across UK Biobank
        metabolite_variables (list<str>): names of columns in metabolite table
            for variables that represent the metabolite to include as
            independent variables in regression
        metabolites (list<str>): identifiers of metabolites for which to regress
            their genetic scores against phenotypes across UK Biobank
        covariates (list<str>): names of columns in phenotype table for
            variables to set as covariate independent variables in regressions
        table_metabolites_scores (object): Pandas data frame of metabolites'
            genetic scores across UK Biobank cohort
        table_phenotypes (object): Pandas data frame of phenotype variables
            across UK Biobank cohort
        regression (str): type of regression, "linear" or "logistic"
        report (bool): whether to print reports

    raises:

    returns:
        (dict): information from regression

    """

    # Determine translations for columns of metabolite variables.
    # Rename columns in metabolites table.
    metabolite_columns = list()
    metabolite_translations = dict()
    metabolite_translations["identifier_ukb"] = "IID"
    for variable in metabolite_variables:
        translation = str(variable).replace(metabolite, "metabolite")
        metabolite_columns.append(translation)
        metabolite_translations[variable] = translation
    # Organize information for regression.
    table_organization = organize_dependent_independent_variables_table(
        phenotype=phenotype,
        metabolite=metabolite,
        metabolite_variables=metabolite_variables,
        metabolite_columns=metabolite_columns,
        metabolite_translations=metabolite_translations,
        covariates=covariates,
        table_metabolites_scores=table_metabolites_scores,
        table_phenotypes=table_phenotypes,
        report=report,
    )

    # Regress dependent against independent variables.
    independence = list()
    independence.extend(metabolite_columns)
    independence.extend(covariates)
    pail_regression = regress_dependent_independent_variables_linear_ordinary(
        dependence=phenotype,
        independence=independence,
        threshold_samples=1000,
        table=table_organization,
        report=False,
    )
    # Compile information.
    pail = dict()
    pail["identifier"] = metabolite
    pail.update(pail_regression["summary"])
    # Return information.
    return pail


def organize_metabolites_regressions_summary_table(
    records=None,
    table_metabolites_names=None,
):
    """
    Organizes a table to summarize information about regressions.

    arguments:
        records (list<dict>): summary information about regressions
        table_metabolites_names (object): Pandas data frame of metabolites'
            identifiers and names

    raises:

    returns:
        (object): Pandas data frame of summary information about regressions

    """

    # Organize table.
    table = utility.convert_records_to_dataframe(
        records=records
    )
    # Introduce metabolites' names.
    # Merge tables using database-style join.
    # Alternative is to use DataFrame.join().
    table["identifier"].astype("string")
    table.set_index(
        "identifier",
        drop=True,
        inplace=True,
    )
    table_metabolites_names.reset_index(
        level=None,
        inplace=True
    )
    table_metabolites_names["identifier"].astype("string")
    table_metabolites_names.set_index(
        "identifier",
        drop=True,
        inplace=True,
    )
    table_merge = table.merge(
        table_metabolites_names,
        how="left",
        left_on="identifier",
        #left_index=True,
        right_on="identifier",
        #right_index=True,
        suffixes=("_summary", "_names"),
    )
    table_merge.reset_index(
        level=None,
        inplace=True
    )
    table_merge.set_index(
        "identifier",
        drop=True,
        inplace=True,
    )
    # Sort rows.
    table_merge.sort_values(
        by=["metabolite_probability", "r_square_adjust"],
        axis="index",
        ascending=True,
        inplace=True,
    )
    # Return.
    return table_merge


# Why not merge metabolite and phenotype tables all at once initially?
# Do not do this.
# Eventually, I want to accommodate multiple column variables for each metabolite.
def organize_regress_phenotype_against_metabolites_genetic_scores(
    phenotype=None,
    metabolites=None,
    covariates=None,
    table_phenotypes=None,
    table_metabolites_scores=None,
    table_metabolites_names=None,
    regression=None,
    report=None,
):
    """
    Organizes information and regresses metabolites' genetic scores against
    phenotypes across the UK Biobank.

    Metabolites' genetic scores match to persons in the UK Biobank by the "IID"
    for their genotypic information.

    arguments:
        phenotype (str): name of column in phenotype table for variable to set
            as dependent variable in regressions
        metabolites (list<str>): identifiers of metabolites for which to regress
            their genetic scores against phenotypes across UK Biobank
        covariates (list<str>): names of columns in phenotype table for
            variables to set as covariate independent variables in regressions
        table_phenotypes (object): Pandas data frame of phenotype variables
            across UK Biobank cohort
        table_metabolites_scores (object): Pandas data frame of metabolites'
            genetic scores across UK Biobank cohort
        table_metabolites_names (object): Pandas data frame of metabolites'
            identifiers and names from Metabolon
        regression (str): type of regression, "linear" or "logistic"
        report (bool): whether to print reports

    raises:

    returns:
        (dict): information from regressions

    """

    # Monitor progress.
    counter = 0
    count_total = len(metabolites)
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print(
            "organize_regress_metabolites_genetic_scores_against_phenotypes()"
        )
        print("Count of metabolites: " + str(count_total))
        utility.print_terminal_partition(level=2)
    # Collect information for metabolites.
    records = list()
    for metabolite in metabolites:
        # TODO: read in table of pre-selected variables for the metabolite...
        # TODO: in which case I'll also need to make the re-naming of the
        # TODO: columns a bit more sophisticated
        record = (
            organize_regress_phenotype_against_metabolite_genetic_scores(
                phenotype=phenotype,
                metabolite=metabolite,
                metabolite_variables=[metabolite],
                metabolites=metabolites,
                covariates=covariates,
                table_phenotypes=table_phenotypes,
                table_metabolites_scores=table_metabolites_scores,
                regression=regression,
                report=False,
        ))
        records.append(record)
        # Monitor progress.
        counter += 1
        percentage = (counter / count_total) * 100
        # Report.
        if (((percentage % 10) < 1) and report):
            utility.print_terminal_partition(level=4)
            print("complete cases: " + str(round(percentage)) + "%")
            pass
        pass
    # Organize information in a table.
    table_regression = organize_metabolites_regressions_summary_table(
        records=records,
        table_metabolites_names=table_metabolites_names,
    )
    # Organize information for report.
    table_report = table_regression.copy(deep=True)
    columns_report = [
        "name",
        "metabolite_parameter", "metabolite_inflation",
        "metabolite_probability", "samples",
        "r_square", "r_square_adjust", "condition",
    ]
    table_report = table_report.loc[
        :, table_report.columns.isin(columns_report)
    ]
    table_report = table_report[[*columns_report]]
    # Report.
    if report:
        utility.print_terminal_partition(level=2)
        print("Summary of metabolite regressions: ")
        print(table_report)
    # Compile information.
    pail = dict()
    pail["table"] = table_regression
    pail["table_report"] = table_report
    # Return.
    return pail


##########
# Write


def write_product(
    phenotype=None,
    information=None,
    paths=None,
):
    """
    Writes product information to file.

    arguments:
        phenotype (str): name of phenotype as dependent variable in regressions
        information (object): information to write to file
        paths (dict<str>): collection of paths to directories for procedure's
            files

    returns:

    """

    # Specify directories and files.
    path_table = os.path.join(
        paths["association"], str("table_" + str(phenotype) + ".tsv")
    )
    path_table_report = os.path.join(
        paths["association"], str("table_report_" + str(phenotype) + ".tsv")
    )
    # Write information to file.
    information["table"].to_csv(
        path_or_buf=path_table,
        sep="\t",
        header=True,
        index=True,
    )
    information["table_report"].to_csv(
        path_or_buf=path_table_report,
        sep="\t",
        header=True,
        index=True,
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
    print("version check: 1")
    # Pause procedure.
    time.sleep(5.0)

    # Initialize directories.
    paths = initialize_directories(
        restore=False,
        path_dock=path_dock,
    )
    # Read source information from file.
    # Exclusion identifiers are "eid".
    source = read_source(
        path_dock=path_dock,
        report=True,
    )
    print(source["table_metabolites_scores"])
    print(source["table_phenotypes"])
    # Regress associations between metabolites' genetic scores and phenotypes
    # accross the UK Biobank.
    # M00599: pyruvate
    # M32315: serine
    # M02342: serotonin
    # M00054: tryptophan
    #metabolites = ["M00599", "M32315", "M02342", "M00054"]
    metabolites = copy.deepcopy(source["metabolites_valid"])
    # "body_mass_index", "testosterone", "oestradiol", "steroid_globulin",
    # "albumin", "audit_c",
    phenotype="neuroticism_log"
    covariates=[
        "sex", "age", "body_mass_index_log",
        "genotype_pc_1", "genotype_pc_2", "genotype_pc_3",
        "genotype_pc_4", "genotype_pc_5", "genotype_pc_6",
        "genotype_pc_7", "genotype_pc_8", "genotype_pc_9",
        "genotype_pc_10",
    ]
    pail_association = (
        organize_regress_phenotype_against_metabolites_genetic_scores(
            phenotype=phenotype,
            metabolites=metabolites,
            covariates=covariates,
            table_phenotypes=source["table_phenotypes"],
            table_metabolites_scores=source["table_metabolites_scores"],
            table_metabolites_names=source["table_metabolites_names"],
            regression="linear", # "linear" or "logistic"
            report=True,
    ))

    # TODO: implement low-throughput test for R^2-adjust attributable to metabolites
    # TODO: of interest...
    # TODO: R^2-adjust for models with and without the metabolite of interest

    if False:
        # Attribute regression model variance to specific metabolites of special
        # interest.
        metabolites_attribution = ["M00599", "M32315", "M02342", "M00054"]
        pail_attribution = (
            organize_regress_model_r_square_attribution_with_without_variables(
                phenotype=phenotype,
                variables_attribution=metabolites_attribution,
                covariates=covariates,
                table_phenotypes=source["table_phenotypes"],
                table_metabolites_scores=source["table_metabolites_scores"],
                table_metabolites_names=source["table_metabolites_names"],
                regression="linear", # "linear" or "logistic"
                report=True,
            )
        )

    # Collect information.
    information = dict()
    information["table"] = pail_association["table"]
    information["table_report"] = pail_association["table_report"]
    # Write product information to file.
    write_product(
        phenotype=phenotype,
        information=information,
        paths=paths,
    )
    pass


if (__name__ == "__main__"):
    execute_procedure()
