#!/bin/bash

#SBATCH -A r01304
#SBATCH -p general
#SBATCH --job-name=brain_stimulation_utah
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=20G

#SBATCH --output=/N/u/wuyuno/Quartz/Documents/BrainStimulation-paper/output/brain_stimulation_utah_%A_%a.out.txt
#SBATCH --error=/N/u/wuyuno/Quartz/Documents/BrainStimulation-paper/error/brain_stimulation_utah_%A_%a.err.txt
#SBATCH --mail-user=wuyuno@iu.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --time=4-00:00:00

module load r
module load geos
module load udunits
module load proj
module load gdal

R CMD BATCH /N/u/wuyuno/Quartz/Documents/GitHub/BrainStimulation-paper/brain_stimulation_utah.R
