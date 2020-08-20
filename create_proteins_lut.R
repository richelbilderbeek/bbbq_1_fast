# Get the proteine IDs for a target
#
# Usage:
#
#   Rscript get_proteins.R [target]
#
# * [target]: either 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript get_proteins covid
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  args <- "covid"
}
testthat::expect_equal(length(args), 1)
message("Running with argument '", args[1], "''")

target_name <- args[1]

message("target_name: '", target_name, "'")

proteome_filename <- paste0(target_name, ".fasta")
message("proteome_filename: '", proteome_filename, "'")
testthat::expect_true(file.exists(proteome_filename))

target_filename <- paste0(target_name, "_proteins_lut.csv")
message("target_filename: '", target_filename, "'")

t <- bbbq::create_proteins_lut(proteome_filename)

readr::write_csv(t, target_filename)
testthat::expect_true(file.exists(target_filename))
