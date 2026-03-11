#!/usr/bin/env bash

IN_DIR="results/bam_aligned"
OUT_DIR="results/bam_dedup"
THREADS=20

mkdir -p "${OUT_DIR}" logs

for BAM in "${IN_DIR}"/*.bam; do
  SAMPLE=$(basename "${BAM}" .bam)
  OUT_BAM="${OUT_DIR}/${SAMPLE}_marked.bam"

  echo "Marking duplicates for: ${SAMPLE}"

  sambamba markdup \
    -t "${THREADS}" \
    "${BAM}" \
    "${OUT_BAM}"

done
