#!/usr/bin/env bash

IN_DIR="results/trimmed"
OUT_DIR="results/bam_aligned"
REF="reference/genome.fna"
THREADS=20

mkdir -p "${OUT_DIR}" logs

for R1 in "${IN_DIR}"/*_trimmed_1.fq.gz; do
  SAMPLE=$(basename "${R1}" _trimmed_1.fq.gz)
  R2="${IN_DIR}/${SAMPLE}_trimmed_2.fq.gz"
  BAM="${OUT_DIR}/${SAMPLE}.sorted.bam"

  echo "Mapping sample: ${SAMPLE}"

  bwa mem -M -t "${THREADS}" "${REF}" "${R1}" "${R2}" | \
    samtools sort -o "${BAM}"

done
