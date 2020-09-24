# Create the 'general.csv' file, containing general info
targets <- bbbq::get_target_names()

t_general <- tibble::tibble(
  target = targets,
  english_name = NA,
  n_tmh_tmhmm = seq(1,8),
  n_tmh_pureseqtm = seq(1,8),
  n_aas_tmh_tmhmm = seq(1,8),
  n_aas_tmh_pureseqtm = seq(1,8),
  n_aas_non_tmh_tmhmm = seq(1,8),
  n_aas_non_tmh_pureseqtm = seq(1,8),
  n_aas = seq(1000, 8000,by = 1000)
)

# Names
for (i in seq_len(nrow(t_general))) {
  t_general$english_name[i] <- bbbq::get_target_english_name(t_general$target[i])
}

# Number of AAs
for (i in seq_len(nrow(t_general))) {
  filename <- paste0(t_general$target[i], ".fasta")
  testthat::expect_true(file.exists(filename))
  # Sum the non-protein lines
  t_general$n_aas[i] <- sum(
    stringr::str_length(
      stringr::str_subset(
        readr::read_lines(filename),
        pattern = "^\\>",
        negate = TRUE
      )
    )
  )
}

shortest_index <- which(t_general$n_aas == min(t_general$n_aas))

# Number of TMHs according to PureseqTM
for (i in seq_len(nrow(t_general))) {
  filename <- paste0(t_general$target[i], ".fasta")
  topology <- pureseqtmr::predict_topology(fasta_filename = filename)
  t_general$n_aas_tmh_pureseqtm[i] <- sum(
    stringr::str_count(topology$topology, "1")
  )
  t_general$n_aas_non_tmh_pureseqtm[i] <- sum(
    stringr::str_count(topology$topology, "0")
  )
  t_tmhs <- pureseqtmr::tally_tmhs(topology)
  t_general$n_tmh_pureseqtm[i] <- sum(t_tmhs$n_tmhs)
}

# Number of TMHs according to TMHMM
for (i in seq_len(nrow(t_general))) {
  filename <- paste0(t_general$target[i], ".fasta")
  tmhmm_result <- tmhmm::run_tmhmm(fasta_filename = filename)
  df_tmhmm <- tmhmm::locatome_to_df(tmhmm_result)
  t_general$n_aas_tmh_tmhmm[i] <- sum(
    stringr::str_count(topology$topology, "1")
  )
  t_general$n_aas_non_tmh_tmhmm[i] <- sum(
    stringr::str_count(topology$topology, "0")
  )
  t_general$n_tmh_tmhmm[i] <- sum(tmhmm::tally_tmhs(df_tmhmm)$n_tmhs)
}

readr::write_csv(t_general, path = "general.csv")
