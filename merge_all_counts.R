# Merge all counts

targets <- c("covid", "human", "myco")
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

# All little tibbles
tibbles <- list()
tibble_index <- 1

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
      if (!file.exists(target_filename)) {
        # message("Filename '", target_filename, "' absent. Ignore")
        next()
      }
      t <- readr::read_csv(
        target_filename,
        col_types = readr::cols(
          haplotype_id = readr::col_character(),
          protein_id = readr::col_character(),
          n_binders = readr::col_double(),
          n_binders_tmh = readr::col_double(),
          n_spots = readr::col_double(),
          n_spots_tmh = readr::col_double()
        )
      )
      t$target <- target
      t <- dplyr::relocate(t, target)
      tibbles[[tibble_index]] <- t
      tibble_index <- tibble_index + 1
    }
  }
}

t <- dplyr::bind_rows(tibbles)
readr::write_csv(t, "counts.csv")
