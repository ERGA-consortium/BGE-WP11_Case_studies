#!/usr/bin/env bash

IN_DIR="results/gatk/joint/genotyped_vcfs"
CHROMS_LIST="reference/chromosomes.list"

OUT_DIR="results/gatk/joint"
OUT_VCF="${OUT_DIR}/cohort.gathered.vcf.gz"

JAVA_HEAP_GB=8
TMP_DIR="${OUT_DIR}/tmp_gather"

mkdir -p "${OUT_DIR}" "${TMP_DIR}" logs

INPUTS=()
while read -r CHR; do
  [ -z "${CHR}" ] && continue
  INPUTS+=("-I" "${IN_DIR}/${CHR}.vcf.gz")
done < "${CHROMS_LIST}"

echo "[$(date)] Gathering cohort VCF -> ${OUT_VCF}"

gatk --java-options "-Xmx${JAVA_HEAP_GB}g -Djava.io.tmpdir=${TMP_DIR}" GatherVcfs \
  "${INPUTS[@]}" \
  -O "${OUT_VCF}" \
  >> "logs/gather_cohort_vcf.log" 2>&1

gatk IndexFeatureFile -I "${OUT_VCF}" >> "logs/gather_cohort_vcf.log" 2>&1

echo "[$(date)] Done: ${OUT_VCF}"
