#!/bin/bash

#SBATCH -A r01304
#SBATCH -p general
#SBATCH --job-name=test_file
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32G

#SBATCH --output=/N/u/wuyuno/Quartz/Documents/BrainStimulation-paper/output/test_file_%A_%a.out.txt
#SBATCH --error=/N/u/wuyuno/Quartz/Documents/BrainStimulation-paper/error/test_file_%A_%a.err.txt
#SBATCH --mail-user=wuyuno@iu.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --time=4-00:00:00

module load r
module load geos
module load udunits
module load proj
module load gdal

Rscript /N/u/wuyuno/Quartz/Documents/GitHub/BrainStimulation-paper/test_file.R
