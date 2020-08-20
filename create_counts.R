# Create the topology for a target
#
# Usage:
#
#   Rscript create_topology.R [target]
#
# * [target]: either 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript create_topology.R covid
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
  args <- c("covid", "h1", "p1")
}
target <- args[1]
haplotype_id <- args[2]
protein_id <- args[3]

haplotype_lut_filename <- "haplotypes_lut.csv"
testthat::expect_true(file.exists(haplotype_lut_filename))

protein_lut_filename <- paste0(target, "_proteins_lut.csv")
testthat::expect_true(file.exists(protein_lut_filename))

target_filename <- paste0(
  target, "_", haplotype_id, "_", protein_id, "_counts.csv"
)

# Look up peptide
t_protein_lut <- readr::read_csv(
  protein_lut_filename,
  col_types = readr::cols(
    protein_id = readr::col_character(),
    protein = readr::col_character(),
    sequence = readr::col_character()
  )
)
peptide <- t_protein_lut$sequence[t_protein_lut$protein_id == protein_id]

# Look up haplotype
t_haplotype_lut <- readr::read_csv(
  haplotype_lut_filename,
  col_types = readr::cols(
    haplotype = readr::col_character(),
    mhc_class = readr::col_double(),
    haplotype_id = readr::col_character()
  )
)
haplotype <- t_haplotype_lut$haplotype[t_haplotype_lut$haplotype_id == haplotype_id]
message("haplotype: ", haplotype)
mhc_class <- t_haplotype_lut$mhc_class[t_haplotype_lut$haplotype_id == haplotype_id]
message("mhc_class: ", mhc_class)
peptide_length <- bbbq::get_mhc_peptide_length(mhc_class)
message("peptide_length: ", peptide_length)

ic50_prediction_tool <- NA
if (mhc_class == 1) {
  ic50_prediction_tool <- "EpitopePrediction"
} else if (mhc_class == 2) {
  ic50_prediction_tool <- "netmhc2pan"
} else {
  stop("Unknown mhc_class: ", mhc_class)
}
message("ic50_prediction_tool: ", ic50_prediction_tool)

t <- bbbq::predict_counts(
  peptide = peptide,
  haplotype = haplotype,
  peptide_length = peptide_length,
  percentile = bbbq::get_ic50_percentile_binder(),
  verbose = TRUE,
  ic50_prediction_tool = ic50_prediction_tool
)
t$protein_id <- protein_id
t <- dplyr::relocate(t, protein_id)
t$haplotype_id <- haplotype_id
t <- dplyr::relocate(t, haplotype_id)

readr::write_csv(t, target_filename)
