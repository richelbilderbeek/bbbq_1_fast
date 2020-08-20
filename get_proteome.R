# Get a proteome for a target.
#
# If the proteome is already present, this script will do nothing.
# The script will first try to download from Uniprot.
# If that fails, a fallback location is used.
#
# Usage:
#
#   Rscript get_proteome.R [target]
#
# * [target]: either 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript get_proteome.R covid
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
target_filename <- paste0(target_name, ".fasta")
message("target_filename: '", target_filename, "'")
if (file.exists(target_filename)) {
  message("target_filename already exists")
  q()
}

if (target_name == "test_covid") {
  file.copy(
    from = bbbq::get_test_covid_proteome_filename(),
    to = "covid.fasta"
  )
  q()
} else if (target_name == "test_human") {
  file.copy(
    from = bbbq::get_test_human_proteome_filename(),
    to = "human.fasta"
  )
  q()
} else if (target_name == "test_myco") {
  file.copy(
    from = bbbq::get_test_myco_proteome_filename(),
    to = "myco.fasta"
  )
  q()
}


uniprot_id <- NA

if (target_name == "covid") {
  uniprot_id <- "UP000464024"
} else if (target_name == "human") {
  uniprot_id <- "UP000005640"
} else if (target_name == "myco") {
  uniprot_id <- "UP000001584"
} else {
  stop("Unknown target '", target, "'")
}


tryCatch({
  UniprotR:::GetProteomeFasta(ProteomeID = uniprot_id, directorypath = getwd())
  downloaded_filename <- paste0(uniprot_id, ".fasta")
  testthat::expect_true(file.exists(downloaded_filename))
  file.rename(from = downloaded_filename, to = target_filename)
}, error = function(e) {} # nolint no worries
)
if (!file.exists(target_filename)) {
  message("Download from Uniprot failed, use fallback download location")
  url <- paste0("https://www.richelbilderbeek.nl/", uniprot_id, ".fasta")
  download.file(url, target_filename)
}

testthat::expect_true(file.exists(target_filename))
