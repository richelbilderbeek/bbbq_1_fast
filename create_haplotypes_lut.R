# Creates the 'haplotypes_lut.csv' file, which maps a haplotype to its ID
#
# Usage:
#
#   Rscript create_haplotypes.R
#
# Usage, for only 4 haplotypes:
#
#   Rscript create_haplotypes.R test

target_filename <- "haplotypes_lut.csv"
message("'target_filename': ", target_filename)

t <- bbbq::create_haplotypes_lut()

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 1 && args[1] == "test") {
  t <- t[c(1, 2, 20, 21), ]
}

readr::write_csv(t, target_filename)

testthat::expect_true(file.exists(target_filename))
