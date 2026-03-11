#!/usr/bin/env bash

REF="reference/genome.fna"
DB_DIR="results/gatk/joint/genomicsdb"
CHROMS_LIST="reference/chromosomes.list"

OUT_DIR="results/gatk/joint/genotyped_vcfs"
LOG_DIR="logs"

mkdir -p "${OUT_DIR}" "${LOG_DIR}"

while read -r CHR; do
  [ -z "${CHR}" ] && continue

  IN_DB="gendb://${DB_DIR}/genomicsdb_${CHR}"
  OUT_VCF="${OUT_DIR}/${CHR}.vcf.gz"
  LOG="${LOG_DIR}/genotype_${CHR}.log"

  echo "[$(date)] GenotypeGVCFs ${CHR}"

  gatk GenotypeGVCFs \
    -R "${REF}" \
    -V "${IN_DB}" \
    -O "${OUT_VCF}" \
    >> "${LOG}" 2>&1

done < "${CHROMS_LIST}"

echo "[$(date)] All chromosomes genotyped."