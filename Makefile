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
     covid_proteins_lut.csv flua_proteins_lut.csv hepa_proteins_lut.csv \
     human_proteins_lut.csv \
     myco_proteins_lut.csv polio_proteins_lut.csv rhino_proteins_lut.csv \
     flua_h1_counts.csv \
     human_h1_counts.csv \
     rhino_h1_counts.csv

# Combine all counts into tables and figures
results: counts.csv \
         table_tmh_binders_mhc1.latex table_tmh_binders_mhc2.latex \
         table_ic50_binders.latex \
         table_f_tmh.latex

# Combine all counts into tables and figures
figures: fig_f_tmh_mhc1.png fig_f_tmh_mhc2.png general.csv

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

flua.fasta:
	Rscript get_proteome.R flua

hepa.fasta:
	Rscript get_proteome.R hepa

hiv.fasta:
	Rscript get_proteome.R hiv

human.fasta:
	Rscript get_proteome.R human

myco.fasta:
	Rscript get_proteome.R myco

polio.fasta:
	Rscript get_proteome.R polio

rhino.fasta:
	Rscript get_proteome.R rhino

################################################################################
# Protein LUT
################################################################################

covid_proteins_lut.csv: covid.fasta
	Rscript create_proteins_lut.R covid

flua_proteins_lut.csv: flua.fasta
	Rscript create_proteins_lut.R flua

hepa_proteins_lut.csv: hepa.fasta
	Rscript create_proteins_lut.R hepa

hiv_proteins_lut.csv: hiv.fasta
	Rscript create_proteins_lut.R hiv

human_proteins_lut.csv: human.fasta
	Rscript create_proteins_lut.R human

myco_proteins_lut.csv: myco.fasta
	Rscript create_proteins_lut.R myco

polio_proteins_lut.csv: polio.fasta
	Rscript create_proteins_lut.R polio

rhino_proteins_lut.csv: rhino.fasta
	Rscript create_proteins_lut.R rhino

################################################################################
# Counts, using sbatch or not
################################################################################

# Will submit/run all jobs
human_h1_counts.csv:
	Rscript create_all_counts_per_proteome.R

flua_h1_counts.csv:
	Rscript create_all_counts_per_proteome.R

hiv_h1_counts.csv:
	Rscript create_all_counts_per_proteome.R

rhino_h1_counts.csv:
	Rscript create_all_counts_per_proteome.R

################################################################################
#
# 2. RESULTS
#
################################################################################

counts.csv:
	Rscript merge_all_counts_per_proteome.R

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

general.csv:
	Rscript create_general.R

update_packages:
	Rscript -e 'remotes::install_github("richelbilderbeek/peregrine")'
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnuggetsr")'
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnpreds")'
	Rscript -e 'remotes::install_github("jtextor/epitope-prediction")'
	Rscript -e 'remotes::install_github("richelbilderbeek/epiprepreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/netmhc2pan")'
	Rscript -e 'remotes::install_github("richelbilderbeek/nmhc2ppreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/bbbq", ref = "develop")'

clean:
	rm -f *.png *.latex *.pdf *.fasta
	echo "I kept the CSV files, as these are hard to calculate"

clean_all:
	rm -f *.png *.latex *.pdf *.fasta *.csv

