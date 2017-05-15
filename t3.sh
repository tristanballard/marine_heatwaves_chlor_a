#!/bin/bash

#SBATCH --job-name=t3
#SBATCH --error=/scratch/users/tballard/sst/modis/t3.err
#SBATCH --output=/scratch/users/tballard/sst/modis/t3.out
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=62GB
#SBATCH --mail-type=END
#SBATCH --mail-user=tballard@stanford.edu
#SBATCH --time=24:00:00
#SBATCH -p diffenbaugh

ml use /share/sw/modules/all
ml load R
ml load netCDF/4.3.0

Rscript threshold.part2.modis.R 801 1000
Rscript threshold.part2.modis.R 1001 1200