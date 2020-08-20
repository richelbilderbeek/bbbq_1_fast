#
# Usage:
#
# Create the data on Peregrine
#
#   make peregrine
#
# Create the results locally, assume data is there
#
#   make results
#
.DELETE_ON_ERROR:
all: 
	echo "Run either 'make peregrine' on Peregrine, to create the data"
	echo "or run either 'make results' locally, to create the results"

# Create the test proteomes
use_test_proteomes_and_haplotypes:
	Rscript get_proteome.R test_covid
	Rscript get_proteome.R test_human
	Rscript get_proteome.R test_myco
	Rscript create_haplotypes_lut.R test

# Create all counts
peregrine: haplotypes_lut.csv \
     covid_proteins_lut.csv human_proteins_lut.csv myco_proteins_lut.csv \
     myco_h21_p3_counts.csv

# Combine all counts into tables and figures
results: counts.csv \
         table_tmh_binders_mhc1.latex table_tmh_binders_mhc2.latex \
         table_ic50_binders.latex \
         table_f_tmh.latex

# Combine all counts into tables and figures
figures: fig_f_tmh_mhc1.png fig_f_tmh_mhc2.png

################################################################################
#
# 1. PEREGRINE
#
################################################################################

################################################################################
# Haplotypes
################################################################################
haplotypes_lut.csv:
	Rscript create_haplotypes_lut.R

################################################################################
# Targets
################################################################################

covid.fasta:
	Rscript get_proteome.R covid

human.fasta:
	Rscript get_proteome.R human

myco.fasta:
	Rscript get_proteome.R myco

################################################################################
# Protein LUT
################################################################################

covid_proteins_lut.csv: covid.fasta
	Rscript create_proteins_lut.R covid

human_proteins_lut.csv: human.fasta
	Rscript create_proteins_lut.R human

myco_proteins_lut.csv: myco.fasta
	Rscript create_proteins_lut.R myco

################################################################################
# Counts, using sbatch or not
################################################################################

# Local: will run all jobs
# On Peregrine: will submit max 987 jobs
myco_h21_p3_counts.csv:
	Rscript create_all_counts.R

################################################################################
#
# 2. RESULTS
#
################################################################################

counts.csv:
	Rscript merge_all_counts.R

################################################################################
# Create the CSV tables for the binders
################################################################################

table_tmh_binders_mhc1.latex: counts.csv
	Rscript create_table_tmh_binders_mhc.R mhc1

table_tmh_binders_mhc2.latex: counts.csv
	Rscript create_table_tmh_binders_mhc.R mhc2

################################################################################
# Create all LaTeX tables
################################################################################

# Easy and general table
table_ic50_binders.latex: haplotypes_lut.csv
	Rscript create_table_ic50_binders.R

table_f_tmh.latex:
	Rscript create_table_f_tmh.R

################################################################################
# Create the figures
################################################################################

fig_f_tmh_mhc1.png: counts.csv
	Rscript create_figure.R mhc1

fig_f_tmh_mhc2.png: counts.csv
	Rscript create_figure.R mhc2

#bbbq_1_percentages.csv: bbbq_1.Rmd
#	Rscript -e 'rmarkdown::render("bbbq_1.Rmd")'

update_packages:
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnuggetsr")'
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnpreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/bbbq", ref = "develop")'

clean:
	rm -f *.png *.latex *.pdf *.fasta
	echo "I kept the CSV files, as these are hard to calculate"

clean_all:
	rm -f *.png *.latex *.pdf *.fasta *.csv

