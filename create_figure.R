# Creates a figure from 'table_1.csv' or 'table_2.csv'
# to show the measured the number of binders and the
# number of binders that are TMH
#
# Usage:
#
#  Rscript create_figure.R [MHC]
#
#  * [MHC] is either 'mhc1' or 'mhc2'
#
#
#
#
library(dplyr, warn.conflicts = FALSE)
library(testthat, warn.conflicts = FALSE)
library(ggplot2, quietly = TRUE)

args <- commandArgs(trailingOnly = TRUE)
if (1 == 2) {
  args <- "mhc1"
}
expect_equal(length(args), 1)
message("Running with argument '", args[1], "'")
mhc <- args[1]
message("mhc: '", mhc, "'")
expect_equal(4, stringr::str_length(mhc))
mhc_class <- stringr::str_sub(mhc, 4, 4)
message("mhc_class: '", mhc_class, "'")
the_mhc_class <- mhc_class
message("the_mhc_class: '", the_mhc_class, "'")

target_filename <- paste0("fig_f_tmh_mhc", mhc_class, ".png")
message("target_filename: '", target_filename, "'")
target_filename_grid <- paste0("fig_f_tmh_mhc", mhc_class, "_grid.png")
message("target_filename_grid: '", target_filename_grid, "'")
target_filename_normalized <- paste0("fig_f_tmh_mhc", mhc_class, "_normalized.png")
message("target_filename_normalized: '", target_filename_normalized, "'")

target_virus_only_filename <- paste0("fig_f_tmh_mhc", mhc_class, "_virus_only.png")
message("target_virus_only_filename: '", target_virus_only_filename, "'")
target_virus_only_filename_grid <- paste0("fig_f_tmh_mhc", mhc_class, "_grid_virus_only.png")
message("target_virus_only_filename_grid: '", target_virus_only_filename_grid, "'")
target_virus_only_filename_normalized <- paste0("fig_f_tmh_mhc", mhc_class, "_normalized_virus_only.png")
message("target_virus_only_filename_normalized: '", target_virus_only_filename_normalized, "'")

general_filename <- "general.csv"
message("general_filename: '", general_filename, "'")
testthat::expect_true(file.exists(general_filename))
t_general <- readr::read_csv(
  general_filename,
  col_types = readr::cols(
    target = readr::col_character(),
    english_name = readr::col_character(),
    n_tmh_tmhmm = readr::col_double(),
    n_tmh_pureseqtm = readr::col_double(),
    n_aas = readr::col_double()
  )
)

haplotype_lut_filename <- "haplotypes_lut.csv"
message("'haplotype_lut_filename': '", haplotype_lut_filename, "'")
testthat::expect_true(file.exists(haplotype_lut_filename))
t_haplotype_lut <- readr::read_csv(
  haplotype_lut_filename,
  col_types = readr::cols(
    haplotype = readr::col_character(),
    mhc_class = readr::col_double(),
    haplotype_id = readr::col_character()
  )
)
t_haplotype_lut$name <- mhcnuggetsr::to_mhcnuggets_names(t_haplotype_lut$haplotype)
# Only keep the desired MHC class
t_haplotype_lut <- t_haplotype_lut %>% filter(mhc_class == the_mhc_class)


table_filename <- "counts.csv"
message("table_filename: '", table_filename, "'")
testthat::expect_true(file.exists(table_filename))
t_tmh_binders_all <- readr::read_csv(
  table_filename,
  col_types = readr::cols(
    target = readr::col_character(),
    haplotype_id = readr::col_character(),
    protein_id = readr::col_character(),
    n_binders = readr::col_double(),
    n_binders_tmh = readr::col_double(),
    n_spots = readr::col_double(),
    n_spots_tmh = readr::col_double()
  )
)

# Only keep the desired MHC class
t_tmh_binders_mhc <- t_tmh_binders_all %>% filter(haplotype_id %in% t_haplotype_lut$haplotype_id)

# Group all proteins
t_tmh_binders <- t_tmh_binders_mhc %>% dplyr::group_by(target, haplotype_id) %>%
    dplyr::summarize(
      n_binders = sum(n_binders, na.rm = TRUE),
      n_binders_tmh = sum(n_binders_tmh, na.rm = TRUE),
      n_spots = sum(n_spots, na.rm = TRUE),
      n_spots_tmh = sum(n_spots_tmh, na.rm = TRUE),
      .groups = "keep"
    ) %>% dplyr::ungroup()


t_tmh_binders$f_tmh <- NA
t_tmh_binders$f_tmh <- t_tmh_binders$n_binders_tmh / t_tmh_binders$n_binders
t_tmh_binders$haplotype <- NA
for (i in seq_len(nrow(t_tmh_binders))) {
  id <- t_tmh_binders$haplotype_id[i]
  t_tmh_binders$haplotype[i] <- t_haplotype_lut$haplotype[t_haplotype_lut$haplotype_id == id]
}
t_tmh_binders$haplotype <- as.factor(t_tmh_binders$haplotype)

t_coincidence <- t_tmh_binders %>% dplyr::group_by(target) %>%
    dplyr::summarize(
      n_spots = mean(n_spots),
      n_spots_tmh = mean(n_spots_tmh),
      .groups = "keep"
    ) %>% dplyr::ungroup()
t_coincidence$f_tmh <- t_coincidence$n_spots_tmh / t_coincidence$n_spots

f_covid <- t_coincidence$f_tmh[t_coincidence$target == "covid"]
f_flua  <- t_coincidence$f_tmh[t_coincidence$target == "flua"]
f_hepa  <- t_coincidence$f_tmh[t_coincidence$target == "hepa"]
f_hiv   <- t_coincidence$f_tmh[t_coincidence$target == "hiv"]
f_human <- t_coincidence$f_tmh[t_coincidence$target == "human"]
f_myco  <- t_coincidence$f_tmh[t_coincidence$target == "myco"]
f_polio <- t_coincidence$f_tmh[t_coincidence$target == "polio"]
f_rhino <- t_coincidence$f_tmh[t_coincidence$target == "rhino"]

roman_mhc_class <- NA
if (mhc_class == 1) roman_mhc_class <- "I"
if (mhc_class == 2) roman_mhc_class <- "II"

caption_text <- paste0(
  "Horizontal lines: % ", bbbq::get_mhc_peptide_length(mhc_class) ,"-mers that overlaps with TMH in ",
  "SARS-Cov2 (",     formatC(100.0 * mean(f_covid), digits = 3),"%), ",
  "Influenza A (",   formatC(100.0 * mean(f_flua ), digits = 3),"%), ",
  "Hepatitus A (",   formatC(100.0 * mean(f_hepa ), digits = 3),"%), \n",
  "HIV (",           formatC(100.0 * mean(f_hiv  ), digits = 3),"%), ",
  "humans (",        formatC(100.0 * mean(f_human), digits = 3),"%), ",
  "Mycobacterium (", formatC(100.0 * mean(f_myco ), digits = 3),"%), ",
  "Polio (",         formatC(100.0 * mean(f_polio), digits = 3),"%), ",
  "Rhinovirus (",    formatC(100.0 * mean(f_rhino), digits = 3),"%)"
)
p <- ggplot(t_tmh_binders, aes(x = haplotype, y = f_tmh, fill = target)) +
  geom_col(position = position_dodge(), color = "#000000") +
  xlab(paste0("MHC-", roman_mhc_class, " HLA haplotype")) +
  ylab("Epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 2),
    breaks = seq(0.0, 1.0, by = 0.1),
    minor_breaks = seq(0.0, 1.0, by = 0.1)
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(data = t_coincidence, aes(yintercept = f_tmh, lty = target)) +
  labs(
    title = "% epitopes that overlap with TMH per haplotype",
    caption = caption_text
  )
p
p + ggsave(target_filename, width = 7, height = 7)


# Facet labels
facet_labels <- paste0(
  t_general$english_name, "\n",
  "TMHs: ", t_general$n_tmh_pureseqtm, "\n",
  t_general$n_aas, " AAs"
)
names(facet_labels) <- t_general$target


p + facet_grid(
  target ~ ., scales = "free",
  labeller = ggplot2::as_labeller(facet_labels)
) + ggplot2::theme(strip.text.y.right = ggplot2::element_text(angle = 0)) +
  ggplot2::theme(legend.position = "none") +
  ggsave(target_filename_grid, width = 7, height = 14)

# Normalize
t_tmh_binders$coincidence <- NA
for (i in seq_len(nrow(t_tmh_binders))) {
  target <- t_tmh_binders$target[i]
  coincidence <- NA
  if (target == "covid") coincidence <- f_covid
  else if (target == "flua") coincidence <- f_flua
  else if (target == "hepa") coincidence <- f_hepa
  else if (target == "hiv") coincidence <- f_hiv
  else if (target == "human") coincidence <- f_human
  else if (target == "myco") coincidence <- f_myco
  else if (target == "polio") coincidence <- f_polio
  else if (target == "rhino") coincidence <- f_rhino
  else stop("?")
  t_tmh_binders$coincidence[i] <- coincidence

}
t_tmh_binders$normalized_f_tmh <- t_tmh_binders$f_tmh / t_tmh_binders$coincidence

ggplot(t_tmh_binders, aes(x = haplotype, y = normalized_f_tmh, fill = target)) +
  geom_col(position = position_dodge(), color = "#000000") +
  xlab(paste0("MHC-", roman_mhc_class, " HLA haplotype")) +
  ylab("Normalized epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(aes(yintercept = 1), lty = "dashed") +
  labs(
    title = "Normalized % epitopes that overlap with TMH per haplotype",
    caption = glue::glue(
      "Dashed line: normalized expected percentage of epitopes ",
      "that have one residue overlapping with a TMH"
    )
  ) + ggsave(target_filename_normalized, width = 7, height = 7)



# Virus only
t_tmh_binders_virus_only <- t_tmh_binders %>% filter(target %in% c("covid", "flua", "hepa", "hiv", "polio", "rhino"))
t_coincidence_virus_only <- t_coincidence %>% filter(target %in% c("covid", "flua", "hepa", "hiv", "polio", "rhino"))

caption_text <- paste0(
  "Horizontal lines: % ", bbbq::get_mhc_peptide_length(mhc_class) ,"-mers that overlaps with TMH in ",
  "SARS-Cov2 (",     formatC(100.0 * mean(f_covid), digits = 3),"%), \n",
  "Influenza A (",   formatC(100.0 * mean(f_flua), digits = 3),"%), \n",
  "Hepatitus A (",   formatC(100.0 * mean(f_hepa), digits = 3),"%), \n",
  "HIV (",           formatC(100.0 * mean(f_hiv), digits = 3),"%), \n",
  "Polio (",         formatC(100.0 * mean(f_polio), digits = 3),"%), \n",
  "Rhinovirus (",     formatC(100.0 * mean(f_rhino), digits = 3),"%)"
)


p <- ggplot(
  t_tmh_binders_virus_only,
  aes(x = as.factor(haplotype), y = f_tmh, fill = target)
) +
  geom_col(position = position_dodge(), color = "#000000") +
  xlab(paste0("MHC-", roman_mhc_class, " HLA haplotype")) +
  ylab("Epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 2),
    breaks = seq(0.0, 1.0, by = 0.1),
    minor_breaks = seq(0.0, 1.0, by = 0.1)
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(data = t_coincidence_virus_only, aes(yintercept = f_tmh, lty = target)) +
  labs(
    title = "% epitopes that overlap with TMH per haplotype",
    caption = caption_text
  )
p
p + ggsave(target_virus_only_filename, width = 7, height = 7)

p + facet_grid(
  target ~ ., scales = "free",
  labeller = ggplot2::as_labeller(facet_labels)
  ) +
  ggplot2::theme(strip.text.y.right = ggplot2::element_text(angle = 0)) +
  ggplot2::theme(legend.position = "none") +
  ggsave(target_virus_only_filename_grid, width = 7, height = 14)
p

ggplot(
  t_tmh_binders %>% filter(target %in% c("covid", "flua", "hepa", "hiv", "polio", "rhino")),
    aes(x = haplotype, y = normalized_f_tmh, fill = target)
  ) +
  geom_col(position = position_dodge(), color = "#000000") +
  xlab(paste0("MHC-", roman_mhc_class, " HLA haplotype")) +
  ylab("Normalized epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(aes(yintercept = 1), lty = "dashed") +
  labs(
    title = "Normalized % epitopes that overlap with TMH per haplotype",
    caption = glue::glue(
      "Dashed line: normalized expected percentage of epitopes ",
      "that have one residue overlapping with a TMH"
    )
  ) + ggsave(target_virus_only_filename_normalized, width = 7, height = 7)
