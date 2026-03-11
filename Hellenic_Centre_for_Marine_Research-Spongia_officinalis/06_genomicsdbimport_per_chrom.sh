#!/usr/bin/env bash

# Inputs
REF="reference/genome.fna"
SAMPLE_MAP="results/gatk/joint/sample_map.tsv"     # sample<TAB>path_to_sample.g.vcf.gz
CHROMS_LIST="reference/chromosomes.list"           # one chrom per line

# Outputs
OUT_DIR="results/gatk/joint/genomicsdb"
TMP_DIR="results/gatk/joint/tmp"

# Runtime knobs
THREADS=12
BATCH_SIZE=40
JAVA_HEAP_GB=16

mkdir -p "${OUT_DIR}" "${TMP_DIR}" logs

while read -r CHR; do
  [ -z "${CHR}" ] && continue

  WS="${OUT_DIR}/genomicsdb_${CHR}"
  LOG="logs/genomicsdbimport_${CHR}.log"

  echo "[$(date)] GenomicsDBImport: ${CHR}"

  gatk --java-options "-Xmx${JAVA_HEAP_GB}g" GenomicsDBImport \
    --genomicsdb-workspace-path "${WS}" \
    --sample-name-map "${SAMPLE_MAP}" \
    --reader-threads "${THREADS}" \
    --reference "${REF}" \
    -L "${CHR}" \
    --batch-size "${BATCH_SIZE}" \
    --tmp-dir "${TMP_DIR}" \
    --overwrite-existing-genomicsdb-workspace true \
    >> "${LOG}" 2>&1

done < "${CHROMS_LIST}"