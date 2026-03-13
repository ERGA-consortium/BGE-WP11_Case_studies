#!/bin/bash
# This script removes duplicates from all BAM files in a directory using Picard.

# Load necessary modules
module load miniconda3
conda activate culex
module load racs-eb/1
module load samtools
module load picard

# Variables
dir=${1}  # e.g., 3.repetidas
subdir=${2}
bam_dir="/sietch_colab/scamison/talapas/${dir}/${subdir}"
out_dir="/sietch_colab/scamison/talapas/${dir}/mark-duplicates"

mkdir -p "$out_dir"

# Loop through all .PR.sorted.rg.bam files
for in_bam in "$bam_dir"/*.sorted.rg.bam; do
    # Extract filename components
    filename=$(basename "$in_bam")
    id_lane="${filename%.sorted.rg.bam}"

    output_bam="$out_dir/${id_lane}.md.bam"
    output_metrics="$out_dir/${id_lane}_marked_dup_metrics.txt"

    echo "Processing: $filename"

    picard  -Xmx6g -XX:ParallelGCThreads=5 -XX:ConcGCThreads=5 MarkDuplicates \
        I="$in_bam" \
        O="$output_bam" \
        M="$output_metrics" \
        REMOVE_DUPLICATES=true
done