# Create all counts
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  targets <- c("covid", "human", "myco")
} else {
  targets <- args
}

haplotype_lut_filename <- "haplotypes_lut.csv"
protein_lut_filenames <- paste0(targets, "_proteins_lut.csv")
testthat::expect_true(file.exists(haplotype_lut_filename))
testthat::expect_true(all(file.exists(protein_lut_filenames)))

t_haplotype_lut <- readr::read_csv(
  haplotype_lut_filename,
  col_types = readr::cols(
    haplotype = readr::col_character(),
    mhc_class = readr::col_double(),
    haplotype_id = readr::col_character()
  )
)

call_cmd <- NA
if (peregrine::is_on_peregrine()) {
  call_cmd <- c("sbatch", "run_r_script.sh")
} else {
  call_cmd <- "Rscript"
}

for (i in seq_along(targets)) {
  target <- targets[i]
  protein_lut_filename <- protein_lut_filenames[i]

  t_protein_lut <- readr::read_csv(
    protein_lut_filename,
    col_types = readr::cols(
      protein_id = readr::col_character(),
      protein = readr::col_character(),
      sequence = readr::col_character()
    )
  )

  for (protein_id in t_protein_lut$protein_id) {
    for (haplotype_id in t_haplotype_lut$haplotype_id) {

      target_filename <- paste0(
        target, "_", haplotype_id, "_", protein_id, "_counts.csv"
      )
      if (file.exists(target_filename)) {
        # message("Filename '", target_filename, "' already exists. Skip")
        next()
      }
      cmds <- c(call_cmd, "create_counts.R", target, haplotype_id, protein_id)
      message(
        "Creating filename '", target_filename, "' with: ",
        paste0(cmds, " ")
      )
      try({
          system2(command = cmds[1], args = cmds[-1])
        }
      )
      while (peregrine::count_jobs() > 950) {
        Sys.sleep(60)
      }
      Sys.sleep(0.5)
    }
  }

}

### `[target]_[haplotype_id]_[protein_id]_counts.csv`
