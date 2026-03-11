#!/usr/bin/env bash

IN_DIR="results/bam_dedup"          # where *_marked.bam are
OUT_DIR="results/bam_dedup_rmdup"   # output directory
THREADS=20

mkdir -p "${OUT_DIR}" logs

for BAM in "${IN_DIR}"/*.bam; do
  SAMPLE=$(basename "${BAM}" .bam)
  OUT_BAM="${OUT_DIR}/${SAMPLE}_dedup.bam"

  echo "Removing duplicates for: ${SAMPLE}"

  # Keep reads that are NOT marked as duplicates
  sambamba view \
    -f bam -h \
    -F "not duplicate" \
    -t "${THREADS}" \
    "${BAM}" \
    -o "${OUT_BAM}" \
    2> "logs/${SAMPLE}.rmdup.stderr.log"

  # Index BAM
  sambamba index "${OUT_BAM}"

done