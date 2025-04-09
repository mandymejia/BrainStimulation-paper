#!/bin/bash
mkdir -p logs

for jobfile in jobs/*.R; do
  scriptname=$(basename "$jobfile" .R)
  sbatch --job-name="$scriptname" \
         --output="logs/${scriptname}_%j.out" \
         --error="logs/${scriptname}_%j.err" \
         slurm_job.sh "$jobfile"
done

