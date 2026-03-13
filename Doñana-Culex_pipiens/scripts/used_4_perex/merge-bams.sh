#!/bin/bash
#optimized for perexiguus md bam files

# Set strict mode
set -euo pipefail

# Input and output directories
dir=${1}
bam_dir="/sietch_colab/scamison/talapas/${dir}/mark-duplicates"
out_dir="/sietch_colab/scamison/talapas/${dir}/merged"

mkdir -p "$out_dir"
cd "$bam_dir" || exit 1

# Extract unique sample IDs (PX****)
sample_ids=$(ls *.md.bam | sed -E 's/^(PX[0-9]+)_.*/\1/' | sort | uniq)

# Loop over each sample ID
for sample in $sample_ids; do
    echo "Processing sample: $sample"

    # Find all BAM files for this sample
    bam_files=($(ls ${sample}_*.md.bam))

    if [ ${#bam_files[@]} -eq 1 ]; then
        original_bam="${bam_files[0]}"
        renamed_bam="$out_dir/${sample}.merged.sorted.bam"
        echo "Only one BAM for $sample, renaming and moving: $original_bam → $renamed_bam"
        cp "$original_bam" "$renamed_bam"
        echo "$sample" >> "$bam_dir/no-merged-files.txt"

    else
        merged_bam="$out_dir/${sample}.merged.bam"
        sorted_bam="$out_dir/${sample}.merged.sorted.bam"

        echo "Merging ${#bam_files[@]} BAM files for $sample..."
        samtools merge "$merged_bam" "${bam_files[@]}"

        echo "Sorting merged BAM for $sample..."
        samtools sort -o "$sorted_bam" "$merged_bam"

        rm "$merged_bam"
    fi

    echo "Done: ${sample}"
done
