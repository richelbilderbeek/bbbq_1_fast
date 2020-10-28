# Create the topology for a target
#
# Usage:
#
#   Rscript create_counts_per_proteome.R [target] [haplotype id] [percentage]
#
# * [target]: a target such as 'covid', 'human', 'myco'
# * [haplotype id]: a haplotype ID such as 'h1', 'h2'
# * [percentage]: a pecentage such as '2' (for 0.02).
#                 Use percentages for filenames
#
# For example:
#
#   Rscript create_counts_per_proteome.R covid h1 5
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) stop("")

if (1 == 2) {
  args <- c("covid", "h1", 5)
  args <- c("human", "h14", 5)
  args <- c("human", "h20", 5)
}
target <- args[1]
haplotype_id <- args[2]
percentage <- args[3]

message("target: ", target)
message("haplotype_id: ", haplotype_id)
message("percentage: ", percentage)

percentile <- percentage / 100.0
message("percentile: ", percentile)


haplotype_lut_filename <- "haplotypes_lut.csv"
testthat::expect_true(file.exists(haplotype_lut_filename))

protein_lut_filename <- paste0(target, "_proteins_lut.csv")
testthat::expect_true(file.exists(protein_lut_filename))

target_filename <- paste0(
  target, "_", haplotype_id, "_", percentage, "_counts.csv"
)
message("target_filename: ", target_filename)

# Look up peptide
t_protein_lut <- readr::read_csv(
  protein_lut_filename,
  col_types = readr::cols(
    protein_id = readr::col_character(),
    protein = readr::col_character(),
    sequence = readr::col_character()
  )
)
protein_sequences <- t_protein_lut$sequence


# Look up haplotype
t_haplotype_lut <- readr::read_csv(
  haplotype_lut_filename,
  col_types = readr::cols(
    haplotype = readr::col_character(),
    mhc_class = readr::col_double(),
    haplotype_id = readr::col_character()
  )
)

if (!haplotype_id %in% t_haplotype_lut$haplotype_id) {
  stop(
    "Unknown haplotope_id: '", haplotype_id, "'. ",
    "Available IDs: ", paste0(t_haplotype_lut$haplotype_id, collapse = ", ")
  )
}
testthat::expect_true(haplotype_id %in% t_haplotype_lut$haplotype_id)

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
if (pureseqtmr::is_on_ci()) {
  if (ic50_prediction_tool == "netmhc2pan") {
    ic50_prediction_tool <- "mhcnuggetsr"
  }
}

message("ic50_prediction_tool: ", ic50_prediction_tool)

t <- bbbq::predict_counts_per_proteome(
  protein_sequences = protein_sequences,
  haplotype = haplotype,
  peptide_length = peptide_length,
  percentile = percentile,
  verbose = FALSE,
  ic50_prediction_tool = ic50_prediction_tool
)
t$protein_id <- t_protein_lut$protein_id
t <- dplyr::relocate(t, protein_id)
t$haplotype_id <- haplotype_id
t <- dplyr::relocate(t, haplotype_id)

readr::write_csv(t, target_filename)
