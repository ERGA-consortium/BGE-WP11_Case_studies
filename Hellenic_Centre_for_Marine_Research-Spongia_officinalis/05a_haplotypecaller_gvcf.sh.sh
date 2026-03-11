#!/usr/bin/env bash

SAMPLES_DIR="results/bam_dedup_rmdup"         
REF="reference/genome.fna"
OUTDIR="results/gatk/gvcf_intervals"
INTERVALS_FILE="intervals/genome_6Mb.list"

MAX_JOBS=18
THREADS=1
LOGDIR="${OUTDIR}/logs"

mkdir -p "${OUTDIR}" "${LOGDIR}"

intervals=( $(cat "${INTERVALS_FILE}") )

for INTERVAL in "${intervals[@]}"; do
  for BAM in "${SAMPLES_DIR}"/*.bam; do
    SAMPLE=$(basename "${BAM}" .bam)
    LOG_FILE="${LOGDIR}/${SAMPLE}_${INTERVAL}.log"

    echo "[$(date)] Starting ${SAMPLE} interval ${INTERVAL}" > "${LOG_FILE}"

    gatk HaplotypeCaller \
      -R "${REF}" \
      -I "${BAM}" \
      -O "${OUTDIR}/${SAMPLE}_${INTERVAL}.g.vcf.gz" \
      -ERC GVCF \
      -L "${INTERVAL}" \
      --native-pair-hmm-threads "${THREADS}" \
      >> "${LOG_FILE}" 2>&1 &

    while [ "$(jobs -rp | wc -l)" -ge "${MAX_JOBS}" ]; do
      sleep 2
    done
  done
done

wait
echo "[$(date)] All intervals completed."
