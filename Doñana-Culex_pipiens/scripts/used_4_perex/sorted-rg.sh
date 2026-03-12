#!/bin/bash

##~##########################################################
# SCRIPT HECHO PARA MUESTRAS DE PEREXIGUUS
# Añade read groups, indexa BAMs y elimina los .sorted intermedios
##~##########################################################

set -euo pipefail

# Input directory as first argument

BAM_DIR="."

# Loop through all .sorted.bam files
for sorted_bam in "$BAM_DIR"/*.PR.sorted.bam; do
    base=$(basename "$sorted_bam" .PR.sorted.bam)

    # Extract ID (first field before first underscore)
    id=$(echo "$base" | cut -d'_' -f1)

    # Extract lane (pattern after last dot before .sorted.bam, e.g. L1)
    lane=$(echo "$base" | awk -F '.' '{print $(NF-2)}')

    # Set fixed read type
    r="PR"

    # Define output file names
    sorted_rg_bam="${BAM_DIR}/${id}_${lane}.${r}.sorted.rg.bam"
    stats_file="${BAM_DIR}/${id}.${lane}.stats"

    echo "Processing $id lane $lane"

    # Add or replace read groups
    picard AddOrReplaceReadGroups \
        I="$sorted_bam" \
        O="$sorted_rg_bam" \
        RGID="${id}" \
        RGLB=PEREX_UNK_BATCH \
        RGPL=Illumina \
        RGPU="${id}.${lane}.${r}" \
        RGSM="${id}" \
        VALIDATION_STRINGENCY=SILENT

    # Index
    echo "Indexing $sorted_rg_bam"
    samtools index "$sorted_rg_bam"

    # Generate flagstat
    echo "Generating stats to $stats_file"
    samtools flagstat "$sorted_rg_bam" > "$stats_file"

    # Remove intermediate sorted BAM
    echo "Removing $sorted_bam"
    rm "$sorted_bam"

    echo "Done with $id lane $lane"
done

echo "✅ All BAMs processed."