# Create the 'general.csv' file, containing general info
targets <- c("covid", "flua", "hepa", "hiv", "human", "myco", "polio", "rhino")

t_general <- tibble::tibble(
  target = targets,
  english_name = NA,
  n_tmh_tmhmm = seq(1,8),
  n_tmh_pureseqtm = seq(1,8),
  n_aas = seq(1000, 8000,by = 1000)
)

# Names
t_general$english_name[t_general$target == "covid"] <- "SARS-CoV-2"
t_general$english_name[t_general$target == "flua"] <- "Influenza A"
t_general$english_name[t_general$target == "hepa"] <- "Hepatitus A"
t_general$english_name[t_general$target == "hiv"] <- "HIV"
t_general$english_name[t_general$target == "human"] <- "Human"
t_general$english_name[t_general$target == "myco"] <- "MTb"
t_general$english_name[t_general$target == "polio"] <- "Polio"
t_general$english_name[t_general$target == "rhino"] <- "Rhinovirus"

# Number of AAs
for (i in seq_len(nrow(t_general))) {
  filename <- paste0(t_general$target[i], ".fasta")
  testthat::expect_true(file.exists(filename))
  t_general$n_aas[i] <- sum(
    stringr::str_length(
      stringr::str_subset(readr::read_lines(filename), pattern = "^\\>", negate = TRUE)
    )
  )
}

shortest_index <- which(t_general$n_aas == min(t_general$n_aas))

# Number of TMHs according to PureseqTM
for (i in seq_len(nrow(t_general))) {
  i <- shortest_index
  filename <- paste0(t_general$target[i], ".fasta")
  topology <- pureseqtmr::predict_topology(fasta_filename = filename)
  t_tmhs <- pureseqtmr::tally_tmhs(topology)
  t_general$n_tmh_pureseqtm[i] <- sum(t_tmhs$n_tmhs)
}

# Number of TMHs according to TMHMM
for (i in seq_len(nrow(t_general))) {
  i <- shortest_index
  filename <- paste0(t_general$target[i], ".fasta")
  tmhmm_result <- tmhmm::run_tmhmm(fasta_filename = filename)
  df_tmhmm <- tmhmm::locatome_to_df(tmhmm_result)
  t_general$n_tmh_tmhmm[i] <- sum(tmhmm::tally_tmhs(df_tmhmm)$n_tmhs)
}

readr::write_csv(t_general, path = "general.csv")