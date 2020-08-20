#!/bin/bash
#
# make this project on Peregrine, by loading the required modules first.
#
# Usage (in queue, preferred):
#
#   sbatch ./peregrine_make.sh
#
# Usage (local):
#
#   ./peregrine_make.sh
#
#
# Peregrine directives:
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --job-name=peregrine_make
#SBATCH --output=peregrine_make_%j.log
module load R Python
echo "make $@"
make "$@"
