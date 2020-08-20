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
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
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
t_tmh_binders <- readr::read_csv(
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
t_tmh_binders <- t_tmh_binders %>% filter(haplotype_id %in% t_haplotype_lut$haplotype_id)

# Group all proteins
t_tmh_binders <- t_tmh_binders %>% dplyr::group_by(target, haplotype_id) %>%
    dplyr::summarize(
      n_binders = sum(n_binders),
      n_binders_tmh = sum(n_binders_tmh),
      n_spots = sum(n_spots),
      n_spots_tmh = sum(n_spots_tmh),
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
f_human <- t_coincidence$f_tmh[t_coincidence$target == "human"]
f_myco <- t_coincidence$f_tmh[t_coincidence$target == "myco"]

roman_mhc_class <- NA
if (mhc_class == 1) roman_mhc_class <- "I"
if (mhc_class == 2) roman_mhc_class <- "II"

caption_text <- paste0(
  "Horizontal lines: % ", bbbq::get_mhc_peptide_length(mhc_class) ,"-mers that overlaps with TMH in ",
  "humans (dotted line, ", formatC(100.0 * mean(f_human), digits = 3),"%), \n",
  "Mycobacterium (dashed line, ", formatC(100.0 * mean(f_myco), digits = 3),"%), \n",
  "SARS-Cov2 (solid line, ", stringr::str_trim(formatC(100.0 * mean(f_covid), digits = 3)),"%)"
)
p <- ggplot(t_tmh_binders, aes(x = haplotype, y = f_tmh, fill = target)) +
  scale_fill_manual(values = c("human" = "#ffffff", "covid" = "#cccccc", "myco" = "#888888")) +
  geom_col(position = position_dodge(), color = "#000000") +
  xlab(paste0("MHC-", roman_mhc_class, " HLA haplotype")) +
  ylab("Epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 2),
    breaks = seq(0.0, 1.0, by = 0.1),
    minor_breaks = seq(0.0, 1.0, by = 0.1)
    # limits = c(0, 1.0)
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(data = t_coincidence, aes(yintercept = f_tmh, lty = target)) +
  labs(
    title = "% epitopes that overlap with TMH per haplotype",
    caption = caption_text
  )

p + ggsave(target_filename, width = 7, height = 7)

p + facet_grid(target ~ ., scales = "free") +
  ggsave(target_filename_grid, width = 7, height = 7)

