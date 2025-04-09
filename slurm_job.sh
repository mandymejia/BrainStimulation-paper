#!/bin/bash
#SBATCH -A r01304
#SBATCH -p general
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=20G
#SBATCH --time=4-00:00:00
#SBATCH --mail-user=wuyuno@iu.edu
#SBATCH --mail-type=BEGIN,END,FAIL

module load r
module load proj
module load gsl
module load udunits
module load gdal
module load geos

Rscript "$1"

